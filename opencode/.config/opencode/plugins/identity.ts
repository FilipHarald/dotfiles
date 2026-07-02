import type { Plugin } from "@opencode-ai/plugin"

const seen = new Set<string>()

export default (async ({ $ }) => {
  return {
    "experimental.chat.system.transform": async (input, output) => {
      const key = input.sessionID ?? "global"
      if (seen.has(key)) return
      seen.add(key)

      const whoami = await $`whoami`.text()
      const hostname = await $`hostname`.text()

      output.system.push(
        [
          "Local machine identity for this session:",
          `whoami: ${whoami.trim()}`,
          `hostname: ${hostname.trim()}`,
        ].join("\n"),
      )
    },
  }
}) satisfies Plugin
