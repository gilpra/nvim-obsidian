require("tree-sitter-manager").setup({
	parser_dir = vim.fn.stdpath("data") .. "/site/parser",
	query_dir = vim.fn.stdpath("data") .. "/site/queries",
	assume_installed = {
		"markdown",
		"markdown_inline",
	},
	ensure_installed = {
		"markdown",
		"markdown_inline",
	},
	auto_install = false,
	highlight = {},
})
