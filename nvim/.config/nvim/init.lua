vim.loader.enable()

require('vim._core.ui2').enable {}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.plugins'

require 'plugins.oil'
require 'plugins.gitsigns'
require 'plugins.which_key'
require 'plugins.treesitter'
require 'plugins.luasnip'
require 'plugins.conform'
require 'plugins.blink'
require 'plugins.md_render'
require 'plugins.flash'
require 'plugins.todo_comments'
require 'plugins.colorscheme'
require 'plugins.guess_indent'
require 'plugins.devicons'
require 'plugins.lsp'
require 'plugins.mini'
require 'plugins.telescope'
require 'plugins.friendly_snippets'
require 'plugins.snacks'
require 'plugins.highlight_colors'

-- vim: ts=2 sts=2 sw=2 et
