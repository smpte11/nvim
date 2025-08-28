local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "shortcuts/no-neck-pain.nvim",
	})

	require("no-neck-pain").setup({
		mappings = {
			enabled = true,
			toggle = "<leader>uzt",
			toggleLeftSide = "<leader>uzl",
			toggleRightSide = "<leader>uzr",
			widthUp = "<leader>uz=",
			widthDown = "<leader>uz-",
			scratchPad = "<leader>uzs",
		},
	})
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
