return {
  "folke/sidekick.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
  config = function(_, opts)
    require("sidekick").setup(opts)

    vim.schedule(function()
      vim.lsp.inline_completion.enable(false)
      vim.g.sidekick_nes = false

      Snacks.toggle({
        name = "NES and inline_completion",
        get = function()
          return vim.g.sidekick_nes ~= false
        end,
        set = function(state)
          vim.g.sidekick_nes = state
          vim.lsp.inline_completion.enable(state)
        end,
      }):map("<leader>uN")
    end)
  end,
  keys = {
    {
      "<tab>",
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>" -- fallback to normal tab
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
  },
}
