/** @jsxImportSource @opentui/solid */
import type { TuiDialogSelectOption, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { createMemo, createResource, createSignal, For, onMount, Show } from "solid-js"
import fs from "node:fs/promises"
import { readFileSync } from "node:fs"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

type Api = any

type Config = {
  enabled?: boolean
  startupPanel?: {
    enabled?: boolean
  }
}

type Inventory = {
  agents: any[]
  skills: any[]
  commands: any[]
  formatters: any[]
  mcp: Record<string, any>
  plugins: any[]
  errors: string[]
}

const __dirname = dirname(fileURLToPath(import.meta.url))
const title = (name: string, count: number) => `${name} (${count})`
const home = () => process.env.HOME ?? ""

const stripJsonComments = (value: string) => value.replace(/\/\/.*$/gm, "").replace(/\/\*[\s\S]*?\*\//g, "")

const loadConfig = (): Config => {
  const paths = [join(home(), ".config", "opencode", "plugins", "inventory.jsonc"), join(__dirname, "inventory.jsonc")]
  for (const path of paths) {
    try {
      return JSON.parse(stripJsonComments(readFileSync(path, "utf8")))
    } catch {
      // Try the next config location.
    }
  }
  return {}
}

const shortPath = (value: string | undefined) => {
  if (!value) return undefined
  const file = value.startsWith("file://") ? value.replace("file://", "") : value
  return home() && file.startsWith(home()) ? `~${file.slice(home().length)}` : file
}

const cut = (value: string | undefined, max = 140) => {
  const text = value?.replace(/\s+/g, " ").trim()
  if (!text) return undefined
  if (text.length <= max) return text
  return `${text.slice(0, max - 1)}…`
}

const describe = (...parts: (string | undefined)[]) => cut(parts.filter(Boolean).join(" - "))

const logError = async (message: string) => {
  await fs.appendFile(`${home()}/.config/opencode/inventory-plugin.log`, `${new Date().toISOString()} ${message}\n`).catch(() => {})
}

const safe = async <T,>(name: string, fallback: T, run: () => Promise<T>, errors: string[]) => {
  let timeout: ReturnType<typeof setTimeout> | undefined
  try {
    return await Promise.race([
      Promise.resolve().then(run),
      new Promise<T>((_, reject) => {
        timeout = setTimeout(() => reject(new Error("timed out after 2500ms")), 2500)
      }),
    ])
  } catch (err) {
    const message = `${name}: ${err instanceof Error ? err.message : String(err)}`
    errors.push(message)
    void logError(message)
    return fallback
  } finally {
    if (timeout) clearTimeout(timeout)
  }
}

const sourceKey = (value: string | undefined) => {
  const file = shortPath(value)
  if (!file) return undefined
  const normalized = file.replace(/\/[^/]+$/, "")
  return normalized || file
}

const skillSourceKey = (value: string | undefined) => {
  const dir = sourceKey(value)
  if (!dir) return undefined
  const parent = dir.replace(/\/[^/]+$/, "")
  return parent || dir
}

const loadInventory = async (api: Api): Promise<Inventory> => {
  const errors: string[] = []
  const [agents, skills, commands, formatters, mcp] = await Promise.all([
    safe("agents", [], () => api.client.app.agents().then((x: any) => x.data ?? []), errors),
    safe("skills", [], () => api.client.app.skills().then((x: any) => x.data ?? []), errors),
    safe("commands", [], () => api.client.command.list().then((x: any) => x.data ?? []), errors),
    safe("formatters", [], () => api.client.formatter.status().then((x: any) => x.data ?? []), errors),
    safe("mcp", {}, () => api.client.mcp.status().then((x: any) => x.data ?? {}), errors),
  ])

  return {
    agents,
    skills,
    commands,
    formatters,
    mcp,
    plugins: await safe("plugins", [], () => Promise.resolve(api.plugins.list()), errors),
    errors,
  }
}

const parts = (api: Api, inventory: Inventory) => {
  const agents = inventory.agents.toSorted((a, b) => a.name.localeCompare(b.name))
  const skills = inventory.skills.toSorted((a, b) => a.name.localeCompare(b.name))
  const commands = inventory.commands.toSorted((a, b) => a.name.localeCompare(b.name))
  const mcp = Object.entries(inventory.mcp).toSorted(([a], [b]) => a.localeCompare(b))
  const lsp = api.state.lsp().toSorted((a: any, b: any) => a.id.localeCompare(b.id))
  const formatters = inventory.formatters.toSorted((a, b) => a.name.localeCompare(b.name))
  const plugins = inventory.plugins.toSorted((a, b) => a.id.localeCompare(b.id))
  const providers = api.state.provider.toSorted((a: any, b: any) => a.id.localeCompare(b.id))
  const sources = [
    ...skills.map((skill) => ({ name: skillSourceKey(skill.location), kind: "skills" })),
    ...plugins
      .filter((plugin) => plugin.active)
      .map((plugin) => ({ name: shortPath(plugin.target || plugin.spec), kind: `tui plugin - ${plugin.id}` })),
  ]
    .filter((item): item is { name: string; kind: string } => !!item.name)
    .filter((item, index, list) => list.findIndex((other) => other.name === item.name && other.kind === item.kind) === index)
    .toSorted((a, b) => a.name.localeCompare(b.name))

  return { agents, skills, commands, mcp, lsp, formatters, plugins, providers, sources }
}

const options = (api: Api, inventory: Inventory): TuiDialogSelectOption<string>[] => {
  const data = parts(api, inventory)
  return [
    ...inventory.errors.map((error) => ({
      title: error,
      value: `error:${error}`,
      category: title("Errors", inventory.errors.length),
      description: "also written to ~/.config/opencode/inventory-plugin.log",
    })),
    ...data.sources.map((source) => ({
      title: source.name,
      value: `source:${source.kind}:${source.name}`,
      category: title("Sources", data.sources.length),
      description: source.kind,
    })),
    ...[
      ["Agents", data.agents.length],
      ["Skills", data.skills.length],
      ["Tools", "not exposed"],
      ["Commands", data.commands.length],
      ["MCP", data.mcp.length],
      ["LSP", data.lsp.length],
      ["Formatters", data.formatters.length],
      ["TUI Plugins", data.plugins.length],
      ["Providers", data.providers.length],
    ].map(([name, count]) => ({
      title: `${name}: ${count}`,
      value: `summary:${name}`,
      category: "Summary",
      description: name === "Tools" ? "plugin API does not expose the backend tool registry" : undefined,
    })),
    ...data.agents.map((agent) => ({
      title: agent.name,
      value: `agent:${agent.name}`,
      category: title("Agents", data.agents.length),
      description: describe(
        agent.mode,
        agent.native ? "native" : "configured",
        agent.hidden ? "hidden" : undefined,
        agent.description,
      ),
    })),
    ...data.skills.map((skill) => ({
      title: skill.name,
      value: `skill:${skill.name}`,
      category: title("Skills", data.skills.length),
      description: describe(shortPath(skill.location), skill.description),
    })),
    ...data.commands.map((command) => ({
      title: command.name,
      value: `command:${command.name}`,
      category: title("Commands", data.commands.length),
      description: describe(command.source ?? "command", command.description),
    })),
    {
      title: "Tool registry",
      value: "tools:unavailable",
      category: "Tools",
      description: "not exposed by the plugin API - backend /tool or /inventory endpoint needed",
    },
    ...data.providers.map((provider) => ({
      title: provider.name,
      value: `provider:${provider.id}`,
      category: title("Providers", data.providers.length),
      description: describe(provider.id, `${Object.keys(provider.models).length} models`),
    })),
    ...data.mcp.map(([name, status]) => ({
      title: name,
      value: `mcp:${name}`,
      category: title("MCP", data.mcp.length),
      description: describe(
        status.status,
        status.status === "failed" || status.status === "needs_client_registration" ? status.error : undefined,
      ),
    })),
    ...data.lsp.map((item) => ({
      title: item.id,
      value: `lsp:${item.id}:${item.root}`,
      category: title("LSP", data.lsp.length),
      description: describe(item.status, shortPath(item.root)),
    })),
    ...data.formatters.map((formatter) => ({
      title: formatter.name,
      value: `formatter:${formatter.name}`,
      category: title("Formatters", data.formatters.length),
      description: describe(formatter.enabled ? "enabled" : "disabled", formatter.extensions.join(", ")),
    })),
    ...data.plugins.map((plugin) => ({
      title: plugin.id,
      value: `plugin:${plugin.id}`,
      category: title("TUI Plugins", data.plugins.length),
      description: describe(
        plugin.source,
        plugin.enabled ? "enabled" : "disabled",
        plugin.active ? "active" : "inactive",
        shortPath(plugin.target || plugin.spec),
      ),
    })),
  ]
}

async function show(api: Api) {
  api.ui.toast({ message: "Loading inventory...", duration: 1000 })
  try {
    const inventory = await loadInventory(api)
    api.ui.dialog.replace(() =>
      api.ui.DialogSelect({
        title: "Inventory",
        placeholder: "Search inventory...",
        options: options(api, inventory),
      }),
    )
    api.ui.dialog.setSize("xlarge")
  } catch (err) {
    api.ui.toast({ variant: "error", message: err instanceof Error ? err.message : String(err) })
  }
}

function InventoryPanel(props: { api: Api }) {
  const [inventory] = createResource(() => loadInventory(props.api))
  const data = createMemo(() => inventory() && parts(props.api, inventory()!))
  const [timedOut, setTimedOut] = createSignal(false)
  const theme = () => props.api.theme.current

  onMount(() => {
    const timeout = setTimeout(() => {
      if (inventory()) return
      setTimedOut(true)
      void logError("startup panel: inventory did not finish after 3000ms")
    }, 3000)
    return () => clearTimeout(timeout)
  })

  return (
    <box
      width="100%"
      maxWidth={75}
      marginTop={1}
      paddingTop={1}
      paddingBottom={1}
      paddingLeft={2}
      paddingRight={2}
      gap={1}
      flexShrink={0}
      backgroundColor={theme().backgroundPanel}
    >
      <text fg={theme().textMuted}>Search for command 'Inventory' for more detailed information</text>
      <box flexDirection="row" gap={4}>
        <box flexGrow={1} minWidth={0}>
          <text fg={theme().success}>Sources ({data()?.sources.length ?? "loading"})</text>
          <Show when={data()} fallback={<text fg={theme().textMuted}>{timedOut() ? "Timed out loading sources" : "Loading sources..."}</text>}>
            {(current) => (
              <>
                <For each={current().sources.slice(0, 5)}>
                  {(source) => <text fg={theme().textMuted}>{source.name}</text>}
                </For>
                <Show when={current().sources.length > 5}>
                  <text fg={theme().textMuted}>+{current().sources.length - 5} more</text>
                </Show>
              </>
            )}
          </Show>
        </box>
        <box flexGrow={1} minWidth={0}>
          <text fg={theme().success}>Summary</text>
          <Show when={timedOut() && !inventory()}>
            <text fg={theme().error}>Inventory fetch timed out</text>
          </Show>
          <Show when={inventory()?.errors.length}>
            <text fg={theme().error}>Errors: {inventory()?.errors.length}</text>
          </Show>
          <text fg={theme().textMuted}>Agents: {data()?.agents.length ?? "loading"}</text>
          <text fg={theme().textMuted}>Skills: {data()?.skills.length ?? "loading"}</text>
          <text fg={theme().textMuted}>Tools: not exposed</text>
          <text fg={theme().textMuted}>Commands: {data()?.commands.length ?? "loading"}</text>
          <text fg={theme().textMuted}>MCP: {data()?.mcp.length ?? props.api.state.mcp().length}</text>
          <text fg={theme().textMuted}>LSP: {data()?.lsp.length ?? props.api.state.lsp().length}</text>
          <text fg={theme().textMuted}>TUI Plugins: {data()?.plugins.length ?? props.api.plugins.list().length}</text>
        </box>
      </box>
    </box>
  )
}

const tui = async (api: Api) => {
  const config = loadConfig()
  if (config.enabled === false) return

  api.keymap.registerLayer({
    commands: [
      {
        name: "inventory.open",
        title: "Inventory",
        category: "System",
        namespace: "palette",
        desc: "Show agents, skills, commands, MCPs, LSPs, formatters, and TUI plugins",
        run() {
          void show(api)
        },
      },
    ],
    bindings: api.tuiConfig.keybinds.get("inventory.open"),
  })

  if (config.startupPanel?.enabled === false) return

  api.slots.register({
    order: 110,
    slots: {
      home_bottom() {
        return <InventoryPanel api={api} />
      },
    },
  })
}

const plugin: TuiPluginModule & { id: string } = {
  id: "global.inventory",
  tui,
}

export default plugin
