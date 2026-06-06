vim.pack.add {
  {
    src = 'https://github.com/folke/snacks.nvim',
  },
}

require('snacks').setup {
  picker = { enabled = true },
}

local picker = Snacks.picker
vim.keymap.set('n', '<leader>sh', function() picker.help() end, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', function() picker.keymaps() end, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', function() picker.smart() end, { desc = '[S]earch [F]iles' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', function() picker.grep_word() end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', function() picker.grep() end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', function() picker.diagnostics() end, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', function() picker.resume() end, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', function() picker.recent() end, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', function() picker.commands() end, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', function() picker.buffers() end, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sa', function() picker.files { hidden = true, ignored = true } end, { desc = '[S]earch [F]iles: Hidden & Ignored' })
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', function() picker.lsp_references() end, { buffer = buf, desc = '[G]oto [R]eferences' })

    vim.keymap.set('n', 'gri', function() picker.lsp_implementations() end, { buffer = buf, desc = '[G]oto [I]mplementation' })

    vim.keymap.set('n', 'grd', function() picker.lsp_definitions() end, { buffer = buf, desc = '[G]oto [D]efinition' })

    vim.keymap.set('n', 'gO', function() picker.lsp_symbols() end, { buffer = buf, desc = 'Open Document Symbols' })

    vim.keymap.set('n', 'gW', function() picker.lsp_workspace_symbols() end, { buffer = buf, desc = 'Open Workspace Symbols' })

    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = buf, desc = '[R]e[n]ame Symbol' })

    vim.keymap.set('n', 'grt', function() picker.lsp_type_definitions() end, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    picker.lines {
      layout = {
        preset = 'dropdown',
      },
    }
  end,
  { desc = '[/] Fuzzily search in current buffer' }
)

vim.keymap.set('n', '<leader>s/', function()
  picker.grep_buffers {
    title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
