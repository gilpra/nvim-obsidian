local map = vim.keymap.set

-- Icons used by Oil.
require("mini.icons").setup()

-- Obsidian.nvim uses mini.pick as its picker backend.
require("mini.pick").setup({
	options = {
		use_cache = true,
	},
})

-- Handy navigation pickers.
map("n", "<leader>ff", function()
	require("mini.pick").builtin.files({ tool = "rg" })
end, { desc = "Find files" })

map("n", "<leader>fo", function()
	require("mini.pick").start({
		source = {
			items = vim.v.oldfiles,
			name = "Recent files",
		},
	})
end, { desc = "Recent files" })

map("n", "<leader>fb", function()
	require("mini.pick").builtin.buffers()
end, { desc = "Find buffers" })
