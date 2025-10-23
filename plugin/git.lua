-- Uses global: spec (from 00-bootstrap.lua)

-- Neogit + Diffview - Git interface
spec({
	source = "neogitorg/neogit",
	depends = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"akinsho/git-conflict.nvim",
		"echasnovski/mini.pick",
	},
	config = function()
		require("diffview").setup({
			hooks = {
				view_opened = function(_)
					table.insert(MiniClue.config.clues, { mode = "n", keys = "<leader>c", desc = " conflicts" })
				end,
				view_closed = function(_)
					for i, entry in ipairs(MiniClue.config.clues) do
						if entry.mode == "n" and entry.keys == "<leader>c" and entry.desc == " conflicts" then
							table.remove(MiniClue.config.clues, i)
							break
						end
					end
				end,
			},
		})

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
	keys = {
		{
			"<leader>gg",
			function()
				require("neogit").open()
			end,
			desc = "[Git] Status",
		},
		{
			"<leader>gb",
			function()
				require("mini.extra").pickers.git_branches()
			end,
			desc = "[Git] [B]ranches",
		},
		{
			"<leader>gc",
			function()
				require("mini.extra").pickers.git_commits()
			end,
			desc = "[Git] [C]ommits",
		},
		{
			"<leader>gh",
			function()
				require("mini.extra").pickers.git_hunks()
			end,
			desc = "[Git] [H]unks",
		},
	},
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
	keys = {
		{ "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "[Git] [B]lame Toggle" },
	},
})
