local snacks = require('snacks')

snacks.setup {
  picker = { enabled = true },
}

local picker = snacks.picker

vim.keymap.set('n', '<leader>fh', function() picker.help() end, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>fk', function() picker.keymaps() end, { desc = 'Find Keymaps' })
vim.keymap.set('n', '<leader>ff', function() picker.smart() end, { desc = 'Find Files' })
vim.keymap.set({ 'n', 'v' }, '<leader>fw', function() picker.grep_word() end, { desc = 'Find Word' })
vim.keymap.set('n', '<leader>fg', function() picker.grep() end, { desc = 'Grep' })
vim.keymap.set('n', '<leader>fd', function() picker.diagnostics() end, { desc = 'Find Diagnostics' })
vim.keymap.set('n', '<leader>fr', function() picker.resume() end, { desc = 'Resume Find' })
vim.keymap.set('n', '<leader>f.', function() picker.recent() end, { desc = 'Find Recent Files' })
vim.keymap.set('n', '<leader>fc', function() picker.commands() end, { desc = 'Find Commands' })
vim.keymap.set('n', '<leader><leader>', function() picker.buffers() end, { desc = 'Find Existing Buf' })
vim.keymap.set('n', '<leader>fa', function() picker.files { hidden = true, ignored = true } end, { desc = 'Find Files [a/h]' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', function() picker.lsp_references() end, { buffer = buf, desc = 'Goto Reference' })

    vim.keymap.set('n', 'gri', function() picker.lsp_implementations() end, { buffer = buf, desc = 'Goto Implementation' })

    vim.keymap.set('n', 'grd', function() picker.lsp_definitions() end, { buffer = buf, desc = 'Goto Definition' })

    vim.keymap.set('n', 'gO', function() picker.lsp_symbols() end, { buffer = buf, desc = 'Open Document Symbols' })

    vim.keymap.set('n', 'gW', function() picker.lsp_workspace_symbols() end, { buffer = buf, desc = 'Open Workspace Symbols' })

    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = buf, desc = 'Rename Symbol' })

    vim.keymap.set('n', 'grt', function() picker.lsp_type_definitions() end, { buffer = buf, desc = 'Goto Type Definition' })
  end,
})

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    picker.lines {
      layout = {
          preset = 'dropdown',
          row = 4,
          width = 0.30,
          height = 0.50,
      },
    }
  end,
  { desc = 'Find in Current Buf' }
)

vim.keymap.set('n', '<leader>f/', function()
  picker.grep_buffers {
    title = 'Live Grep in Open Files',
  }
end, { desc = 'Find in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>fn', function() picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Find Config' })
