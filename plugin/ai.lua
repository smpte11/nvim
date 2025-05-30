local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "zbirenbaum/copilot.lua",
	})

	require("copilot").setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
	})

	add({
		source = "olimorris/codecompanion.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})

	require("codecompanion").setup({
		strategies = {
			chat = {
				adapter = "copilot",
				keymaps = {
					close = {
						modes = { n = "q", i = "<C-c>" },
					},
				},
			},
			inline = {
				adapter = "copilot",
			},
		},
		display = {
			action_palette = {
				width = 95,
				height = 10,
				prompt = "Prompt ", -- Prompt used for interactive LLM calls
				provider = "mini_pick", -- default|telescope|mini_pick
				opts = {
					show_default_actions = true, -- Show the default actions in the action palette?
					show_default_prompt_library = true, -- Show the default prompt library in the action palette?
				},
			},
		},
	})
end)
