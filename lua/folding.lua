local M = {}

local config = {
	filetype = "markdown",
	lsp_client = "obsidian-ls",
	max_restore_attempts = 40,
	retry_delay = 50,
}

local fold_dir = vim.fn.stdpath("state") .. "/folds"
local state_file = fold_dir .. "/states.json"

-- Return true only for named Markdown files
local function is_note(buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].filetype == config.filetype
		and vim.bo[buf].buftype == ""
		and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function note_path(buf)
	return vim.api.nvim_buf_get_name(buf)
end

local function legacy_state_file(buf)
	return fold_dir .. "/" .. vim.fn.sha256(note_path(buf))
end

local function has_obsidian_lsp(buf)
	return #vim.lsp.get_clients({ bufnr = buf, name = config.lsp_client }) > 0
end

local function configure_window(win)
	vim.wo[win].foldmethod = "expr"
	vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
	vim.wo[win].foldtext = "v:lua.vim.lsp.foldtext()"
	vim.wo[win].foldlevel = 99
	vim.wo[win].foldcolumn = "1"
end

local function configure_windows(buf)
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		configure_window(win)
	end
end

-- Read the one JSON file that contains fold states for all notes.
local function load_states()
	if vim.fn.filereadable(state_file) == 0 then
		return {}
	end

	local ok, lines = pcall(vim.fn.readfile, state_file)
	if not ok then
		return nil
	end

	local decoded, states = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
	if not decoded or type(states) ~= "table" then
		return nil
	end

	return states
end

local function save_states(states)
	local temp_file = state_file .. ".tmp"
	local encoded, content = pcall(vim.fn.json_encode, states)
	if not encoded then
		return false
	end

	local written, result = pcall(vim.fn.writefile, { content }, temp_file)
	if not written or result ~= 0 or vim.fn.rename(temp_file, state_file) ~= 0 then
		vim.fn.delete(temp_file)
		return false
	end

	return true
end

local function read_saved_state(buf)
	local states = load_states()
	if not states then
		return nil
	end

	local path = note_path(buf)
	if type(states[path]) == "table" then
		return states[path]
	end

	local old_file = legacy_state_file(buf)
	if vim.fn.filereadable(old_file) == 0 then
		return nil
	end

	local ok, lines = pcall(vim.fn.readfile, old_file)
	if not ok then
		return nil
	end

	states[path] = lines
	if save_states(states) then
		vim.fn.delete(old_file)
	end

	return lines
end

local function has_folds(win)
	return vim.api.nvim_win_call(win, function()
		for line = 1, vim.fn.line("$") do
			if vim.fn.foldlevel(line) > 0 then
				return true
			end
		end
		return false
	end)
end

local function restore_folds(buf, win)
	local lines = read_saved_state(buf)
	if not lines then
		return
	end

	vim.api.nvim_win_call(win, function()
		local saved_cursor = vim.api.nvim_win_get_cursor(0)
		local fold_line

		for _, line in ipairs(lines) do
			local number = tonumber(line)
			local action = line:match("^sil! normal! z([oc])$")

			if number then
				fold_line = number
			elseif action and fold_line and fold_line >= 1 and fold_line <= vim.fn.line("$") then
				vim.api.nvim_win_set_cursor(0, { fold_line, 0 })
				vim.cmd("silent! normal! z" .. action)
				fold_line = nil
			end
		end

		vim.api.nvim_win_set_cursor(0, saved_cursor)
	end)
end

local function restore_when_ready(buf, attempt)
	if not is_note(buf) or not has_obsidian_lsp(buf) then
		return
	end

	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		return
	end

	if not has_folds(win) and attempt < config.max_restore_attempts then
		vim.defer_fn(function()
			restore_when_ready(buf, attempt + 1)
		end, config.retry_delay)
		return
	end

	restore_folds(buf, win)
	vim.b[buf].fold_state_ready = true
end

local function save_folds(buf)
	if not is_note(buf) or not vim.b[buf].fold_state_ready then
		return
	end

	-- Prefer the current window; otherwise use the first window showing the note.
	local win = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_buf(win) ~= buf then
		win = vim.fn.win_findbuf(buf)[1]
	end

	if not win then
		return
	end

	local temp_view = vim.fn.tempname()
	local ok = pcall(vim.api.nvim_win_call, win, function()
		vim.cmd("silent! mkview! " .. vim.fn.fnameescape(temp_view))
	end)

	if not ok or vim.fn.filereadable(temp_view) == 0 then
		vim.fn.delete(temp_view)
		return
	end

	local read_ok, lines = pcall(vim.fn.readfile, temp_view)
	vim.fn.delete(temp_view)
	if not read_ok then
		return
	end

	local states = load_states()
	if not states then
		return
	end

	states[note_path(buf)] = lines
	if save_states(states) then
		-- Remove this note's old per-note file after its state is safely saved.
		vim.fn.delete(legacy_state_file(buf))
	end
end

function M.setup()
	local augroup = vim.api.nvim_create_augroup("ObsidianFolding", { clear = true })

	vim.opt.viewoptions = "folds"
	vim.opt.fillchars:append({
		fold = " ",
		foldopen = "▾",
		foldclose = "▸",
		foldsep = " ",
	})
	vim.fn.mkdir(fold_dir, "p")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = augroup,
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not (client and client.name == config.lsp_client) then
				return
			end

			configure_windows(event.buf)
			restore_when_ready(event.buf, 0)
		end,
		desc = "Configure obsidian-ls folding and restore saved folds",
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = augroup,
		callback = function(event)
			if is_note(event.buf) and has_obsidian_lsp(event.buf) then
				configure_windows(event.buf)
				restore_when_ready(event.buf, 0)
			end
		end,
		desc = "Restore fold state when a note is shown",
	})

	vim.api.nvim_create_autocmd("BufWinLeave", {
		group = augroup,
		callback = function(event)
			save_folds(event.buf)
		end,
		desc = "Save fold state when leaving a note window",
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = augroup,
		callback = function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				save_folds(vim.api.nvim_win_get_buf(win))
			end
		end,
		desc = "Save fold state of visible notes on exit",
	})
end

return M
