-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Treesitter Configuration                                                    │
-- │                                                                             │
-- │ Syntax highlighting, incremental selection, and code understanding.        │
-- │ Includes custom filetype detection for Go templates, Helm, and chezmoi.    │
-- │                                                                             │
-- │ Uses global: spec (from 00-bootstrap.lua)                                  │
-- └─────────────────────────────────────────────────────────────────────────────┘

spec({
	source = "nvim-treesitter/nvim-treesitter",
	immediate = true, -- Load immediately (critical for syntax highlighting)
	checkout = "master", -- Use 'master' while monitoring updates in 'main'
	hooks = {
		post_checkout = function()
			vim.cmd("TSUpdate")
		end,
	},
	config = function()
		-- ══════════════════════════════════════════════════════════════════════════
		-- 1. Custom filetype detection for Go templates, Helm, and chezmoi
		-- ══════════════════════════════════════════════════════════════════════════
		vim.filetype.add({
			extension = {
				gotmpl = "gotmpl",
			},
			pattern = {
				-- Helm templates (these ARE Go templates)
				[".*/templates/.*%.tpl"] = "helm",
				[".*/templates/.*%.ya?ml"] = "helm",
				["helmfile.*%.ya?ml"] = "helm",
				
				-- Chezmoi templates with embedded languages (NOT Go templates - use base language)
				-- These patterns detect chezmoi templates and set their filetype to the base language
				-- The dual LSP autocmd below will handle attaching additional language servers if needed
				[".*/%.local/share/chezmoi/.*%.sh%.tmpl$"] = "sh",
				[".*/%.local/share/chezmoi/.*%.bash%.tmpl$"] = "bash",
				[".*/%.local/share/chezmoi/.*%.ya?ml%.tmpl$"] = "yaml",
				[".*/%.local/share/chezmoi/.*%.toml%.tmpl$"] = "toml",
				[".*/%.local/share/chezmoi/.*%.json%.tmpl$"] = "json",
				[".*/%.local/share/chezmoi/.*%.nu%.tmpl$"] = "nu",
			},
		})
		
		-- ══════════════════════════════════════════════════════════════════════════
		-- 2. Treesitter configuration
		-- ══════════════════════════════════════════════════════════════════════════
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"eex",
				"elixir",
				"erlang",
				"heex",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"terraform",
				"hcl",
				"go",
				"gomod",
				"gowork",
				"gosum",
				"gotmpl",
				"helm",
			},
			auto_install = true,
			highlight = { enable = true },
		})
	end,
})
