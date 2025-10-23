-- Uses global: spec (from 00-bootstrap.lua)

spec({
	source = "smpte11/octo.nvim",
	depends = {
		"nvim-lua/plenary.nvim",
		"echasnovski/mini.pick",
	},
	checkout = "feat/add-mini-picker-provider",
	config = function()
		require("octo").setup({
			picker = "mini_picker",
		})
	end,
	-- stylua: ignore start
	keys = {
		{ "<leader>goo", "<cmd>Octo actions<cr>", desc = "[Git] Octo Actions" },
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "[Git] Octo PR List" },
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "[Git] Octo Issue List" },
		{ "<leader>goc", "<cmd>Octo issue create<cr>", desc = "[Git] Octo Create Issue" },
		{ "<leader>gor", "<cmd>Octo review list<cr>", desc = "[Git] Octo Review List" },
		{ "<leader>goR", "<cmd>Octo review start<cr>", desc = "[Git] Octo Start Review" },
		{ "<leader>gos", "<cmd>Octo review submit<cr>", desc = "[Git] Octo Submit Review" },
	},
	-- stylua: ignore end
})
