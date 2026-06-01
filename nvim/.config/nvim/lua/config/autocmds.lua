-- Disable autoformat for cpp files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})
