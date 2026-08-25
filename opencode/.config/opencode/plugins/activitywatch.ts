import type { Plugin } from "@opencode-ai/plugin"
import type { Event } from "@opencode-ai/sdk"

type Options = {
  server?: string
  bucket?: string
  pulsetime?: number
  enabled?: boolean
}

const interestingEvents = new Set([
  "session.created",
  "session.updated",
  "session.idle",
  "session.compacted",
  "session.error",
  "message.updated",
  "message.part.updated",
  "command.executed",
  "file.edited",
  "permission.updated",
  "permission.replied",
  "todo.updated",
])

function eventProperties(event: Event): Record<string, any> {
  return (event as any).properties ?? {}
}

function sessionID(event: Event): string | undefined {
  const props = eventProperties(event)
  return props.sessionID ?? props.info?.sessionID ?? props.info?.id ?? props.part?.sessionID
}

function sessionTitle(event: Event): string | undefined {
  const props = eventProperties(event)
  return props.info?.title
}

function compactData(value: Record<string, any>) {
  return Object.fromEntries(Object.entries(value).filter(([, entry]) => entry !== undefined && entry !== null && entry !== ""))
}

function basename(path: string) {
  return path.replace(/\/+$/, "").split("/").pop() || path
}

const ActivityWatchPlugin: Plugin = async ({ project, directory, worktree }, rawOptions) => {
  const options = rawOptions as Options | undefined
  if (options?.enabled === false) return {}

  let host = "unknown"
  const server = options?.server ?? "http://127.0.0.1:5600"
  const pulsetime = options?.pulsetime ?? 60
  let bucketReady = false
  const titles = new Map<string, string>()

  async function resolveHost() {
    if (host !== "unknown") return

    const response = await fetch(`${server}/api/0/info`).catch(() => undefined)
    const info = response?.ok ? await response.json().catch(() => undefined) : undefined
    host = info?.hostname ?? (globalThis as any).process?.env?.HOSTNAME ?? "unknown"
  }

  function bucketName() {
    return options?.bucket ?? `aw-watcher-opencode_${host}`
  }

  async function ensureBucket() {
    if (bucketReady) return

    await resolveHost()

    const response = await fetch(`${server}/api/0/buckets/${encodeURIComponent(bucketName())}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        client: "opencode-local-plugin",
        hostname: host,
        type: "app.editor.activity",
      }),
    }).catch(() => undefined)

    bucketReady = response?.ok === true || response?.status === 304
  }

  async function heartbeat(event: Event) {
    if (!interestingEvents.has(event.type)) return

    const id = sessionID(event)
    const title = sessionTitle(event)
    if (id && title) titles.set(id, title)

    await ensureBucket()
    if (!bucketReady) return

    await fetch(`${server}/api/0/buckets/${encodeURIComponent(bucketName())}/heartbeat?pulsetime=${pulsetime}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        timestamp: new Date().toISOString(),
        duration: 0,
        data: compactData({
          app: "opencode",
          title: id ? titles.get(id) ?? `opencode: ${basename(directory)}` : `opencode: ${basename(directory)}`,
          file: directory,
          project_id: project.id,
          directory,
          worktree,
          session_id: id,
        }),
      }),
    }).catch(() => {})
  }

  return {
    event: async ({ event }) => {
      await heartbeat(event)
    },
  }
}

export default ActivityWatchPlugin
