-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ LeetCode Configuration                                                      │
-- │                                                                             │
-- │ LeetCode integration for competitive programming practice.                 │
-- │                                                                             │
-- │ Uses global: add, now (from 00-bootstrap.lua)                              │
-- └─────────────────────────────────────────────────────────────────────────────┘

now(function()
	add({
		source = "smpte11/leetcode.nvim",
		depends = {
			"echasnovski/mini.pick",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		hooks = {
			post_checkout = function()
				vim.cmd("TsUpdate html")
			end,
		},
	})

	require("leetcode").setup({
		lang = "python3",
	})
end)
