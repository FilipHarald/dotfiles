/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui"
import type { Context, DialogSelectOption } from "@opencode/plugin/tui/context"
import { createResource, Show } from "solid-js"

type Named = {
  id?: string
  name?: string
  title?: string
  description?: string
  status?: string
  source?: string
  active?: boolean
  providerID?: string
}

type Inventory = {
  agents: Named[]
  skills: Named[]
  commands: Named[]
  integrations: Named[]
  models: Named[]
  providers: Named[]
  references: Named[]
  mcp: Named[]
  resources: Named[]
  plugins: Named[]
  errors: string[]
}

const title = (name: string, count: number) => `${name} (${count})`
const itemName = (item: Named) => item.name ?? item.title ?? item.id ?? "unknown"
const itemDescription = (item: Named) =>
  [item.description, item.status, item.source, item.active === undefined ? undefined : item.active ? "active" : "inactive", item.providerID]
    .filter(Boolean)
    .join(" · ") || undefined

const loadInventory = async (context: Context): Promise<Inventory> => {
  const location = context.location ?? context.data.location.default()
  const errors: string[] = []
  const timeoutMs = (context.options as { timeoutMs?: number }).timeoutMs ?? 2500
  const bounded = async <T,>(name: string, fallback: T, run: () => Promise<T>): Promise<T> => {
    let timer: ReturnType<typeof setTimeout> | undefined
    try {
      return await Promise.race([
        run(),
        new Promise<T>((_, reject) => {
          timer = setTimeout(() => reject(new Error(`timed out after ${timeoutMs}ms`)), timeoutMs)
        }),
      ])
    } catch (error) {
      errors.push(`${name}: ${error instanceof Error ? error.message : String(error)}`)
      return fallback
    } finally {
      if (timer) clearTimeout(timer)
    }
  }
  const sources = [
    ["agents", context.data.location.agent],
    ["skills", context.data.location.skill],
    ["commands", context.data.location.command],
    ["integrations", context.data.location.integration],
    ["models", context.data.location.model],
    ["providers", context.data.location.provider],
    ["references", context.data.location.reference],
    ["mcp", context.data.location.mcp.server],
    ["resources", context.data.location.mcp.resource],
  ] as const

  await Promise.all(sources.map(([name, source]) => bounded(name, undefined, () => source.sync(location))))

  const plugins = await bounded("plugins", [] as Named[], async () => {
    const response = await context.client.plugin.list({ location })
    return (response.data ?? []) as unknown as Named[]
  })

  const values = Object.fromEntries(sources.map(([name, source]) => [name, (source.list(location) ?? []) as Named[]])) as Omit<
    Inventory,
    "plugins" | "errors"
  >
  return { ...values, plugins, errors }
}

const inventoryOptions = (inventory: Inventory): DialogSelectOption<string>[] => {
  const groups = [
    ["Agents", inventory.agents],
    ["Skills", inventory.skills],
    ["Commands", inventory.commands],
    ["Integrations", inventory.integrations],
    ["Models", inventory.models],
    ["Providers", inventory.providers],
    ["References", inventory.references],
    ["MCP servers", inventory.mcp],
    ["MCP resources", inventory.resources],
    ["Plugins", inventory.plugins],
  ] as const

  return [
    ...inventory.errors.map((error) => ({ title: error, value: `error:${error}`, category: title("Errors", inventory.errors.length) })),
    ...groups.map(([name, items]) => ({ title: `${name}: ${items.length}`, value: `summary:${name}`, category: "Summary" })),
    ...groups.flatMap(([name, items]) =>
      items
        .toSorted((a, b) => itemName(a).localeCompare(itemName(b)))
        .map((item) => ({
          title: itemName(item),
          value: `${name}:${itemName(item)}`,
          category: title(name, items.length),
          description: itemDescription(item),
        })),
    ),
  ]
}

const showInventory = async (context: Context) => {
  context.ui.toast.show({ message: "Loading inventory…", duration: 1000 })
  const inventory = await loadInventory(context)
  await context.ui.dialog.select({
    title: "Inventory",
    placeholder: "Search agents, skills, models, MCP servers, and plugins…",
    options: inventoryOptions(inventory),
  })
}

function InventoryCommands(props: { context: Context }) {
  props.context.keymap.layer(() => ({
    mode: "global",
    commands: [
      {
        id: "inventory.open",
        title: "Inventory",
        description: "Show agents, skills, commands, MCP servers, models, providers, and plugins",
        group: "System",
        palette: true,
        slash: { name: "inventory" },
        run: () => showInventory(props.context),
      },
    ],
  }))
  return null
}

function InventorySummary(props: { context: Context }) {
  const [inventory] = createResource(() => loadInventory(props.context))
  return (
    <box flexDirection="column" paddingLeft={2} paddingRight={2} marginTop={1}>
      <text>Inventory</text>
      <Show when={inventory()} fallback={<text>Loading agents, skills, MCP servers, and plugins…</text>}>
        {(current) => (
          <text>
            Agents {current().agents.length} · Skills {current().skills.length} · MCP {current().mcp.length} · Plugins {current().plugins.length}
          </text>
        )}
      </Show>
    </box>
  )
}

export default Plugin.define({
  id: "local.inventory",
  setup(context) {
    if (context.options.enabled === false) return

    const cleanupCommands = context.ui.slot({
      append: "app",
      render: () => <InventoryCommands context={context} />,
    })

    if (context.options.startupPanel?.enabled === false) return cleanupCommands

    const cleanupSummary = context.ui.slot({
      append: "home.footer",
      render: () => <InventorySummary context={context} />,
    })

    return () => {
      cleanupCommands()
      cleanupSummary()
    }
  },
})
