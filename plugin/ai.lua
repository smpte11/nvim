-- Uses global: add, later (from 00-bootstrap.lua)

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

	-- Set up AI keymaps after CodeCompanion is loaded
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = false }

	-- AI operations (only verified commands from documentation)
	keymap({"n", "v"}, "<leader>aa", "<cmd>CodeCompanionActions<cr>", vim.tbl_extend("force", opts, { desc = 'CodeCompanion [A]ctions'}))
	keymap({"n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat<cr>", vim.tbl_extend("force", opts, { desc = 'CodeCompanion [C]hat'}))
	keymap({"n", "v"}, "<leader>ai", "<cmd>CodeCompanion<cr>", vim.tbl_extend("force", opts, { desc = 'CodeCompanion [I]nline Assistant'}))
end)
