local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "shortcuts/no-neck-pain.nvim",
	})

	require("no-neck-pain").setup({
		mappings = { enabled = false },
	})

	vim.keymap.set("n", "<leader>uzt", "<cmd>NoNeckPain<cr>", { desc = "Toggle" })
	vim.keymap.set("n", "<leader>uzl", "<cmd>NoNeckPainToggleLeftSide<cr>", { desc = "Toggle Left Side" })
	vim.keymap.set("n", "<leader>uzr", "<cmd>NoNeckPainToggleRightSide<cr>", { desc = "Toggle Right Side" })
	vim.keymap.set("n", "<leader>uz=", "<cmd>NoNeckPainWidthUp<cr>", { desc = "Increase Width" })
	vim.keymap.set("n", "<leader>uz-", "<cmd>NoNeckPainWidthDown<cr>", { desc = "Decrease Width" })
	vim.keymap.set("n", "<leader>uzs", "<cmd>NoNeckPainScratchPad<cr>", { desc = "Toggle ScratchPad" })
end)

later(function()
	add({
		source = "HakonHarnes/img-clip.nvim",
		--rocks = { "magick" }, -- Example of rock
	})

	require("img-clip").setup({
		-- add options here
		-- or leave it empty to use the default settings
	})

end)
