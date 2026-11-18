require("obsidian").setup({
	legacy_commands = false,
	note_id_func = require("obsidian.builtin").title_id,
	notes_subdir = "00 Inbox",
	new_notes_location = "notes_subdir",

	frontmatter = { enabled = false },

	workspaces = {
		{
			name = "personal",
			path = "~/Documents/Obsidian/Vaults",
		},
	},

	picker = {
		name = "mini.pick",
	},

	ui = {
		enable = false,
	},

	footer = {
		enabled = false,
	},

	cache = {
		enabled = true,
	},

	link = {
		style = "wiki",
		render_modes = false,
		format = "shortest",
		auto_update = false,
	},

	checkbox = {
		order = { " ", "x" },
	},

	templates = {
		folder = "99 Metas/Templates",
		date_format = "YYYY-MM-DD",
		time_format = "HH:mm",
	},

	daily_notes = {
		enabled = true,
		folder = "03 Journals",
		date_format = "YYYY-MM-DD",
		template = "Journal.md",
		default_tags = { "journal" },
		workdays_only = false,
		start_of_week = 1,
	},

	attachments = {
		folder = "99 Metas/Attachments",
	},
})

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>on", "<cmd>Obsidian new_from_template<CR>", { desc = "Obsidian: New note" })
map("n", "<leader>os", "<cmd>Obsidian quick_switch<CR>", { desc = "Obsidian: Quick switch" })
map("n", "<leader>od", "<cmd>Obsidian today<CR>", { desc = "Obsidian: Today's note" })
map("n", "<leader>ot", "<cmd>Obsidian template<CR>", { desc = "Obsidian: Insert template" })

map("n", "<leader>oo", function()
	local dir = vim.fn.expand("~/Documents/Obsidian/Vaults")
	vim.cmd("cd " .. vim.fn.fnameescape(dir))
	require("oil").open()
end, { desc = "Obsidian: Open Vault directory" })

map("n", "<leader>of", function()
	local buf = vim.api.nvim_get_current_buf()
	local state = require("render-markdown.state")
	local config = state.get(buf)

	local enabled = not config.anti_conceal.enabled

	config.anti_conceal.enabled = enabled
	config.win_options.concealcursor.rendered = enabled and "" or "nvic"

	require("render-markdown").render({
		buf = buf,
		force = true,
	})

	vim.notify("Reading mode: " .. (enabled and "false" or "true"))
end, { desc = "Obsidian: Toggle Reading Mode" })
