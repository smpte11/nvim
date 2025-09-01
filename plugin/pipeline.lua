local add, later = MiniDeps.add, MiniDeps.later

later(function()
	add({
		source = "topaxi/pipeline.nvim",
		-- optional, you can also install and use `yq` instead.
		-- build = "make",
	})
	require("pipeline").setup({})

	vim.keymap.set("n", "<leader>upo", "<cmd>Pipeline open<cr>", { desc = "Open Pipeline" })
	vim.keymap.set("n", "<leader>upc", "<cmd>Pipeline close<cr>", { desc = "Close Pipeline" })
	vim.keymap.set("n", "<leader>upt", "<cmd>Pipeline toggle<cr>", { desc = "Toggle Pipeline" })
end)
