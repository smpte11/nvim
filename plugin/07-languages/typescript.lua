later(function()
	add({
		source = "pmizio/typescript-tools.nvim",
		depends = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	})

	require("typescript-tools").setup({})
end)

