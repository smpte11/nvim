-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Treesitter Configuration                                                    │
-- │                                                                             │
-- │ Syntax highlighting, incremental selection, and code understanding.        │
-- │ Includes custom filetype detection for Go templates, Helm, and chezmoi.    │
-- │                                                                             │
-- │ Uses global: add, now (from 00-bootstrap.lua)                              │
-- └─────────────────────────────────────────────────────────────────────────────┘

now(function()
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

	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- use 'master' while monitoring updates in 'main'
		checkout = "master",
		-- perform action after every checkout
		hooks = {
			post_checkout = function()
				vim.cmd("tsupdate")
			end,
		},
	})
	-- possible to immediately execute code which depends on the added plugin
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
end)
