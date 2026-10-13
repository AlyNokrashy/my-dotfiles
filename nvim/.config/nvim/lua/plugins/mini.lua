local miniclue = require 'mini.clue'
local miniAi = require 'mini.ai'
local miniSurround = require 'mini.surround'
local miniPairs = require 'mini.pairs'
local miniIcons = require 'mini.icons'
local miniStatusline = require 'mini.statusline'
local miniNotify = require 'mini.notify'
local miniCmd = require 'mini.cmdline'
local miniJump = require 'mini.jump2d'
local starter = require 'mini.starter'
local files = require 'mini.files'
local map = vim.keymap.set
local minifiles_toggle = function(...)
  if MiniFiles.close() == nil then MiniFiles.open(...) end
end

miniIcons.setup()
miniSurround.setup()
miniPairs.setup()
miniCmd.setup()

files.setup {
  -- vim.keymap.set('n', '-',function() MiniFiles.open() end, { desc = 'Open MiniFiles' }),
  vim.keymap.set('n', '-', minifiles_toggle , { desc = 'Toggle MiniFiles' }),
}

-- Mini.Starter
starter.setup {
  header = 'Sunrise Parabellum',
  evaluate_single = true,
}

-- Mini.Notify
miniNotify.setup {
  lsp_progress = {
    enable = false,
  },
}

-- Mini.jump2d
miniJump.setup()
map('n', 'S', function() MiniJump2d.start() end, { desc = 'Jump to Word' })
map('n', 's', function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end, { desc = 'Jump to Character' })

-- Mini.ai
miniAi.setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Mini.clue
miniclue.setup {
  window = {
    delay = 200,
  },
  triggers = {
    -- Leader triggers
    { mode = { 'n', 'x' }, keys = '<Leader>' },

    -- `[` and `]` keys
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = { 'n', 'x' }, keys = 'g' },

    -- Marks
    { mode = { 'n', 'x' }, keys = "'" },
    { mode = { 'n', 'x' }, keys = '`' },

    -- Registers
    { mode = { 'n', 'x' }, keys = '"' },
    { mode = { 'i', 'c' }, keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = { 'n', 'x' }, keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

-- Mini-statusline
miniStatusline.setup { use_icons = true }

---@diagnostic disable-next-line: duplicate-set-field
miniStatusline.section_location = function() return '%2l:%-2v' end
