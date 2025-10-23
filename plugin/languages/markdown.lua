-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Markdown Configuration                                                      │
-- │                                                                             │
-- │ Enhanced Markdown rendering with render-markdown.nvim.                     │
-- │                                                                             │
-- │ Uses global: spec (from 00-bootstrap.lua)                                  │
-- └─────────────────────────────────────────────────────────────────────────────┘

spec({
	source = "MeanderingProgrammer/render-markdown.nvim",
	config = function()
		require("render-markdown").setup({})
	end,
})

