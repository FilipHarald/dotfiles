return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        enabled = "snacks",
        -- snacks = {
        --   -- ...
        -- }
      }
    }

    vim.o.autoread = true
    vim.keymap.set({ "n", "x" }, "<leader>coa", function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>cox", function() require("opencode").select() end,
      { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>cor", function() return require("opencode").operator("@this ") end,
      { expr = true, desc = "Add range to opencode" })
    vim.keymap.set("n", "<leader>col", function() return require("opencode").operator("@this ") .. "_" end,
      { expr = true, desc = "Add line to opencode" })

    -- vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
    --   { desc = "opencode half page up" })
    -- vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
    --   { desc = "opencode half page down" })
  end,
}
