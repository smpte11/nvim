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
        require("render-markdown").setup({
            heading = {
				border = true,
				border_virutal = true,
                -- Enable heading backgrounds by pointing to highlight groups that have bg defined
                -- (Note: These are defined in lua/config/colors.lua with bg colors)
                backgrounds = {
                    "RenderMarkdownH1",
                    "RenderMarkdownH2",
                    "RenderMarkdownH3",
                    "RenderMarkdownH4",
                    "RenderMarkdownH5",
                    "RenderMarkdownH6",
                },
            },
        })
    end
})

