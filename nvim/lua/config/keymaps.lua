-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Muscle memory from old vimrc: jj exits insert mode.
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Muscle memory: <C-o> toggles filetree.
-- LazyVim ships neo-tree; oil.nvim override is defined in lua/plugins/oil.lua.
vim.keymap.set("n", "<C-o>", "<cmd>Neotree toggle<cr>", { desc = "Toggle filetree" })
