-- Uses global: spec (from 00-bootstrap.lua)

-- Diffview - Git diff viewer with automatic 3-way merge support
spec({
	source = "sindrets/diffview.nvim",
	depends = { "nvim-lua/plenary.nvim" },
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
		})
	end,
	-- stylua: ignore start
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "[Git] [D]iffview Open (auto 3-way merge)" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "[Git] [D]iffview Close" },
		{ "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "[Git] [F]ile History" },
		{ "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "[Git] [F]ile History (All)" },
		{ "<leader>gm", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "[Git] [M]erge Base Diff" },
	},
	-- stylua: ignore end
})

-- Neogit - Git interface
spec({
	source = "neogitorg/neogit",
	depends = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"echasnovski/mini.pick",
	},
	config = function()
		require("neogit").setup({
			integrations = {
				mini_pick = true,
				fzf_lua = false,
				telescope = false,
				snacks = false,
				diffview = true,
			},
		})
	end,
	-- stylua: ignore start
	keys = {
		{ "<leader>gg", function() require("neogit").open() end, desc = "[Git] Status" },
		{ "<leader>gb", function() require("mini.extra").pickers.git_branches() end, desc = "[Git] [B]ranches" },
		{ "<leader>gc", function() require("mini.extra").pickers.git_commits() end, desc = "[Git] [C]ommits" },
		{ "<leader>gH", function() require("mini.extra").pickers.git_hunks() end, desc = "[Git] [H]unks" },
	},
	-- stylua: ignore end
})

-- Git Blame
spec({
	source = "f-person/git-blame.nvim",
	config = function()
		require("gitblame").setup({
			enabled = false, -- Don't enable by default
			message_template = " <author> • <date> • <summary>",
			date_format = "%c",
			virtual_text_column = 2,
		})
	end,
	-- stylua: ignore start
	keys = {
		{ "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "[Git] [B]lame Toggle" },
	},
	-- stylua: ignore end
})
