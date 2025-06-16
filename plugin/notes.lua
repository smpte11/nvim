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
				end,
			},
		},
	})

	local commands = require("zk.commands")

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
end)
