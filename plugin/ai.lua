-- Uses global: add, later, spec (from 00-bootstrap.lua)

-- GitHub Copilot
spec({
	source = "zbirenbaum/copilot.lua",
	config = function()
		require("copilot").setup({
			suggestion = { enabled = false },
			panel = { enabled = false },
		})
	end,
})

-- CodeCompanion AI assistant
spec({
	source = "olimorris/codecompanion.nvim",
	depends = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			adapters = {
				http = {
					ollama = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								url = "http://localhost:1234",
								api_key = "lm-studio",
							},
						})
					end,
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
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
	end,
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion [A]ctions", mode = { "n", "v" }, noremap = true, silent = false },
		{ "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "CodeCompanion [C]hat", mode = { "n", "v" }, noremap = true, silent = false },
		{ "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion [I]nline Assistant", mode = { "n", "v" }, noremap = true, silent = false },
	},
})
