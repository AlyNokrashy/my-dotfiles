local map = vim.keymap.set

-- custom keymaps
map("n", "<leader>tt", "<cmd>lua require('FTerm').toggle()<cr>", { desc = "Toggle Floating Terminal" }) -- toggle Fterm
map("t", "<leader>tt", "<C-\\><C-n><cmd>lua require('FTerm').toggle()<cr>", { desc = "Toggle Floating Terminal" })
-- Ctrl + u/d -> cursor in the middle of the screeen
map("n", "<C-d>", "<C-d>zz", { desc = "Move up half page and center the cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Move up half page and center the cursor" })
map("i", "jf", "<ESC>", { desc = "Exit Insert mode" })
