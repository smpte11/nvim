local add, later = MiniDeps.add, MiniDeps.later
local keymap = vim.keymap.set

later(function()
	add({
		source = "christoomey/vim-tmux-navigator",
	})

	keymap("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
	keymap("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Navigate down" })
	keymap("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Navigate up" })
	keymap("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Navigate right" })
	keymap("n", "<c-\\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Navigate previous" })
end)
