local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add("zk-org/zk-nvim")

	local zk = require("zk")
	zk.setup({
		piker = "minipick",
		lsp = {
			config = {
				on_attach = function(_, _)
					local function map(...)
						vim.api.nvim_buf_set_keymap(0, ...)
					end
					local opts = { noremap = true, silent = false }
					-- Create a new note in the same directory as the current buffer, using the current selection for title.
					map(
						"v",
						"<leader>nnt",
						":'<,'>ZkNewFromTitleSelection<CR>",
						vim.tbl_extend("force", opts, { desc = "Create new from selection (Title)" })
					)
					-- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
					map(
						"v",
						"<leader>nnc",
						":'<,'>ZkNewFromContentSelection { title = vim.fn.input('Title: ') }<CR>",
						vim.tbl_extend("force", opts, { desc = "Create new from selection (Content)" })
					)
					-- Journal creation with carryover
					map(
						"n",
						"<leader>nj",
						":ZkNewDailyJournal<CR>",
						vim.tbl_extend("force", opts, { desc = "New daily journal note (carry unfinished tasks)" })
					)
					map(
						"n",
						"<leader>nw",
						":ZkNewWorkJournal<CR>",
						vim.tbl_extend("force", opts, { desc = "New work daily journal note (carry unfinished tasks)" })
					)
				end,
			},
		},
	})

	local commands = require("zk.commands")

	-- Carryover helper functions
	local function create_journal_helpers()
		local uv = vim.loop

		local function read_file(path)
			local fd = uv.fs_open(path, "r", 438)
			if not fd then
				return nil
			end
			local stat = uv.fs_fstat(fd)
			local data = uv.fs_read(fd, stat.size, 0)
			uv.fs_close(fd)
			return data
		end

		local function get_most_recent_journal_note(target_dir)
			local handle = uv.fs_scandir(target_dir)
			if not handle then
				return nil
			end
			local files = {}
			while true do
				local name, typ = uv.fs_scandir_next(handle)
				if not name then
					break
				end
				-- Allow any prefix (including hyphens)
				if typ == "file" and name:match("^.+%-%d%d%d%d%-%d%d%-%d%d%.md$") then
					table.insert(files, name)
				end
			end
			table.sort(files, function(a, b)
				return a > b
			end)
			if #files == 0 then
				return nil
			end
			return target_dir .. "/" .. files[1]
		end

		local function extract_unfinished_tasks(content, section)
			-- Escape special pattern characters in section name
			local escaped_section = section:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
			
			-- Find the start of our section
			local section_start = content:find("## " .. escaped_section)
			if not section_start then
				return {}
			end
			
			-- Find the start of content (after the section header and any whitespace)
			local content_start = content:find("\n", section_start)
			if not content_start then
				return {}
			end
			content_start = content_start + 1
			
			-- Find the next section header or end of content
			local next_section_start = content:find("\n## ", content_start)
			local section_content
			
			if next_section_start then
				section_content = content:sub(content_start, next_section_start - 1)
			else
				section_content = content:sub(content_start)
			end
			
			-- Remove leading/trailing whitespace
			section_content = section_content:gsub("^%s+", ""):gsub("%s+$", "")
			
			local tasks = {}
			-- Handle empty sections
			if section_content == "" then
				return tasks
			end
			
			-- Split by newlines and check each line for unfinished tasks
			for line in (section_content .. "\n"):gmatch("(.-)\n") do
				line = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
				if line:match("^%- %[ %]") or line:match("^%- %[%-%]") then
					table.insert(tasks, line)
				end
			end
			return tasks
		end

		return {
			read_file = read_file,
			get_most_recent_journal_note = get_most_recent_journal_note,
			extract_unfinished_tasks = extract_unfinished_tasks,
		}
	end

	-- Function to create a new task with custom URI
	local function create_new_task()
		-- Use the shared UUID generation utility from Utils
		local uuid = Utils.generate_uuid()
		local task_line = string.format("- [ ]  [ ](task://%s)", uuid)
		
		-- Get current cursor position in the current window
		-- vim.api.nvim_win_get_cursor(0) returns {row, col} where:
		-- - 0 means "current window"
		-- - row is 1-indexed (first line is 1)
		-- - col is 0-indexed (first column is 0)
		-- We only need [1] to get the row number
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		
		-- Insert text into the current buffer after the current line
		-- vim.api.nvim_buf_set_lines(buffer, start, end, strict_indexing, replacement)
		-- - 0 means "current buffer"
		-- - current_line for start: since nvim_buf_set_lines uses 0-indexed lines,
		--   and current_line is 1-indexed, using current_line as 0-indexed position
		--   means we insert after the 1-indexed line current_line
		-- - current_line for end means "don't replace any existing lines"
		-- - false means "allow out-of-bounds line numbers" (more forgiving)
		-- - {task_line} is a table of strings to insert (one string = one line)
		vim.api.nvim_buf_set_lines(0, current_line, current_line, false, {task_line})
		
		-- Move the cursor to the task line we just inserted
		-- vim.api.nvim_win_set_cursor(window, {row, col})
		-- - 0 means "current window"
		-- - {current_line + 1, 6} means:
		--   - current_line + 1 is the new task line (original line + 1 due to insertion)
		--   - 6 is the column position (0-indexed): "- [ ] " = positions 0,1,2,3,4,5, so 6 is right after the space
		vim.api.nvim_win_set_cursor(0, {current_line + 1, 6})
		
		-- Enter insert mode programmatically
		-- vim.cmd() executes a Vim command as if you typed it in command mode
		-- "startinsert" is the Vim command equivalent to pressing 'i' in normal mode
		-- This puts the cursor in insert mode so the user can immediately start typing
		vim.cmd("startinsert")
	end

	-- Journal content creation with task carryover
	local function create_journal_content_with_carryover(target_dir, task_type)
		local H = create_journal_helpers()
		local prev_path = H.get_most_recent_journal_note(target_dir)
		local main_tasks, other_tasks = {}, {}
		
		if prev_path then
			local prev_content = H.read_file(prev_path)
			if prev_content then
				main_tasks = H.extract_unfinished_tasks(prev_content, "What is my main goal for today?")
				other_tasks = H.extract_unfinished_tasks(prev_content, "What else do I wanna do?")

				-- Show extracted tasks in a notification only if there are tasks to show
				local has_main_tasks = next(main_tasks) ~= nil
				local has_other_tasks = next(other_tasks) ~= nil
				
				if has_main_tasks or has_other_tasks then
					local msg_parts = {}
					
					if has_main_tasks then
						table.insert(msg_parts, "Main tasks:\n" .. table.concat(main_tasks, "\n"))
					end
					
					if has_other_tasks then
						table.insert(msg_parts, "Other tasks:\n" .. table.concat(other_tasks, "\n"))
					end
					
					local msg = table.concat(msg_parts, "\n\n")
					vim.notify(msg, vim.log.levels.INFO, { title = "Extracted Unfinished Tasks (" .. task_type .. ")" })
				else
					local entry_type = task_type:lower() == "work" and "work journal" or "journal"
					vim.notify("No unfinished tasks found in previous " .. entry_type .. " entry.", vim.log.levels.INFO, { title = "Task Extraction (" .. task_type .. ")" })
				end
			else
				local file_type = task_type:lower() == "work" and "work journal" or "journal"
				vim.notify("Could not read previous " .. file_type .. " file: " .. prev_path, vim.log.levels.WARN, { title = "Task Extraction (" .. task_type .. ")" })
			end
		end
		
		return "## What is my main goal for today?\n"
			.. (next(main_tasks) and table.concat(main_tasks, "\n") .. "\n" or "")
			.. "\n## What else do I wanna do?\n"
			.. (next(other_tasks) and table.concat(other_tasks, "\n") .. "\n" or "")
			.. "\n## What did I do today?\n"
	end

	commands.add("ZkNewAtDir", function(options)
		options = options or {}
		local notedir = vim.env.ZK_NOTEBOOK_DIR
		if notedir == nil or notedir == "" then
			vim.notify("ZK_NOTEBOOK_DIR is not set.", vim.log.levels.ERROR)
			return
		end

		-- Helper function to get directory items for the picker
		local get_directory_items = function(current_path_abs)
			local items = {}
			-- Add ".. (Parent)" navigation item if not at the notedir root
			-- Ensure paths are compared reliably (e.g. by resolving them)
			local resolved_current_path = vim.fn.resolve(current_path_abs)
			local resolved_notedir = vim.fn.resolve(notedir)

			if resolved_current_path ~= resolved_notedir then
				local parent_path = vim.fn.fnamemodify(current_path_abs, ":h")
				local resolved_parent_path = vim.fn.resolve(parent_path) -- Resolve for comparison
				-- Ensure parent_path is not empty or root before adding, and is above or at notedir
				if
					parent_path ~= ""
					and parent_path ~= current_path_abs
					and vim.startswith(resolved_current_path, resolved_notedir)
					and #resolved_parent_path >= #resolved_notedir
				then
					table.insert(items, {
						text = ".. (Parent Directory)",
						path = parent_path,
						is_parent_link = true,
						is_dir = true, -- Treat parent link as a directory for navigation purposes
					})
				end
			end

			-- Read current_path, add subdirectories
			-- vim.fn.readdir can error if dir is not readable, use pcall
			local ok, dir_contents = pcall(vim.fn.readdir, current_path_abs)
			if not ok or dir_contents == nil then
				vim.notify("Error reading directory: " .. current_path_abs, vim.log.levels.WARN)
				-- Return items collected so far (e.g., parent link) or empty if none
				return items
			end

			-- Sort directory contents for consistent order
			table.sort(dir_contents)

			for _, name in ipairs(dir_contents) do
				-- Ignore hidden directories (starting with .)
				if not vim.startswith(name, ".") then
					local full_item_path = current_path_abs .. "/" .. name
					-- Ensure it's actually a directory
					if vim.fn.isdirectory(full_item_path) == 1 then
						table.insert(items, {
							text = name,
							path = full_item_path,
							is_dir = true,
						})
					end
				end
			end
			table.insert(items, { text = "(Select current: " .. vim.fn.fnamemodify(current_path_abs, ":~") .. ")", path = current_path_abs, is_current_dir_selection = true, is_dir = true })
			return items
		end

		local current_picker_path = notedir -- Path the picker is currently showing

		local _handle_final_directory_selection = function(selected_dir_path)
			if selected_dir_path == nil then
				vim.notify("No directory selected. Note creation cancelled.", vim.log.levels.INFO)
				return
			end

			local dir_to_use = selected_dir_path
			-- Normalize path (e.g., remove trailing slash)
			if string.sub(dir_to_use, -1) == "/" and #dir_to_use > 1 then -- Avoid turning "/" into ""
				dir_to_use = string.sub(dir_to_use, 1, -2)
			end

			-- This notification can be removed if it's too verbose, or kept for debugging
			-- vim.notify("Selected directory for zk: '" .. dir_to_use .. "'", vim.log.levels.INFO)

			local note_title = vim.fn.input("Title: ")
			if note_title == nil or note_title == "" then
				vim.notify("Title cannot be empty. Note creation cancelled.", vim.log.levels.WARN)
				return
			end
			zk.new({ dir = dir_to_use, title = note_title })
		end

		-- Recursive function to show picker for a given path
		local show_picker_for_path
		show_picker_for_path = function(path_to_show)
			current_picker_path = path_to_show -- Update current path being viewed

			local picker_items = get_directory_items(path_to_show)

			MiniPick.start({
				source = {
					items = picker_items,
					name = "Select Directory (Current: " .. vim.fn.fnamemodify(path_to_show, ":~") .. ")",
					cwd = path_to_show,
					show = function(buf_id, items_arr, query)
						-- Use MiniPick.default_show, attempting to show icons.
						-- Our items have a .text and .path field, which default_show can use.
						MiniPick.default_show(buf_id, items_arr, query, { show_icons = true })
					end,
					choose = function(selected_item)
						if selected_item == nil then return false end -- Esc pressed, stop picker

						if selected_item.is_current_dir_selection then
							_handle_final_directory_selection(selected_item.path)
							return false -- Stop picker, selection processed
						elseif selected_item.is_parent_link then
							show_picker_for_path(selected_item.path)
							return false -- Stop current picker, new one will start for parent path
						elseif selected_item.is_dir then -- This implies it's a navigable subdirectory
							show_picker_for_path(selected_item.path)
							return false -- Stop current picker, new one will start for subdir
						end
						-- Default action if no specific handling: stop the picker.
						return false
					end,
				},
				mappings = {
					select_current_dir = {
						char = "<S-CR>", -- Shift-Enter
						func = function()
							-- If current picker view has no items (other than parent link),
							-- it means we are in an empty dir. Allow selecting it.
							-- Or if user wants to select the directory they are currently viewing.
							_handle_final_directory_selection(current_picker_path)
							return false -- Stop picker, selection processed
						end,
					},
				},
			})
		end

		show_picker_for_path(notedir) -- Start the picker
	end)

	-- Daily journal creation with carryover functionality
	commands.add("ZkNewDailyJournal", function(options)
		options = options or {}
		local dir = vim.fn.input("Journal directory: ", "journal/daily")
		if dir == "" then
			vim.notify("Journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local prefix = vim.fn.input("Note prefix: ", "perso")
		if prefix == "" then
			vim.notify("Journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local date = os.date("%Y-%m-%d")
		local title = string.format("%s-%s", prefix, date)
		local target_dir = vim.fn.expand("$ZK_NOTEBOOK_DIR") .. "/" .. dir
		local content = create_journal_content_with_carryover(target_dir, "personal")
		
		zk.new({
			dir = dir,
			title = title,
			content = content,
		})
	end)

	-- Work daily journal creation with carryover functionality
	commands.add("ZkNewWorkJournal", function(options)
		options = options or {}
		local dir = vim.fn.input("Work journal directory: ", "work")
		if dir == "" then
			vim.notify("Work journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local prefix = vim.fn.input("Note prefix: ", "work")
		if prefix == "" then
			vim.notify("Work journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local date = os.date("%Y-%m-%d")
		local title = string.format("%s-%s", prefix, date)
		local target_dir = vim.fn.expand("$ZK_NOTEBOOK_DIR") .. "/" .. dir
		local content = create_journal_content_with_carryover(target_dir, "work")
		
		zk.new({
			dir = dir,
			title = title,
			content = content,
		})
	end)

	-- Task creation command
	commands.add("ZkNewTask", function()
		create_new_task()
	end)
end)

-- Add note-specific clues for mini.clue discoverability
local note_clues = {
	{ mode = "n", keys = "<leader>nn", desc = " new note" },
	{ mode = "n", keys = "<leader>nN", desc = " new at dir" },
	{ mode = "n", keys = "<leader>nj", desc = " daily journal" },
	{ mode = "n", keys = "<leader>nw", desc = " work journal" },
	{ mode = "n", keys = "<leader>no", desc = " open notes" },
	{ mode = "n", keys = "<leader>nt", desc = " tags" },
	{ mode = "n", keys = "<leader>nf", desc = " find notes" },
	{ mode = "n", keys = "<leader>nT", desc = " new task" },
}

-- Add clues when zk-nvim is attached (when working with notes)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == "zk" then
			-- Add clues for note buffer
			for _, clue in ipairs(note_clues) do
				table.insert(require("mini.clue").config.clues, clue)
			end

			-- Remove clues when leaving the buffer
			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = event.buf,
				once = true,
				callback = function()
					local clue_config = require("mini.clue").config.clues
					for i = #clue_config, 1, -1 do
						local existing_clue = clue_config[i]
						for _, note_clue in ipairs(note_clues) do
							if existing_clue.keys == note_clue.keys and existing_clue.desc == note_clue.desc then
								table.remove(clue_config, i)
								break
							end
						end
					end
				end,
			})
		end
	end,
})

-- Global note keymaps (moved from keymaps.lua for better organization)
local keymap = vim.keymap.set
local opts = { noremap = true, silent = false }

-- Create a new note after asking for its title.
keymap("n", "<leader>nn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", vim.tbl_extend('keep', opts, { desc = "New note" }))
keymap("n", "<leader>nN", "<Cmd>ZkNewAtDir<CR>", vim.tbl_extend('keep', opts, { desc = "New note at dir" }))

-- Open notes.
keymap("n", "<leader>no", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes" }))
-- Open notes associated with the selected tags.
keymap("n", "<leader>nt", "<Cmd>ZkTags<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes (tags)" }))

-- Search for the notes matching a given query.
keymap("n", "<leader>nf", "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", vim.tbl_extend('keep', opts, { desc = "Search notes" }))
-- Search for the notes matching the current visual selection.
keymap("v", "<leader>nf", ":'<,'>ZkMatch<CR>", vim.tbl_extend('keep', opts, { desc = 'Search notes'}))

-- Task creation with custom URI
keymap("n", "<leader>nT", "<Cmd>ZkNewTask<CR>", vim.tbl_extend('keep', opts, { desc = "New task with custom URI" }))
