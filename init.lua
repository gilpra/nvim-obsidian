vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("vim._core.ui2").enable({})
require("options")

vim.pack.add({
	{ src = "https://github.com/gilpra/yoruakari.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/romus204/tree-sitter-manager.nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim", version = vim.version.range("*") },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/NeogitOrg/neogit" },
})

vim.cmd.colorscheme("yoruakari")

require("plugins.mini")
require("plugins.oil")
require("plugins.treesitter")
require("plugins.render-markdown")
require("plugins.obsidian")
require("plugins.diffview")
require("plugins.neogit")

require("autocmds")
require("folding").setup()
require("commands")
require("keymaps")
require("statusline")
require("tabline")
