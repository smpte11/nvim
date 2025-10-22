-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Go Language Configuration                                                   │
-- │                                                                             │
-- │ Complete Go development setup including gopls LSP, DAP debugging,           │
-- │ formatting, testing, and more via ray-x/go.nvim.                            │
-- │                                                                             │
-- │ Uses global: add, later (from 00-bootstrap.lua)                            │
-- └─────────────────────────────────────────────────────────────────────────────┘

later(function()
	-- Comprehensive Go development plugin
	-- Includes LSP (gopls), DAP debugging, testing, formatting, and more
	add({
		source = "ray-x/go.nvim",
		depends = {
			"ray-x/guihua.lua", -- optional float term, codeaction gui support
			"nvim-treesitter/nvim-treesitter",
		},
	})

	require("go").setup({
		goimports = 'gopls', -- use gopls for import management
		gofmt = 'gopls', -- use gopls for formatting
		tag_transform = false,
		test_dir = '',
		comment_placeholder = '   ',
		lsp_cfg = true, -- true: use go.nvim's gopls setup
		lsp_gofumpt = true, -- enable gofumpt formatting in gopls
		lsp_on_attach = true, -- use go.nvim's default on_attach
		lsp_keymaps = true, -- set to false if you want to use your own lsp keymaps
		lsp_codelens = true, -- enable code lens
		lsp_diag_hdlr = true, -- hook diagnostic handler
		lsp_diag_underline = true,
		lsp_diag_virtual_text = { space = 0, prefix = "󰠠" }, -- show diagnostic virtual text
		lsp_diag_signs = true,
		lsp_diag_update_in_insert = false,
		lsp_document_formatting = true,
		-- DAP debug setup
		dap_debug = true, -- enable dap debug
		dap_debug_keymap = true, -- true: use default keymap
		dap_debug_gui = true, -- enable dap gui
		dap_debug_vt = true, -- enable dap virtual text
		-- Test setup
		test_runner = 'go', -- use go test command
		run_in_floaterm = true, -- run tests in floating terminal
		-- Formatter
		trouble = true, -- trouble integration
		test_efm = false, -- errorformat
		luasnip = false, -- disable luasnip integration (not installed)
		-- Build system
		build_tags = '', -- build tags
		textobjects = true, -- enable text objects
		-- Icons
		icons_cfg = {
			breakpoint = '󰏃',
			currentpos = '󰁕',
		},
	})
	
	-- ══════════════════════════════════════════════════════════════════════════════
	-- NOTE: Chezmoi template handling
	-- ══════════════════════════════════════════════════════════════════════════════
	-- Chezmoi templates like `.sh.tmpl`, `.yaml.tmpl` are detected as their base
	-- filetype (sh, yaml, etc.) via the vim.filetype.add() patterns above.
	-- This means they get the correct LSP automatically (bashls for .sh.tmpl, etc.)
	-- 
	-- The Go template syntax highlighting is provided by treesitter injections in
	-- queries/gotmpl/injections.scm, which work even when filetype is set to the
	-- base language.
	--
	-- For actual Go template files (like Helm charts), they are detected as `gotmpl`
	-- or `helm` filetype and get gopls LSP from go.nvim.
end)
