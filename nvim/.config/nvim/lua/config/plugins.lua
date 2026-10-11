--    :lua vim.pack.update(nil, { offline = true })
--    :lua vim.pack.update()
vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }
vim.pack.add { { src = 'https://github.com/folke/snacks.nvim' } }
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }
vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
vim.pack.add { 'https://github.com/sainnhe/gruvbox-material' }
vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }
vim.pack.add { { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' } }
vim.pack.add { 'https://github.com/stevearc/conform.nvim' }
vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }
vim.pack.add { 'https://github.com/rafamadriz/friendly-snippets' }
vim.pack.add { 'https://github.com/NMAC427/guess-indent.nvim' }
vim.pack.add { 'https://github.com/brenoprata10/nvim-highlight-colors' }
vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}
vim.pack.add {
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}
vim.pack.add { { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
vim.pack.add { 'https://github.com/folke/todo-comments.nvim' }
vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }
vim.pack.add {'https://github.com/RRethy/base16-nvim'}
