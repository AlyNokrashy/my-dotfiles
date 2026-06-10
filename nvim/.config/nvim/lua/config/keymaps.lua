-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
local map = vim.keymap.set

map({ 'n', 'x' }, 'gy', '"+y', { desc = 'Copy to system clipboard' })
map('n', 'gp', '"+p', { desc = 'Paste from system clipboard' })
-- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
map('x', 'gp', '"+P', { desc = 'Paste in Visual without copying selected text' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<C-c>', '<cmd>nohlsearch<CR>')
map('i', '<C-c>', '<Esc>')
-- move selected lines
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'moves lines down in visual selection' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'moves lines up in visual selection' })
-- center cursor while searching
map('n', 'n', 'nzzzv', { desc = 'Next search result cursor centered' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search result cursor centered' })

map('v', '<', '<gv', { desc = 'Unindent and keep selection' })
map('v', '>', '>gv', { desc = 'Indent and keep selection' })

map('n', 'J', 'mzJ`z', { desc = 'Join lines without moving cursor' })
map('n', '<leader>re', '<cmd>restart<cr>', { desc = 'Restart' })
map('n', '<space>st', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.api.nvim_win_set_height(0, 10)
end, { desc = 'Open Terminal' })

map('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- native undotree
map('n', '<leader>u', function()
  vim.cmd.packadd 'nvim.undotree'
  require('undotree').open()
end, { desc = 'Toggle Undotree' })

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open Quickfix list' })

map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Move up half page and center the cursor' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Move up half page and center the cursor' })

map('n', 'g0', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { desc = 'Put empty line above' })
map('n', 'go', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", { desc = 'Put empty line below' })
map('n', '<C-Left>', '"<Cmd>vertical resize -" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
map('n', '<C-Down>', '"<Cmd>resize -"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
map('n', '<C-Up>', '"<Cmd>resize +"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window height' })
map('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window width' })
-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
