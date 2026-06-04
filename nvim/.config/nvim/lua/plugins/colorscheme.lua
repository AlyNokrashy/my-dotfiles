vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
vim.pack.add { 'https://github.com/sainnhe/gruvbox-material' }
vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }

---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  styles = {
    comments = { italic = false },
  },
}

vim.cmd.colorscheme 'catppuccin'
