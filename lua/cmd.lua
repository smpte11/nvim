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

local daily = require("daily")
vim.api.nvim_create_user_command("ZkNewDailyWithUnfulfilledTasks", daily.create_daily_note, {})
