local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local keymap = vim.keymap.set

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
	
	-- Set cohesive highlight groups that match mini.nvim and Kanagawa color palette
	local palette = Utils.palette
	vim.api.nvim_set_hl(0, "CodeCompanionChatInfo", { fg = palette.base0D, bg = palette.base01 })
	vim.api.nvim_set_hl(0, "CodeCompanionChatError", { fg = palette.base08, bg = palette.base01, bold = true })
	vim.api.nvim_set_hl(0, "CodeCompanionChatWarn", { fg = palette.base0A, bg = palette.base01 })
	vim.api.nvim_set_hl(0, "CodeCompanionChatSubtext", { fg = palette.base03, italic = true })
	vim.api.nvim_set_hl(0, "CodeCompanionChatHeader", { fg = palette.base0E, bold = true })
	vim.api.nvim_set_hl(0, "CodeCompanionChatSeparator", { fg = palette.base02 })
	vim.api.nvim_set_hl(0, "CodeCompanionChatTokens", { fg = palette.base06, italic = true })
	vim.api.nvim_set_hl(0, "CodeCompanionChatTool", { fg = palette.base0B, bg = palette.base01 })
	vim.api.nvim_set_hl(0, "CodeCompanionChatToolGroups", { fg = palette.base0C, bg = palette.base01, bold = true })
	vim.api.nvim_set_hl(0, "CodeCompanionChatVariable", { fg = palette.base09, italic = true })
	vim.api.nvim_set_hl(0, "CodeCompanionVirtualText", { fg = palette.base04, italic = true })

	keymap("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Codecompanion [A]i [A]actions" })
	keymap("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion [C]hat" })
	keymap("n", "<leader>ae", "<cmd>CodeCompanionExplain<cr>", { desc = "CodeCompanion [E]xplain" })
	keymap("n", "<leader>ag", "<cmd>CodeCompanionGenerate<cr>", { desc = "CodeCompanion [G]enerate" })
end)
