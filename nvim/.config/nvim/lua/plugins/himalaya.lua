return {
  "knownasnaffy/himalaya.nvim",
  dir = vim.fn.expand("~/c/himalaya.nvim"),
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    icons_enabled = true,
    wrap_folder_navigation = true,
  },
  keys = {
    { "<leader>oh", "<cmd>Himalaya<cr>", desc = "Open Himalaya" },
  },
}
