-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Keymaps
vim.keymap.set('n', '<leader>air', function()
  vim.fn.setreg('+', '')
  vim.notify("Clipboard cleared!")
end, { noremap = true })

vim.keymap.set('n', '<leader>ain', function()
  vim.fn.setreg('+', vim.fn.getreg('+') .. '\n' .. vim.fn.expand('%:p'))
  vim.notify("Filename appended to clipboard!")
end, { noremap = true })
