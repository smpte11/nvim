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

-- SSH mode debugging commands
vim.api.nvim_create_user_command("SshStatus", function()
	Utils.ssh.show_status()
end, { desc = "Show SSH mode detection status" })

vim.api.nvim_create_user_command("SshToggle", function()
	local current = vim.env.NVIM_SSH_MODE
	if current == "1" then
		vim.env.NVIM_SSH_MODE = "0"
		vim.notify("SSH mode disabled (manual override)", vim.log.levels.INFO)
	else
		vim.env.NVIM_SSH_MODE = "1"
		vim.notify("SSH mode enabled (manual override)", vim.log.levels.INFO)
	end
	vim.notify("Restart Neovim to apply changes", vim.log.levels.WARN)
end, { desc = "Toggle SSH mode (requires restart)" })

vim.api.nvim_create_user_command("SshClear", function()
	vim.env.NVIM_SSH_MODE = nil
	vim.notify("SSH mode override cleared, using auto-detection", vim.log.levels.INFO)
	vim.notify("Restart Neovim to apply changes", vim.log.levels.WARN)
end, { desc = "Clear SSH mode override (requires restart)" })
