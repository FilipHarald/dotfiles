return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          -- Enable schema validation and autocomplete
          settings = {
            json = {
              schemas = {
                -- Schema validation will automatically work for files with $schema field
                -- No need to manually specify schemas here
              },
              validate = { enable = true },
              -- Support JSONC (JSON with comments)
              format = {
                enable = true,
              },
            },
          },
          -- Ensure JSONC files are handled
          filetypes = { "json", "jsonc" },
        },
      },
    },
  },
}
