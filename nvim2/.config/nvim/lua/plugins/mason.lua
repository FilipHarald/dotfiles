return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Language Servers (most are auto-installed by LazyVim lang extras)
        "ansible-language-server",
        "ansible-lint",
        "copilot-language-server",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "eslint-lsp",
        "jinja-lsp",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "nomicfoundation-solidity-language-server",
        "typescript-language-server",
        "vtsls",
        "yaml-language-server",

        -- Formatters
        "shfmt",
        "stylua",

        -- Linters
        "hadolint",
        "markdownlint-cli2",
        "solhint",

        -- Tools
        "markdown-toc",
      },
    },
  },
}
