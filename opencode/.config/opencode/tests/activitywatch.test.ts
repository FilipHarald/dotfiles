import { describe, expect, it } from "bun:test"

import activitywatch from "../plugins/activitywatch/index"

const waitFor = async (check: () => boolean, timeout = 1000) => {
  const started = Date.now()
  while (!check()) {
    if (Date.now() - started > timeout) throw new Error("Timed out waiting for condition")
    await new Promise((resolve) => setTimeout(resolve, 5))
  }
}

describe("ActivityWatch location filtering", () => {
  it("ignores session activity owned by another location", async () => {
    const originalFetch = globalThis.fetch
    const heartbeats: unknown[] = []
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      if (String(input).includes("/heartbeat?")) heartbeats.push(JSON.parse(String(init?.body)))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield {
          type: "session.execution.started",
          properties: {
            sessionID: "session-1",
            info: { id: "session-1", projectID: "project-2", location: { directory: "/tmp/other" } },
          },
        }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
      })
      await new Promise((resolve) => setTimeout(resolve, 25))
      await cleanup?.()
      expect(heartbeats).toHaveLength(0)
    } finally {
      globalThis.fetch = originalFetch
    }
  })

  it("resolves the owning location for sparse session events", async () => {
    const originalFetch = globalThis.fetch
    const heartbeats: Array<{ data: { path?: string } }> = []
    globalThis.fetch = (async (input: string | URL | Request, init?: RequestInit) => {
      const url = String(input)
      if (url.endsWith("/api/0/info")) return new Response(JSON.stringify({ hostname: "test-host" }))
      if (url.includes("/heartbeat?")) heartbeats.push(JSON.parse(String(init?.body)))
      return new Response(null, { status: 200 })
    }) as typeof fetch

    try {
      async function* events() {
        yield { type: "session.execution.started", properties: { sessionID: "session-1" } }
      }

      const cleanup = await activitywatch.setup({
        options: { server: "http://activitywatch.test", bucket: "test-bucket" },
        location: { directory: "/tmp/demo", project: { id: "project-1" } },
        event: { subscribe: () => events() },
        session: {
          get: async () => ({ id: "session-1", projectID: "project-1", location: { directory: "/tmp/demo" } }),
        },
      })
      await waitFor(() => heartbeats.length === 1)
      await cleanup?.()
      expect(heartbeats[0].data.path).toBe("/tmp/demo")
    } finally {
      globalThis.fetch = originalFetch
    }
  })
})
