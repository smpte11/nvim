local M = {}
local db = require("db")
local uuid_gen = require("rfc4122")

M.starter = {
	header = function()
		local day = os.date("%A")
		local headers = {
			["Monday"] = [[
███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██╗
████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Tuesday"] = [[
████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║
   ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Wednesday"] = [[
██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Thursday"] = [[
████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Friday"] = [[
███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝
█████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝
██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝
██║     ██║  ██║██║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Saturday"] = [[
███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝
╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝
███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Sunday"] = [[
███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
		}
		return headers[day]
	end,
}

M.palette = {
	base00 = "#1F1F28",
	base01 = "#2A2A37",
	base02 = "#223249",
	base03 = "#727169",
	base04 = "#C8C093",
	base05 = "#DCD7BA",
	base06 = "#938AA9",
	base07 = "#363646",
	base08 = "#C34043",
	base09 = "#FFA066",
	base0A = "#DCA561",
	base0B = "#98BB6C",
	base0C = "#7FB4CA",
	base0D = "#7E9CD8",
	base0E = "#957FB8",
	base0F = "#D27E99",
}

-- Common helper functions for journal creation
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
				local task_id
				local full_line = line

				-- Look for the pattern [](task://<uuid>)
				local _, _, id = line:find("%s*%[%]%(task://([%w%-]+)%)$")

				if id then
					task_id = id
				else
					-- No ID found, generate one and append it
					task_id = uuid_gen.v4()
					full_line = string.format("%s [](task://%s)", line, task_id)
				end

				table.insert(tasks, { id = task_id, line = full_line })
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

-- Common journal content creation with task carryover
local function create_journal_content_with_carryover(target_dir, task_type)
	local H = create_journal_helpers()
	local prev_path = H.get_most_recent_journal_note(target_dir)
	local main_tasks, other_tasks = {}, {}

	if prev_path then
		local prev_content = H.read_file(prev_path)
		if prev_content then
			main_tasks = H.extract_unfinished_tasks(prev_content, "What is my main goal for today?")
			other_tasks = H.extract_unfinished_tasks(prev_content, "What else do I wanna do?")

			for _, task in ipairs(main_tasks) do
				db.log_event("task_carried_over", task.id, {
					task_content = task.line,
					source_note = prev_path,
				})
			end

			for _, task in ipairs(other_tasks) do
				db.log_event("task_carried_over", task.id, {
					task_content = task.line,
					source_note = prev_path,
				})
			end

			-- Show extracted tasks in a notification only if there are tasks to show
			local has_main_tasks = next(main_tasks) ~= nil
			local has_other_tasks = next(other_tasks) ~= nil

			if has_main_tasks or has_other_tasks then
				local msg_parts = {}
				local main_task_lines = {}
				for _, task in ipairs(main_tasks) do
					table.insert(main_task_lines, task.line)
				end
				local other_task_lines = {}
				for _, task in ipairs(other_tasks) do
					table.insert(other_task_lines, task.line)
				end

				if has_main_tasks then
					table.insert(msg_parts, "Main tasks:\n" .. table.concat(main_task_lines, "\n"))
				end

				if has_other_tasks then
					table.insert(msg_parts, "Other tasks:\n" .. table.concat(other_task_lines, "\n"))
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

	local main_task_lines = {}
	for _, task in ipairs(main_tasks) do
		table.insert(main_task_lines, task.line)
	end
	local other_task_lines = {}
	for _, task in ipairs(other_tasks) do
		table.insert(other_task_lines, task.line)
	end

	return "## What is my main goal for today?\n"
		.. (next(main_tasks) and table.concat(main_task_lines, "\n") .. "\n" or "")
		.. "\n## What else do I wanna do?\n"
		.. (next(other_tasks) and table.concat(other_task_lines, "\n") .. "\n" or "")
		.. "\n## What did I do today?\n"
end

M.create_daily_journal_note = function()
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
    
    require("zk").new({
        dir = dir,
        title = title,
        content = content,
    })
end

M.create_work_daily_journal_note = function()
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
    
    require("zk").new({
        dir = dir,
        title = title,
        content = content,
    })
end

M.scan_buffer_for_completed_tasks = function()
	local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local buffer_text = table.concat(buffer_content, "\n")

	for line in buffer_text:gmatch("(.-)\n") do
		if line:match("^%- %[x%]") then
			-- This is a completed task, try to find its ID
			local _, _, id = line:find("%s*%[%]%(task://([%w%-]+)%)$")
			if id then
				local last_event = db.get_last_event_for_task(id)
				if not last_event or last_event.event_type ~= "task_completed" then
					-- Log the completion event
					db.log_event("task_completed", id, {
						task_content = line,
						source_note = vim.api.nvim_buf_get_name(0),
					})
					vim.notify("Logged completion for task: " .. id)
				end
			end
		end
	end
end

_G.Utils = M
