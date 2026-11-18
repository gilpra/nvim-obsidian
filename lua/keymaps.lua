local map = vim.keymap.set

-- File
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map({ "i", "x", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

-- Mode switching
map("n", ";", ":", { desc = "Enter command mode" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Navigation
map({ "n", "v" }, "H", "^", { desc = "Jump to beginning of line" })
map({ "n", "v" }, "L", "$", { desc = "Jump to end of line" })
map("v", "<", "<gv", { desc = "Indent left keep visual" })
map("v", ">", ">gv", { desc = "Indent right keep visual" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>z", "<cmd>Zoom<CR>", { desc = "Toggle zoom buffer" })

-- Selection and search
map("v", "*", [[y/\V<C-R>=escape(@", '\')<CR><CR>]], { silent = true })
map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("x", "<leader>r", "<Cmd>ReplaceSelection<CR>", { desc = "Replace selection" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Comments
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle line comment" })
map("v", "<leader>/", "gc", { remap = true, desc = "Toggle selection comment" })

-- Terminal and windows
map("n", "<leader>tt", "<cmd>vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
map("n", "<leader>sh", "<cmd>sp<CR>", { desc = "Split: horizontal" })
map("n", "<leader>sv", "<cmd>vsp<CR>", { desc = "Split: vertical" })
map("n", "<leader>se", "<cmd>wincmd =<CR>", { desc = "Split: equalize size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Split: close current pane" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<CR>", { desc = "Pane: decrease width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<CR>", { desc = "Pane: increase width" })
map("n", "<C-S-k>", "<cmd>resize +2<CR>", { desc = "Pane: increase height" })
map("n", "<C-S-j>", "<cmd>resize -2<CR>", { desc = "Pane: decrease height" })
