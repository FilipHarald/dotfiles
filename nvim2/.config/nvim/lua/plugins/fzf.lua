return {
  "ibhagwan/fzf-lua",
  opts = {
    fzf_opts = {
      ["--no-scrollbar"] = true,
      ["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
    },
    winopts = {
      width = 0.9,
      height = 0.9,
      row = 0.5,
      col = 0.5,
      preview = {
        scrollchars = { "┃", "" },
      },
    },
  },
}
