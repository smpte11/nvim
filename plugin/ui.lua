local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "shortcuts/no-neck-pain.nvim",
	})

	require("no-neck-pain").setup({})
end)
