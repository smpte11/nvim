pick_chezmoi = function()
	local pick = MiniPick

	-- Define the source items
	local source_items = require("chezmoi.commands").list()

	-- Start the picker
	pick.start({
		source = {
			items = source_items,
			choose = function(selected)
				require("chezmoi.commands").edit({
					targets = { "~/" .. selected },
					args = { "--watch" },
				})
			end,
		},
	})
end

vim.api.nvim_command("command! ChezmoiPick lua pick_chezmoi()")

local function show_stats()
	local db = require("db")
	local count = db.get_carried_over_tasks_count()
	vim.notify("Carried over tasks: " .. count)
end

vim.api.nvim_command("command! ShowStats lua show_stats()")

local function create_task()
	local uuid_gen = require("rfc4122")
	local db = require("db")

	local task_text = vim.fn.input("Task: ")
	if task_text == "" then
		vim.notify("Task creation cancelled", vim.log.levels.WARN)
		return
	end

	local task_id = uuid_gen.v4()
	local formatted_task = string.format("- [ ] %s [](task://%s)", task_text, task_id)

	-- Insert the task at the current cursor position
	vim.api.nvim_put({ formatted_task }, "c", true, true)

	db.log_event("task_created", task_id, {
		task_content = task_text,
	})

	vim.notify("Task created with ID: " .. task_id)
end

vim.api.nvim_command("command! CreateTask lua create_task()")
