-- Uses global: add, later (from 00-bootstrap.lua)

later(function()
	add({
		source = "christoomey/vim-tmux-navigator",
	})

	-- Set up Tmux navigation keymaps after vim-tmux-navigator is loaded
	local keymap = vim.keymap.set
	keymap("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
	keymap("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down" })
	keymap("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up" })
	keymap("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right" })
	keymap("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Navigate previous" })
end)
