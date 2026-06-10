vim.pack.add { 'https://github.com/stevearc/oil.nvim', 'https://github.com/nvim-mini/mini.icons' }
require('mini.icons').setup()
require('oil').setup {}

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })
