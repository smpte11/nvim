local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "smpte11/octo.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"echasnovski/mini.pick",
		},
		checkout = "feat/add-mini-picker-provider",
	})
	require("octo").setup({
		picker = "mini_picker",
	})
end)
