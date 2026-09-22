import { describe, expect, it } from "bun:test"
import { existsSync } from "node:fs"

import activitywatch from "../plugins/activitywatch/index"
import inventory from "../plugins/inventory/tui"

const waitFor = async (check: () => boolean, timeout = 1000) => {
  const started = Date.now()
  while (!check()) {
    if (Date.now() - started > timeout) throw new Error("Timed out waiting for condition")
    await new Promise((resolve) => setTimeout(resolve, 5))
  }
}

describe("OpenCode v2 plugin entrypoints", () => {
  it("uses the v2 discovered-plugin directory layout", () => {
    const root = new URL("../plugins/", import.meta.url)
    expect(existsSync(new URL("activitywatch/index.ts", root))).toBe(true)
    expect(existsSync(new URL("inventory/tui.tsx", root))).toBe(true)
  })

  it("exposes ActivityWatch as a v2 server module", () => {
    expect(activitywatch.id).toBe("local.activitywatch")
    expect(typeof activitywatch.setup).toBe("function")
  })

  it("sends a heartbeat for session activity", async () => {
    const calls: Array<{ url: string; init?: RequestInit }> = []
    const originalFetch = globalThis.fetch
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      const url = String(input)
      calls.push({ url, init })
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield {
          type: "session.created",
          properties: { sessionID: "session-1", info: { id: "session-1", title: "Fix the build" } },
        }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket", pulsetime: 30 },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
      })
      await waitFor(() => calls.length === 3)
      await cleanup?.()

      expect(calls.map((call) => call.url)).toEqual([
        "http://activitywatch.test/api/0/info",
        "http://activitywatch.test/api/0/buckets/test-bucket",
        "http://activitywatch.test/api/0/buckets/test-bucket/heartbeat?pulsetime=30",
      ])
      const heartbeat = JSON.parse(String(calls[2].init?.body))
      expect(heartbeat.data).toMatchObject({
        app: "opencode",
        title: "Fix the build",
        path: "/tmp/demo",
        project: "project-1",
        sessionID: "session-1",
        event: "session.created",
      })
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("uses OpenCode v2 session.renamed titles", async () => {
    const originalFetch = globalThis.fetch
    const heartbeats: Array<{ data: { title?: string } }> = []
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      const url = String(input)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      if (url.includes("/heartbeat?")) heartbeats.push(JSON.parse(String(init?.body)))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.renamed", data: { sessionID: "session-1", title: "Renamed session" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
      })
      await waitFor(() => heartbeats.length >= 1)
      await cleanup?.()

      expect(heartbeats[0].data.title).toBe("Renamed session")
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("forgets ActivityWatch session titles after deletion", async () => {
    const originalFetch = globalThis.fetch
    const heartbeats: Array<{ data: { title?: string } }> = []
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      const url = String(input)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      if (url.includes("/heartbeat?")) heartbeats.push(JSON.parse(String(init?.body)))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.created", properties: { sessionID: "session-1", title: "Fix the build" } }
        yield { type: "session.deleted", properties: { sessionID: "session-1" } }
        yield { type: "session.status", data: { sessionID: "session-1" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
      })
      await waitFor(() => heartbeats.length >= 3)
      await cleanup?.()

      expect(heartbeats.at(-1)?.data.title).toBe("opencode: project-1")
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("forgets deleted ActivityWatch sessions while the server is unavailable", async () => {
    const originalFetch = globalThis.fetch
    const heartbeats: Array<{ data: { title?: string } }> = []
    let bucketAttempts = 0
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      const url = String(input)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      if (url.endsWith("/api/0/buckets/test-bucket") && ++bucketAttempts <= 2) throw new Error("offline")
      if (url.includes("/heartbeat?")) heartbeats.push(JSON.parse(String(init?.body)))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.created", properties: { sessionID: "session-1", title: "Fix the build" } }
        yield { type: "session.deleted", properties: { sessionID: "session-1" } }
        yield { type: "session.status", data: { sessionID: "session-1" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
      })
      await waitFor(() => heartbeats.length >= 1)
      await cleanup?.()

      expect(heartbeats.at(-1)?.data.title).toBe("opencode: project-1")
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("aborts stalled ActivityWatch requests during cleanup", async () => {
    const originalFetch = globalThis.fetch
    let requestSignal: AbortSignal | undefined
    let fetchStarted = false
    globalThis.fetch = (async (_input: string | URL | Request, init?: RequestInit) =>
      new Promise<Response>((_resolve, reject) => {
        fetchStarted = true
        requestSignal = init?.signal ?? undefined
        if (requestSignal?.aborted) return reject(new DOMException("Aborted", "AbortError"))
        requestSignal?.addEventListener("abort", () => reject(new DOMException("Aborted", "AbortError")), { once: true })
      })) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.created", properties: { sessionID: "session-1" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo" },
        event: { subscribe: () => events() },
      })
      await waitFor(() => fetchStarted)

      const result = await Promise.race([
        cleanup?.().then(() => "cleaned"),
        new Promise<string>((resolve) => setTimeout(() => resolve("timed-out"), 100)),
      ])
      expect(result).toBe("cleaned")
      expect(requestSignal?.aborted).toBe(true)
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("resubscribes after an ActivityWatch event stream failure", async () => {
    const originalFetch = globalThis.fetch
    const calls: string[] = []
    let subscriptions = 0
    globalThis.fetch = (async (input: string | URL | Request) => {
      const url = String(input)
      calls.push(url)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      const subscribe = ({ signal }: { signal?: AbortSignal } = {}) => {
        subscriptions += 1
        if (subscriptions === 1) {
          return (async function* () {
            throw new Error("stream closed")
          })()
        }
        return (async function* () {
          yield { type: "session.created", properties: { sessionID: "session-1" } }
          await new Promise<void>((resolve) => signal?.addEventListener("abort", () => resolve(), { once: true }))
        })()
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo" },
        event: { subscribe },
      })
      await waitFor(() => calls.some((url) => url.includes("/heartbeat?")))
      await cleanup?.()

      expect(subscriptions).toBe(2)
      expect(calls.some((url) => url.includes("/heartbeat?"))).toBe(true)
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("retries bucket creation after ActivityWatch is temporarily unavailable", async () => {
    const calls: string[] = []
    const originalFetch = globalThis.fetch
    let bucketAttempts = 0
    globalThis.fetch = (async (input: string | URL | Request) => {
      const url = String(input)
      calls.push(url)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      if (url.endsWith("/api/0/buckets/test-bucket") && ++bucketAttempts === 1) throw new Error("offline")
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.created", properties: { sessionID: "session-1" } }
        yield { type: "session.status", data: { sessionID: "session-1" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo" },
        event: { subscribe: () => events() },
      })
      await waitFor(() => calls.length >= 4)
      await cleanup?.()

      expect(calls.filter((url) => url.endsWith("/api/0/info"))).toHaveLength(2)
      expect(calls.filter((url) => url.endsWith("/api/0/buckets/test-bucket"))).toHaveLength(2)
      expect(calls.filter((url) => url.includes("/heartbeat?"))).toHaveLength(1)
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("exposes inventory as a v2 CLI plugin", () => {
    expect(inventory.id).toBe("local.inventory")
    expect(typeof inventory.setup).toBe("function")
  })

  it("registers keymap commands from a component-owned app slot", () => {
    const slots: Array<{ append?: string; render?: () => unknown }> = []
    const context = {
      options: {},
      keymap: {
        layer: () => {
          throw new Error("Keymap.Provider is missing")
        },
      },
      ui: {
        slot: (claim: { append?: string; render?: () => unknown }) => {
          slots.push(claim)
          return () => undefined
        },
      },
    }

    expect(() => inventory.setup(context as never)).not.toThrow()
    expect(slots.some((slot) => slot.append === "app")).toBe(true)
  })

  it("registers the inventory command and startup summary slot", async () => {
    const layers: Array<() => { commands?: Array<{ id?: string; palette?: true }> }> = []
    const slots: Array<{ append?: string; render?: () => unknown }> = []
    const cleanupCalls: string[] = []

    const cleanup = await inventory.setup({
      options: {},
      keymap: { layer: (layer: () => { commands?: Array<{ id?: string; palette?: true }> }) => layers.push(layer) },
      ui: {
        slot: (claim: { append?: string; render?: () => unknown }) => {
          slots.push(claim)
          return () => cleanupCalls.push("slot")
        },
      },
    } as never)

    expect(slots).toHaveLength(2)
    expect(slots.map((slot) => slot.append)).toEqual(["app", "home.footer"])
    slots.find((slot) => slot.append === "app")?.render?.()
    expect(layers).toHaveLength(1)
    expect(layers[0]().commands?.[0]).toMatchObject({ id: "inventory.open", palette: true })

    await cleanup?.()
    expect(cleanupCalls).toEqual(["slot", "slot"])
  })

  it("loads v2 inventory data when the command runs", async () => {
    let layer: (() => { commands?: Array<{ id?: string; run: () => Promise<void> | void }> }) | undefined
    let appSlot: { append?: string; render?: () => unknown } | undefined
    let dialog: { options: Array<{ title: string; category?: string }> } | undefined
    const synced: string[] = []
    const location = { directory: "/tmp/demo" }
    const collection = (name: string, values: unknown[]) => ({
      sync: async () => synced.push(name),
      list: () => values,
    })

    await inventory.setup({
      options: { startupPanel: { enabled: false } },
      location,
      keymap: { layer: (value: typeof layer) => (layer = value) },
      client: {
        plugin: {
          list: async () => ({ data: [{ id: "local.activitywatch", source: "local", active: true }] }),
        },
      },
      data: {
        location: {
          default: () => location,
          agent: collection("agents", [{ name: "build", description: "Build things" }]),
          skill: collection("skills", [{ name: "tdd", description: "Test first" }]),
          command: collection("commands", [{ name: "review", description: "Review code" }]),
          integration: collection("integrations", []),
          model: collection("models", [{ id: "gpt-test", providerID: "openai" }]),
          provider: collection("providers", [{ id: "openai", name: "OpenAI" }]),
          reference: collection("references", []),
          mcp: {
            server: collection("mcp", [{ name: "gbrain", status: "connected" }]),
            resource: collection("resources", []),
          },
        },
      },
      ui: {
        toast: { show: () => undefined },
        dialog: {
          select: async (value: typeof dialog) => {
            dialog = value
            return undefined
          },
        },
        slot: (claim: { append?: string; render?: () => unknown }) => {
          appSlot = claim
          return () => undefined
        },
      },
    } as never)

    appSlot?.render?.()
    const command = layer?.().commands?.find((item) => item.id === "inventory.open")
    expect(command).toBeDefined()
    await command?.run()

    expect(synced).toEqual(["agents", "skills", "commands", "integrations", "models", "providers", "references", "mcp", "resources"])
    expect(dialog?.options.map((option) => option.title)).toContain("Agents: 1")
    expect(dialog?.options.map((option) => option.title)).toContain("Skills: 1")
    expect(dialog?.options.map((option) => option.title)).toContain("Plugins: 1")
    expect(dialog?.options.map((option) => option.title)).toContain("local.activitywatch")
  })

  it("bounds inventory source synchronization", async () => {
    let layer: (() => { commands?: Array<{ id?: string; run: () => Promise<void> | void }> }) | undefined
    let appSlot: { render?: () => unknown } | undefined
    let dialog: { options: Array<{ title: string }> } | undefined
    const location = { directory: "/tmp/demo" }
    const ready = { sync: async () => undefined, list: () => [] }
    const stalled = { sync: () => new Promise<void>(() => undefined), list: () => [] }

    await inventory.setup({
      options: { startupPanel: { enabled: false }, timeoutMs: 20 },
      location,
      keymap: { layer: (value: typeof layer) => (layer = value) },
      client: { plugin: { list: async () => ({ data: [] }) } },
      data: {
        location: {
          default: () => location,
          agent: stalled,
          skill: ready,
          command: ready,
          integration: ready,
          model: ready,
          provider: ready,
          reference: ready,
          mcp: { server: ready, resource: ready },
        },
      },
      ui: {
        toast: { show: () => undefined },
        dialog: { select: async (value: typeof dialog) => (dialog = value) },
        slot: (claim: { render?: () => unknown }) => {
          appSlot = claim
          return () => undefined
        },
      },
    } as never)

    appSlot?.render?.()
    const command = layer?.().commands?.find((item) => item.id === "inventory.open")
    const result = await Promise.race([
      Promise.resolve(command?.run()).then(() => "done"),
      new Promise<string>((resolve) => setTimeout(() => resolve("timed-out"), 150)),
    ])

    expect(result).toBe("done")
    expect(dialog?.options.map((option) => option.title)).toContain("agents: timed out after 20ms")
  })

  it("bounds inventory plugin listing", async () => {
    let layer: (() => { commands?: Array<{ id?: string; run: () => Promise<void> | void }> }) | undefined
    let appSlot: { render?: () => unknown } | undefined
    let dialog: { options: Array<{ title: string }> } | undefined
    const location = { directory: "/tmp/demo" }
    const ready = { sync: async () => undefined, list: () => [] }

    await inventory.setup({
      options: { startupPanel: { enabled: false }, timeoutMs: 20 },
      location,
      keymap: { layer: (value: typeof layer) => (layer = value) },
      client: { plugin: { list: () => new Promise(() => undefined) } },
      data: {
        location: {
          default: () => location,
          agent: ready,
          skill: ready,
          command: ready,
          integration: ready,
          model: ready,
          provider: ready,
          reference: ready,
          mcp: { server: ready, resource: ready },
        },
      },
      ui: {
        toast: { show: () => undefined },
        dialog: { select: async (value: typeof dialog) => (dialog = value) },
        slot: (claim: { render?: () => unknown }) => {
          appSlot = claim
          return () => undefined
        },
      },
    } as never)

    appSlot?.render?.()
    const command = layer?.().commands?.find((item) => item.id === "inventory.open")
    const result = await Promise.race([
      Promise.resolve(command?.run()).then(() => "done"),
      new Promise<string>((resolve) => setTimeout(() => resolve("timed-out"), 150)),
    ])

    expect(result).toBe("done")
    expect(dialog?.options.map((option) => option.title)).toContain("plugins: timed out after 20ms")
  })
})
