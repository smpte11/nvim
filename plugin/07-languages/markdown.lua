-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Markdown Configuration                                                      │
-- │                                                                             │
-- │ Enhanced Markdown rendering with render-markdown.nvim.                     │
-- │                                                                             │
-- │ Uses global: add, later (from 00-bootstrap.lua)                            │
-- └─────────────────────────────────────────────────────────────────────────────┘

later(function()
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
	})

	require("render-markdown").setup({})
end)

