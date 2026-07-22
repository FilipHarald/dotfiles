return {
  "kitlangton/navi.nvim",
  cmd = { "NaviLoad", "NaviNext", "NaviPrev", "NaviPick", "NaviClear", "NaviTest" },
  keys = {
    { "<Tab>", "<Cmd>NaviNext<CR>", desc = "Next Navi stop" },
    { "<S-Tab>", "<Cmd>NaviPrev<CR>", desc = "Previous Navi stop" },
    { "<leader>np", "<Cmd>NaviPick<CR>", desc = "Pick Navi stop" },
    { "<leader>nc", "<Cmd>NaviClear<CR>", desc = "Clear Navi tour" },
  },
}