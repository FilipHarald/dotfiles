type Options = {
  server?: string
  bucket?: string
  pulsetime?: number
  enabled?: boolean
}

type ActivityEvent = {
  type: string
  properties?: {
    sessionID?: string
    title?: string
    info?: { id?: string; title?: string }
    [key: string]: unknown
  }
  data?: {
    sessionID?: string
    title?: string
    info?: { id?: string; title?: string }
    [key: string]: unknown
  }
}

type Context = {
  options: Options
  location: {
    directory: string
    project?: { id?: string }
  }
  event: {
    subscribe(input?: { signal?: AbortSignal }): AsyncIterable<unknown>
  }
}

const INTERESTING_EVENTS = new Set([
  "session.created",
  "session.renamed",
  "session.deleted",
  "session.status",
  "session.idle",
  "session.error",
  "session.compacted",
  "session.execution.started",
  "session.execution.succeeded",
  "session.execution.failed",
  "session.execution.interrupted",
  "permission.asked",
  "permission.replied",
  "file.edited",
  "command.executed",
])

const details = (event: ActivityEvent) => event.properties ?? event.data ?? {}

const plugin = {
  id: "local.activitywatch",
  setup(context: Context) {
    const options = context.options ?? {}
    if (options.enabled === false) return

    const server = (options.server ?? "http://127.0.0.1:5600").replace(/\/$/, "")
    const pulsetime = options.pulsetime ?? 30
    const directory = context.location.directory
    const project = context.location.project?.id ?? directory.split("/").filter(Boolean).at(-1) ?? "unknown"
    const sessionTitles = new Map<string, string>()
    const abort = new AbortController()
    let bucketReady: Promise<string> | undefined

    const request = async (path: string, init?: RequestInit) => {
      try {
        const signals = [abort.signal, AbortSignal.timeout(5000)]
        if (init?.signal) signals.push(init.signal)
        const response = await fetch(`${server}${path}`, { ...init, signal: AbortSignal.any(signals) })
        if (!response.ok && response.status !== 304) throw new Error(`ActivityWatch request failed: ${response.status}`)
        return response
      } catch {
        return undefined
      }
    }

    const ensureBucket = async () => {
      const info = await request("/api/0/info")
      const payload = (await info?.json().catch(() => undefined)) as { hostname?: string } | undefined
      const runtimeHost = (globalThis as typeof globalThis & { process?: { env?: Record<string, string | undefined> } }).process?.env?.HOSTNAME
      const host = payload?.hostname ?? runtimeHost ?? "unknown"
      const bucket = options.bucket ?? `aw-watcher-opencode_${host}`
      const response = await request(`/api/0/buckets/${encodeURIComponent(bucket)}`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          id: bucket,
          type: "app.editor.activity",
          client: "opencode",
          hostname: host,
        }),
      })
      if (!response) throw new Error("ActivityWatch bucket creation failed")
      return bucket
    }

    const heartbeat = async (event: ActivityEvent) => {
      if (!INTERESTING_EVENTS.has(event.type)) return

      const payload = details(event)
      const info = payload.info
      const sessionID = payload.sessionID ?? info?.id
      const nextTitle = payload.title ?? info?.title
      if (sessionID && nextTitle) sessionTitles.set(sessionID, nextTitle)

      const deleted = event.type === "session.deleted" && Boolean(sessionID)
      try {
        bucketReady ??= ensureBucket()
        const bucket = await bucketReady
        const title = (sessionID && sessionTitles.get(sessionID)) ?? `opencode: ${project}`
        await request(`/api/0/buckets/${encodeURIComponent(bucket)}/heartbeat?pulsetime=${pulsetime}`, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            timestamp: new Date().toISOString(),
            duration: 0,
            data: {
              app: "opencode",
              title,
              path: directory,
              project,
              sessionID,
              event: event.type,
            },
          }),
        })
      } catch {
        bucketReady = undefined
      } finally {
        if (deleted && sessionID) sessionTitles.delete(sessionID)
      }
    }

    const retryDelay = () =>
      new Promise<void>((resolve) => {
        const stop = () => {
          clearTimeout(timer)
          resolve()
        }
        const timer = setTimeout(() => {
          abort.signal.removeEventListener("abort", stop)
          resolve()
        }, 50)
        abort.signal.addEventListener("abort", stop, { once: true })
      })

    const worker = (async () => {
      while (!abort.signal.aborted) {
        try {
          for await (const event of context.event.subscribe({ signal: abort.signal })) {
            if (abort.signal.aborted) break
            await heartbeat(event as ActivityEvent)
          }
        } catch {
          // Event streams can close during a server restart; reconnect below.
        }
        if (!abort.signal.aborted) await retryDelay()
      }
    })()

    return async () => {
      abort.abort()
      await worker
    }
  },
}

export default plugin
