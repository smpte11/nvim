-- Uses global: add, later (from 00-bootstrap.lua)

later(function()
	add({
		source = "smpte11/octo.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"echasnovski/mini.pick",
		},
		checkout = "feat/add-mini-picker-provider",
	})
	require("octo").setup({
		picker = "mini_picker",
	})
	
	-- Set up Octo keymaps after loading
	local keymap = vim.keymap.set
	keymap("n", "<leader>goo", "<cmd>Octo actions<cr>", { desc = "[Git] Octo Actions" })
	keymap("n", "<leader>gop", "<cmd>Octo pr list<cr>", { desc = "[Git] Octo PR List" })
	keymap("n", "<leader>goi", "<cmd>Octo issue list<cr>", { desc = "[Git] Octo Issue List" })
	keymap("n", "<leader>goc", "<cmd>Octo issue create<cr>", { desc = "[Git] Octo Create Issue" })
	keymap("n", "<leader>gor", "<cmd>Octo review list<cr>", { desc = "[Git] Octo Review List" })
	keymap("n", "<leader>goR", "<cmd>Octo review start<cr>", { desc = "[Git] Octo Start Review" })
	keymap("n", "<leader>gos", "<cmd>Octo review submit<cr>", { desc = "[Git] Octo Submit Review" })
end)
