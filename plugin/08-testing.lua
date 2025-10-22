later(function()
	add({
		source = "nvim-neotest/neotest",
		depends = {
			"nvim-neotest/nvim-nio",
		},
	})

	require("neotest").setup({
		adapters = {
			-- Go testing is handled by ray-x/go.nvim
			-- Add other test adapters here as needed
		},
	})
end)

-- =====================================================
