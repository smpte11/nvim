local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	-- This is a good place to add any global options you want to set for
	-- all of the plugins in this file. For example, you could set
	-- `vim.g.mapleader = " "` here, and it would be available for all
	-- of the plugins below.
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = Utils.ui.border, source = "if_many" },
		underline = { severity = vim.diagnostic.severity.ERROR },
		signs = vim.g.have_nerd_font and {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
		} or {},
		virtual_text = {
			source = "if_many",
			spacing = 2,
			format = function(diagnostic)
				local diagnostic_message = {
					[vim.diagnostic.severity.ERROR] = diagnostic.message,
					[vim.diagnostic.severity.WARN] = diagnostic.message,
					[vim.diagnostic.severity.INFO] = diagnostic.message,
					[vim.diagnostic.severity.HINT] = diagnostic.message,
				}
				return diagnostic_message[diagnostic.severity]
			end,
		},
	})
end)

now(function()
	vim.filetype.add({
		extension = {
			gotmpl = "gotmpl",
		},
		pattern = {
			[".*/templates/.*%.tpl"] = "helm",
			[".*/templates/.*%.ya?ml"] = "helm",
			["helmfile.*%.ya?ml"] = "helm",
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

now(function()
	-- Use other plugins with `add()`. It ensures plugin is available in current
	-- session (installs if absent)
	add({
		source = "neovim/nvim-lspconfig",
		-- Supply dependencies near target plugin
		depends = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
	})
	require("mason").setup({
		ui = {
			border = Utils.ui.border,
		},
	})

	add({
		source = "folke/lazydev.nvim",
	})
	require("lazydev").setup({
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

local function build_blink(params)
  vim.notify('Building blink.cmp', vim.log.levels.INFO)
  local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
  if obj.code == 0 then
    vim.notify('Building blink.cmp done', vim.log.levels.INFO)
  else
    vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
  end
end

add({
  source = 'Saghen/blink.cmp',
		depends = {
			"giuxtaposition/blink-cmp-copilot",
			"Kaiser-Yang/blink-cmp-git",
		},
  hooks = {
    post_install = build_blink,
    post_checkout = build_blink,
  },
})
	require("blink.cmp").setup({
		snippets = { preset = "mini_snippets" },
		cmdline = {
			enabled = true,
			keymap = { preset = 'cmdline' },
			completion = {
				menu = {
					auto_show = function(ctx)
						return vim.fn.getcmdtype() == ":"
					end,
				},
			},
		},
		sources = {
			default = { "lsp", "lazydev", "path", "snippets", "buffer", "copilot" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
				markdown = {
					name = "RenderMarkdown",
					module = "render-markdown.integ.blink",
					fallbacks = { "lsp" },
				},
				copilot = {
					name = "copilot",
					module = "blink-cmp-copilot",
					score_offset = 100,
					async = true,
					transform_items = function(_, items)
						local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
						local kind_idx = #CompletionItemKind + 1
						CompletionItemKind[kind_idx] = "Copilot"
						for _, item in ipairs(items) do
							item.kind = kind_idx
						end
						return items
					end,
				},
				git = {
					module = "blink-cmp-git",
					name = "Git",
					enabled = function()
						return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype)
					end,
				},
			},
			per_filetype = {
				codecompanion = { "codecompanion" },
			},
		},
		keymap = {
			preset = "none",
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			["<C-e>"] = { "hide", "fallback" },
			["<C-c>"] = { "hide", "fallback" },
		},
		signature = { enabled = true, window = { border = Utils.ui.border } },
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
					default_brackets = { "(", ")" },
					override_brackets_for_filetypes = {},
					-- Disable semantic token resolution for Java/Scala to prevent unwanted parentheses on modules
					semantic_token_resolution = {
						enabled = true,
						blocked_filetypes = { "java", "scala" },
					},
				},
			},
			menu = {
				border = Utils.ui.menu_border,
				auto_show = true,
				auto_show_delay_ms = function(ctx, items) return vim.bo.filetype == 'markdown' and 1000 or 0 end,
				draw = {
					columns = {
						{ "kind_icon", "label", "label_description", gap = 1 },
						{ "kind" },
					},
					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
					},
				},
			},
			documentation = {
				window = { border = Utils.ui.border },
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			ghost_text = { enabled = true },
		},
	})

	-- Highlights are managed in lua/colors.lua

	add({
		source = "stevearc/conform.nvim",
	})
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			local lsp_format_opt
			if disable_filetypes[vim.bo[bufnr].filetype] then
				lsp_format_opt = "never"
			else
				lsp_format_opt = "fallback"
			end
			return {
				timeout_ms = 500,
				lsp_format = lsp_format_opt,
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			elixir = { "mix_format" },
			exs = { "mix_format" },
			heex = { "mix_format" },
			yaml = { "prettierd", "prettier" },
			markdown = { "prettier" },
			go = { "goimports", "gofumpt" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	})

	-- Brief aside: **What is LSP?**
	--
	-- LSP is an initialism you've probably heard, but might not understand what it is.
	--
	-- LSP stands for Language Server Protocol. It's a protocol that helps editors
	-- and language tooling communicate in a standardized fashion.
	--
	-- In general, you have a "server" which is some tool built to understand a particular
	-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
	-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
	-- processes that communicate with some "client" - in this case, Neovim!
	--
	-- LSP provides Neovim with features like:
	--  - Go to definition
	--  - Find references
	--  - Autocompletion
	--  - Symbol Search
	--  - and more!
	--
	-- Thus, Language Servers are external tools that must be installed separately from
	-- Neovim. This is where `mason` and related plugins come into play.
	--
	-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
	-- and elegantly composed help section, `:help lsp-vs-treesitter`

	-- change diagnostic symbols in the sign column (gutter)
	if vim.g.have_nerd_font then
		local signs = { error = "", warn = "", hint = "", info = "" }
		for type, icon in pairs(signs) do
			local hl = "diagnosticsign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end

	-- lsp servers and clients are able to communicate to each other what features they support.
	--  by default, neovim doesn't support everything that is in the lsp specification.
	--  when you add nvim-cmp, luasnip, etc. neovim now has *more* capabilities.
	--  so, we create new capabilities with nvim cmp, and then broadcast that to the servers.
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

	-- enable the following language servers
	--  feel free to add/remove any lsps that you want here. they will automatically be installed.
	--
	--  add any additional override configuration in the following tables. available keys are:
	--  - cmd (table): override the default command used to start the server
	--  - filetypes (table): override the default list of associated filetypes for the server
	--  - capabilities (table): override fields in capabilities. can be used to disable certain lsp features.
	--  - settings (table): override the default settings passed when initializing the server.
	--        for example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
	local servers = {
		-- clangd = {},
		-- rust_analyzer = {},
		-- ... etc. see `:help lspconfig-all` for a list of all the pre-configured lsps
		--
		-- some languages (like typescript) have entire language plugins that can be useful:
		--    https://github.com/pmizio/typescript-tools.nvim
		--
		-- but for many setups, the lsp (`ts_ls`) will work just fine
		terraformls = {},
		ts_ls = {},
		basedpyright = {
			settings = {
				basedpyright = {
					analysis = {
						autosearchpaths = true,
						diagnosticmode = "openfilesonly",
						uselibrarycodefortypes = true,
					},
				},
			},
		},
		ruff = {},
		nushell = {},
		dockerls = {},
		-- Erlang Language Platform (ELP) - WhatsApp's advanced Erlang/Elixir LSP
		-- Provides superior semantic analysis, go-to-definition, find references, call hierarchy
		-- Designed to be scalable and fully incremental, inspired by rust-analyzer
		elp = {
			cmd = { "elp", "server" },
			filetypes = { "erlang", "elixir" },
			root_dir = function(fname)
				-- Look for rebar.config, mix.exs, or .git directory
				return require("lspconfig.util").find_git_ancestor(fname)
					or require("lspconfig.util").root_pattern("rebar.config", "mix.exs", "OTP_VERSION")(fname)
			end,
			settings = {
				elp = {
					-- Enable incremental compilation for better performance
					incremental = true,
					-- Enable all diagnostics
					diagnostics = {
						enabled = true,
						-- Show warnings and errors
						disabled = {},
					},
					-- Enable code lens for additional information
					codeLens = {
						enabled = true,
					},
				},
			},
		},
		bashls = {},
		html = {},
		jsonls = {},
		yamlls = {},
		marksman = {},
		lua_ls = {
			-- cmd = { ... },
			-- filetypes = { ... },
			-- capabilities = {},
			settings = {
				lua = {
					completion = {
						callsnippet = "replace",
					},
					-- you can toggle below to ignore lua_ls's noisy `missing-fields` warnings
					diagnostics = { disable = { "missing-fields" } },
				},
			},
		},
	}

	-- ensure the servers and tools above are installed
	--
	-- to check the current status of installed tools and/or manually install
	-- other tools, you can run
	--    :mason
	--
	-- you can press `g?` for help in this menu.
	--
	-- `mason` had to be setup earlier: to configure its options see the
	-- `dependencies` table for `nvim-lspconfig` above.
	--
	-- you can add other tools here that you want mason to install
	-- for you, so that they are available from within neovim.
	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		"stylua", -- used to format lua code
		"shfmt",
		"shellcheck",
		"taplo",
		-- ELP (Erlang Language Platform) for Erlang/Elixir
		-- Note: May need manual installation if not available in Mason registry
		-- Installation: cargo install --git https://github.com/whatsapp/erlang-language-platform --bin elp
		-- Go tools are handled by ray-x/go.nvim
		-- "tflint",
	})

	local i = 1
	while i <= #ensure_installed do
		if ensure_installed[i] == "nushell" then
			table.remove(ensure_installed, i)
		else
			i = i + 1
		end
	end

	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	require("mason-lspconfig").setup({
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				-- this handles overriding only values explicitly passed
				-- by the server configuration above. useful when disabling
				-- certain features of an lsp (for example, turning off formatting for ts_ls)
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

				require("lspconfig")[server_name].setup(server)
			end,
		},
	})

end)

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

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- use 'master' while monitoring updates in 'main'
		checkout = "master",
		-- perform action after every checkout
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
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
		},
		auto_install = true,
		highlight = { enable = true },
	})
end)


later(function()
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
	})

	require("render-markdown").setup({})
end)

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
end)

later(function()
	add({
		source = "scalameta/nvim-metals",
	})

	local metals_config = require("metals").bare_config()

	-- Metals settings
	metals_config.settings = {
		showImplicitArguments = true,
		excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
	}

	metals_config.init_options.statusBarProvider = "off"

	-- Set capabilities for completion
	metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()

	-- Configure on_attach to setup DAP integration
	metals_config.on_attach = function(client, bufnr)
		-- Set up nvim-dap integration with metals
		-- This enables Scala debugging through nvim-metals
		require("metals").setup_dap()

			-- Set buffer-local keymap for metals commands picker
			if _G.MiniPick and MiniPick.registry.metals then
				vim.keymap.set("n", "<leader>lm", function()
					MiniPick.registry.metals()
				end, {
					buffer = true,
					desc = "[L]sp [M]etals Commands",
					silent = true
				})
			end

		-- Additional Scala-specific debug keymaps
		vim.keymap.set("n", "<leader>dt", function()
			require("metals").run_test()
		end, { buffer = true, desc = "[D]ebug Run [T]est" })

		vim.keymap.set("n", "<leader>dT", function()
			require("metals").test_target()
		end, { buffer = true, desc = "[D]ebug [T]est Target" })
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
		pattern = { "scala", "sbt", "java", "sc" },
		callback = function()
			require("metals").initialize_or_attach(metals_config)
		end,
	})

	-- Metals command picker for mini.pick
	-- Only works in Scala-related files (.scala, .sbt, .java, .sc)
	-- Dynamically loads available commands from metals.commands module
	if _G.MiniPick then
		MiniPick.registry.metals = function(local_opts)
			local_opts = local_opts or {}

			-- Check if we're in a Scala-related file
			local filetype = vim.bo.filetype
			local scala_filetypes = { "scala", "sbt", "java", "sc" }
			local is_scala_file = vim.tbl_contains(scala_filetypes, filetype)

			if not is_scala_file then
				vim.notify("Metals commands are only available in Scala files (.scala, .sbt, .java, .sc)", vim.log.levels.WARN)
				return
			end

			-- Check if metals LSP client is active
			local function is_metals_active()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				for _, client in ipairs(clients) do
					if client.name == "metals" then
						return true
					end
				end
				return false
			end

			if not is_metals_active() then
				vim.notify("Metals LSP client is not active in current buffer", vim.log.levels.WARN)
				return
			end

			-- Static fallback commands to avoid dynamic loading issues
			local metals_commands = {
				{ name = "Build Import", command = "metals.build-import", desc = "Import build" },
				{ name = "Build Connect", command = "metals.build-connect", desc = "Connect to build server" },
				{ name = "Build Disconnect", command = "metals.build-disconnect", desc = "Disconnect from build server" },
				{ name = "Build Restart", command = "metals.build-restart", desc = "Restart build server" },
				{ name = "Compile Cascade", command = "metals.compile-cascade", desc = "Compile current file and dependencies" },
				{ name = "Generate BSP Config", command = "metals.generate-bsp-config", desc = "Generate BSP config files" },
				{ name = "Doctor Run", command = "metals.doctor-run", desc = "Run metals doctor" },
				{ name = "Sources Scan", command = "metals.sources-scan", desc = "Scan workspace sources" },
				{ name = "New Scala File", command = "metals.new-scala-file", desc = "Create new Scala file" },
				{ name = "New Java File", command = "metals.new-java-file", desc = "Create new Java file" },
				{ name = "Restart Server", command = "metals.restart-server", desc = "Restart metals server" },
			}

			local source = {
				name = "Metals Commands",
				items = metals_commands,
				show = function(buf_id, items, query)
					local lines = {}
					for _, item in ipairs(items) do
						-- Format: "Command Name - Description"
						table.insert(lines, string.format("%-25s - %s", item.name, item.desc))
					end
					vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
				end,
				choose = function(item)
					if not item then return end
					vim.notify("Executing: " .. item.name, vim.log.levels.INFO)
					-- Execute the LSP command
					local success, err = pcall(vim.lsp.buf.execute_command, { command = item.command })
					if not success then
						vim.notify("Error executing " .. item.name .. ": " .. tostring(err), vim.log.levels.ERROR)
					end
				end,
			}

			-- Use proper MiniPick.start with explicit source
			MiniPick.start({ source = source }, local_opts)
		end
	end
end)

later(function()
	add({
		source = "pmizio/typescript-tools.nvim",
		depends = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	})

	require("typescript-tools").setup({})
end)

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
-- Comprehensive Debug Adapter Protocol (DAP) Setup
-- =====================================================
-- Supports: Python, JavaScript/TypeScript, Lua, Bash, Elixir, Erlang + Scala (via nvim-metals)
-- Features:
-- - Auto-installation of debug adapters via Mason
-- - Comprehensive debug configurations for each language
-- - Dynamic keymaps during debug sessions
-- - Virtual text showing variable values
-- - Enhanced UI with nvim-dap-ui
-- - Breakpoint management with custom icons
-- - Scala debugging via official nvim-metals DAP integration
-- - TypeScript/JavaScript debugging complements typescript-tools.nvim
-- - Elixir debugging via elixir-ls (complements ELP LSP server)
-- - Erlang: Full DAP support via Erlang LS els_dap (https://erlang-ls.github.io/articles/tutorial-debugger/)
--
-- Note: Go is handled by ray-x/go.nvim (includes LSP + DAP + testing)
-- TypeScript LSP features are handled by typescript-tools.nvim
-- Elixir/Erlang LSP features are handled by ELP (Erlang Language Platform)
-- =====================================================
later(function()
	add({
		source = "mfussenegger/nvim-dap",
		depends = {
			-- Creates a beautiful debugger UI
			"rcarriga/nvim-dap-ui",

			-- Required dependency for nvim-dap-ui
			"nvim-neotest/nvim-nio",

			-- Installs the debug adapters for you
			"mason-org/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
	})
	local dap = require("dap")
	local dapui = require("dapui")

	require("mason-nvim-dap").setup({
		-- Makes a best effort to setup the various debuggers with
		-- reasonable debug configurations
		automatic_installation = true,

		-- You can provide additional configuration to the handlers,
		-- see mason-nvim-dap README for more information
		handlers = {},

		-- Core language debuggers
		-- Note: Go uses nvim-dap-go, Scala uses nvim-metals built-in DAP
		-- TypeScript uses typescript-tools.nvim for LSP but needs separate DAP setup
		-- Elixir uses ELP for LSP and elixir-ls for DAP
		ensure_installed = {
			-- Python
			"debugpy",
			-- JavaScript/TypeScript/Node.js (complements typescript-tools.nvim)
			"js-debug-adapter",
			-- Lua
			"local-lua-debugger-vscode",
			-- Bash
			"bash-debug-adapter",
			-- Elixir (DAP support - LSP handled by ELP)
			"elixir-ls",
			-- Erlang DAP support via Erlang LS (els_dap)
			"erlang-debugger",
		},
	})

	-- =====================================================
	-- Manual DAP Adapter and Configuration Setup
	-- =====================================================
	-- Some adapters may need manual configuration for optimal functionality
	-- These complement the mason-nvim-dap automatic setup

	-- Python Configuration (debugpy)
	-- Works with basedpyright and ruff LSPs
	dap.adapters.python = function(cb, config)
		if config.request == 'attach' then
			---@diagnostic disable-next-line: undefined-field
			local port = (config.connect or config).port
			---@diagnostic disable-next-line: undefined-field
			local host = (config.connect or config).host or '127.0.0.1'
			cb({
				type = 'server',
				port = assert(port, '`connect.port` is required for a python `attach` configuration'),
				host = host,
				options = { source_filetype = 'python' },
			})
		else
			cb({
				type = 'executable',
				command = 'python3',
				args = { '-m', 'debugpy.adapter' },
				options = { source_filetype = 'python' },
			})
		end
	end

	dap.configurations.python = {
		{
			type = 'python',
			request = 'launch',
			name = 'Launch file',
			program = '${file}', -- Current file
			console = 'integratedTerminal',
			cwd = '${workspaceFolder}',
		},
		{
			type = 'python',
			request = 'launch',
			name = 'Launch file with arguments',
			program = '${file}',
			args = function()
				local args_string = vim.fn.input('Arguments: ')
				return vim.split(args_string, " +")
			end,
			console = 'integratedTerminal',
			cwd = '${workspaceFolder}',
		},
		{
			type = 'python',
			request = 'launch',
			name = 'Launch module',
			module = function()
				return vim.fn.input('Module name: ')
			end,
			console = 'integratedTerminal',
			cwd = '${workspaceFolder}',
		},
		{
			type = 'python',
			request = 'attach',
			name = 'Attach remote',
			connect = function()
				local host = vim.fn.input('Host [127.0.0.1]: ')
				host = host ~= '' and host or '127.0.0.1'
				local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
				return { host = host, port = port }
			end,
		},
	}

	-- JavaScript/TypeScript/Node.js Configuration
	-- Complements typescript-tools.nvim (which handles LSP) with debugging capabilities
	dap.adapters['pwa-node'] = {
		type = 'server',
		host = 'localhost',
		port = '${port}',
		executable = {
			command = 'js-debug-adapter',
			args = { '${port}' },
		},
	}

	dap.configurations.javascript = {
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch file',
			program = '${file}',
			cwd = '${workspaceFolder}',
		},
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch with npm script',
			runtimeExecutable = 'npm',
			runtimeArgs = function()
				local script = vim.fn.input('npm script: ')
				return { 'run', script }
			end,
			rootPath = '${workspaceFolder}',
			cwd = '${workspaceFolder}',
			console = 'integratedTerminal',
			internalConsoleOptions = 'neverOpen',
		},
		{
			type = 'pwa-node',
			request = 'attach',
			name = 'Attach to process',
			processId = require('dap.utils').pick_process,
			cwd = '${workspaceFolder}',
		},
	}

	dap.configurations.typescript = {
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch file',
			program = '${file}',
			cwd = '${workspaceFolder}',
			sourceMaps = true,
			protocol = 'inspector',
			console = 'integratedTerminal',
		},
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch with ts-node',
			runtimeExecutable = 'npx',
			runtimeArgs = { 'ts-node', '${file}' },
			cwd = '${workspaceFolder}',
			sourceMaps = true,
			protocol = 'inspector',
			console = 'integratedTerminal',
		},
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch with tsx',
			runtimeExecutable = 'npx',
			runtimeArgs = { 'tsx', '${file}' },
			cwd = '${workspaceFolder}',
			sourceMaps = true,
			protocol = 'inspector',
			console = 'integratedTerminal',
		},
		{
			type = 'pwa-node',
			request = 'attach',
			name = 'Attach to process',
			processId = require('dap.utils').pick_process,
			cwd = '${workspaceFolder}',
		},
	}

	-- Lua Configuration (local-lua-debugger-vscode)
	-- Works with lua_ls LSP
	dap.adapters['local-lua'] = {
		type = 'executable',
		command = 'local-lua-debugger-vscode',
		enrich_config = function(config, on_config)
			if not config['extensionPath'] then
				local c = vim.deepcopy(config)
				-- 💀 If you have trouble with the debugger adapter, try specifying the full path
				c.extensionPath = vim.fn.stdpath('data') .. '/mason/packages/local-lua-debugger-vscode/'
				on_config(c)
			else
				on_config(config)
			end
		end,
	}

	dap.configurations.lua = {
		{
			type = 'local-lua',
			request = 'launch',
			name = 'Debug current file (local-lua-dbg, lua)',
			program = {
				lua = 'lua',
				file = '${file}',
			},
			cwd = '${workspaceFolder}',
			args = {},
		},
		{
			type = 'local-lua',
			request = 'launch',
			name = 'Debug current file (local-lua-dbg, luajit)',
			program = {
				lua = 'luajit',
				file = '${file}',
			},
			cwd = '${workspaceFolder}',
			args = {},
		},
		{
			type = 'local-lua',
			request = 'launch',
			name = 'Debug with arguments',
			program = {
				lua = 'lua',
				file = '${file}',
			},
			args = function()
				local args_string = vim.fn.input('Arguments: ')
				return vim.split(args_string, " +")
			end,
			cwd = '${workspaceFolder}',
		},
	}

	-- Elixir Configuration (elixir-ls debug adapter)
	-- Complements ELP LSP server with debugging capabilities
	-- Uses elixir-ls debug_adapter.sh for DAP support
	dap.adapters.mix_task = {
		type = 'executable',
		command = vim.fn.stdpath("data") .. '/mason/packages/elixir-ls/debug_adapter.sh',
		args = {}
	}

	-- Erlang Configuration (using Erlang LS DAP support)
	-- Uses els_dap from Erlang LS for full Debug Adapter Protocol support
	-- See: https://erlang-ls.github.io/articles/tutorial-debugger/
	dap.adapters.erlang = {
		type = 'executable',
		command = vim.fn.stdpath("data") .. '/mason/packages/erlang-debugger/els_dap',
		args = {},
	}

	dap.configurations.elixir = {
		{
			type = "mix_task",
			name = "mix test",
			task = 'test',
			taskArgs = {"--trace"},
			request = "launch",
			startApps = true, -- for Phoenix projects
			projectDir = "${workspaceFolder}",
			requireFiles = {
				"test/**/test_helper.exs",
				"test/**/*_test.exs"
			}
		},
		{
			type = "mix_task",
			name = "mix test (current file)",
			task = 'test',
			taskArgs = {"${file}", "--trace"},
			request = "launch",
			startApps = true,
			projectDir = "${workspaceFolder}",
			requireFiles = {
				"test/**/test_helper.exs",
			}
		},
		{
			type = "mix_task",
			name = "mix run",
			task = 'run',
			taskArgs = {"--no-halt"},
			request = "launch",
			startApps = true,
			projectDir = "${workspaceFolder}",
		},
		{
			type = "mix_task",
			name = "mix phx.server",
			task = 'phx.server',
			request = "launch",
			startApps = true,
			projectDir = "${workspaceFolder}",
		},
		{
			type = "mix_task",
			name = "mix run (with args)",
			task = 'run',
			taskArgs = function()
				local args_string = vim.fn.input('Arguments: ')
				return vim.split(args_string, " +")
			end,
			request = "launch",
			startApps = true,
			projectDir = "${workspaceFolder}",
		},
	}

	-- Erlang debug configurations (using Erlang LS DAP)
	-- Full Debug Adapter Protocol support via els_dap
	-- Supports breakpoints, variable inspection, conditional breakpoints, logpoints, etc.
	-- See: https://erlang-ls.github.io/articles/tutorial-debugger/
	dap.configurations.erlang = {
		{
			type = "erlang",
			name = "Launch Erlang Project",
			request = "launch",
			cwd = "${workspaceFolder}",
			timeout = 300,
		},
		{
			type = "erlang",
			name = "Attach to Existing Node",
			request = "attach",
			projectnode = function()
				return vim.fn.input('Node name (without @hostname): ')
			end,
			cookie = function()
				return vim.fn.input('Cookie (or press Enter for default): ')
			end,
			timeout = 300,
			cwd = "${workspaceFolder}",
		},
		{
			type = "erlang",
			name = "Debug Rebar3 Project",
			request = "launch",
			projectnode = "debug_session",
			cookie = "debug_cookie",
			timeout = 300,
			cwd = "${workspaceFolder}",
			-- This will launch a node that can be attached to
			preLaunchTask = {
				type = "shell",
				command = "rebar3",
				args = {"shell", "--name", "debug_session@localhost", "--setcookie", "debug_cookie"},
			},
		},
		{
			type = "erlang",
			name = "Debug EUnit Tests",
			request = "launch",
			projectnode = "eunit_debug",
			cookie = "eunit_cookie",
			timeout = 300,
			cwd = "${workspaceFolder}",
			-- Setup for debugging EUnit tests
			preLaunchTask = {
				type = "shell",
				command = "rebar3",
				args = {"shell", "--name", "eunit_debug@localhost", "--setcookie", "eunit_cookie"},
			},
		},
	}

	-- Bash Configuration (bash-debug-adapter)
	-- Works with bashls LSP
	dap.adapters.bashdb = {
		type = 'executable',
		command = 'bash-debug-adapter',
		name = 'bashdb',
	}

	dap.configurations.sh = {
		{
			type = 'bashdb',
			request = 'launch',
			name = 'Launch file',
			showDebugOutput = true,
			pathBashdb = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
			pathBashdbLib = vim.fn.stdpath('data') .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
			trace = true,
			file = '${file}',
			program = '${file}',
			cwd = '${workspaceFolder}',
			pathCat = 'cat',
			pathBash = '/bin/bash',
			pathMkfifo = 'mkfifo',
			pathPkill = 'pkill',
			args = {},
			env = {},
			terminalKind = 'integrated',
		},
	}



	-- Advanced configuration for better debugging experience
	-- Enable virtual text for debugging (shows variable values inline)
	add({
		source = "theHamsta/nvim-dap-virtual-text",
	})
	require("nvim-dap-virtual-text").setup({
		enabled = true,
		enabled_commands = true,
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		show_stop_reason = true,
		commented = false,
		only_first_definition = true,
		all_references = false,
		clear_on_continue = false,
		display_callback = function(variable, buf, stackframe, node, options)
			if options.virt_text_pos == 'inline' then
				return ' = ' .. variable.value
			else
				return variable.name .. ' = ' .. variable.value
			end
		end,
		virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
		all_frames = false,
		virt_lines = false,
		virt_text_win_col = nil
	})

	-- Dap UI setup
	-- For more information, see |:help nvim-dap-ui|
	dapui.setup({
		-- Set icons to characters that are more likely to work in every terminal.
		--    Feel free to remove or use ones that you like more! :)
		--    Don't feel like these are good choices.
		icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
		controls = {
			icons = {
				pause = "⏸",
				play = "▶",
				step_into = "⏎",
				step_over = "⏭",
				step_out = "⏮",
				step_back = "b",
				run_last = "▶▶",
				terminate = "⏹",
				disconnect = "⏏",
			},
		},
	})

	-- Change breakpoint icons
	-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
	-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
	-- local breakpoint_icons = vim.g.have_nerd_font
	--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
	--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
	-- for type, icon in pairs(breakpoint_icons) do
	--   local tp = 'Dap' .. type
	--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
	--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
	-- end

	-- Configure breakpoint icons and highlights
	vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
	vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#e51400' })
	vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888888' })
	vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
	vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#ffcc00' })

	local breakpoint_icons = vim.g.have_nerd_font
	    and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
	  or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
	for type, icon in pairs(breakpoint_icons) do
	  local tp = 'Dap' .. type
	  local hl = (type == 'Stopped') and 'DapStopped' or 'Dap' .. type
	  vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
	end

	-- Static breakpoint keymaps (always available)
	vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end,
		{ desc = "[D]ebug Toggle [B]reakpoint" })
	vim.keymap.set("n", "<leader>dB", function()
		require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
	end, { desc = "[D]ebug Conditional [B]reakpoint" })
	vim.keymap.set("n", "<leader>dC", function() require("dap").clear_breakpoints() end,
		{ desc = "[D]ebug [C]lear All Breakpoints" })
	vim.keymap.set("n", "<leader>dl", function()
		require("dap").set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
	end, { desc = "[D]ebug [L]og Point" })

	-- Dynamic debug keymap management
	local function setup_debug_keymaps()
		-- Core debugging flow
		vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end,
			{ desc = "[D]ebug [C]ontinue/Start" })
		vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end,
			{ desc = "[D]ebug Step [I]nto" })
		vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end,
			{ desc = "[D]ebug Step [O]ver" })
		vim.keymap.set("n", "<leader>dO", function() require("dap").step_out() end,
			{ desc = "[D]ebug Step [O]ut" })
		vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end,
			{ desc = "[D]ebug [U]I Toggle" })

		-- Session management
		vim.keymap.set("n", "<leader>dr", function() require("dap").restart() end,
			{ desc = "[D]ebug [R]estart" })
		vim.keymap.set("n", "<leader>dt", function() require("dap").terminate() end,
			{ desc = "[D]ebug [T]erminate" })
		vim.keymap.set("n", "<leader>dp", function() require("dap").pause() end,
			{ desc = "[D]ebug [P]ause" })

		-- Advanced debugging
		vim.keymap.set("n", "<leader>dS", function() require("dap").run_to_cursor() end,
			{ desc = "[D]ebug Run to Cursor [S]top" })
		vim.keymap.set("n", "<leader>dU", function() require("dap").up() end,
			{ desc = "[D]ebug Stack [U]p" })
		vim.keymap.set("n", "<leader>dD", function() require("dap").down() end,
			{ desc = "[D]ebug Stack [D]own" })

		-- Evaluation & inspection
		vim.keymap.set("n", "<leader>de", function() require("dapui").eval() end,
			{ desc = "[D]ebug [E]valuate Expression" })
		vim.keymap.set("v", "<leader>de", function() require("dapui").eval() end,
			{ desc = "[D]ebug [E]valuate Selection" })
		vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end,
			{ desc = "[D]ebug [H]over Variables" })
		vim.keymap.set("n", "<leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end, { desc = "[D]ebug [S]copes" })
		vim.keymap.set("n", "<leader>df", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.frames)
		end, { desc = "[D]ebug [F]rames" })

		-- REPL
		vim.keymap.set("n", "<leader>dR", function() require("dap").repl.open() end,
			{ desc = "[D]ebug [R]EPL Open" })
		vim.keymap.set("n", "<leader>dk", function() require("dap").repl.run_last() end,
			{ desc = "[D]ebug REPL Run Last [K]ommand" })

		-- Add debug session clue to mini.clue
		table.insert(MiniClue.config.clues, { mode = "n", keys = "<leader>d", desc = "🐛 debug session" })
	end

	local function teardown_debug_keymaps()
		-- Remove debug session clue from mini.clue
		for i, entry in ipairs(MiniClue.config.clues) do
			if entry.mode == "n" and entry.keys == "<leader>d" and entry.desc == "🐛 debug session" then
				table.remove(MiniClue.config.clues, i)
				break
			end
		end

		-- Remove dynamic keymaps
		-- Core debugging flow
		pcall(vim.keymap.del, "n", "<leader>dc")
		pcall(vim.keymap.del, "n", "<leader>di")
		pcall(vim.keymap.del, "n", "<leader>do")
		pcall(vim.keymap.del, "n", "<leader>dO")
		pcall(vim.keymap.del, "n", "<leader>du")

		-- Session management
		pcall(vim.keymap.del, "n", "<leader>dr")
		pcall(vim.keymap.del, "n", "<leader>dt")
		pcall(vim.keymap.del, "n", "<leader>dp")

		-- Advanced debugging
		pcall(vim.keymap.del, "n", "<leader>dS")
		pcall(vim.keymap.del, "n", "<leader>dU")
		pcall(vim.keymap.del, "n", "<leader>dD")

		-- Evaluation & inspection
		pcall(vim.keymap.del, "n", "<leader>de")
		pcall(vim.keymap.del, "v", "<leader>de")
		pcall(vim.keymap.del, "n", "<leader>dh")
		pcall(vim.keymap.del, "n", "<leader>ds")
		pcall(vim.keymap.del, "n", "<leader>df")

		-- REPL
		pcall(vim.keymap.del, "n", "<leader>dR")
		pcall(vim.keymap.del, "n", "<leader>dk")
	end

	-- Event listeners with keymap management
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
		setup_debug_keymaps()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
		teardown_debug_keymaps()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
		teardown_debug_keymaps()
	end
end)

later(function()
	add({
		source = "neogitorg/neogit",
		depends = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"akinsho/git-conflict.nvim",
			"echasnovski/mini.pick",
		},
	})
	require("diffview").setup({
		hooks = {
			view_opened = function(_)
				table.insert(MiniClue.config.clues, { mode = "n", keys = "<leader>c", desc = " conflicts" })
			end,
			view_closed = function(_)
				for i, entry in ipairs(MiniClue.config.clues) do
					if entry.mode == "n" and entry.keys == "<leader>c" and entry.desc == " conflicts" then
						table.remove(MiniClue.config.clues, i)
						break
					end
				end
			end,
		},
	})

	require("neogit").setup({
		integrations = {
			mini_pick = true,
			fzf_lua = nil,
			telescope = nil,
			snacks = nil,
			diffview = true,
		},
	})

	-- Set up git keymaps after loading
	local keymap = vim.keymap.set
	keymap("n", "<leader>gg", function() require('neogit').open() end, { desc = "[Git] Status" })
	keymap("n", "<leader>gb", function() require('mini.extra').pickers.git_branches() end, { desc = "[Git] [B]ranches" })
	keymap("n", "<leader>gc", function() require('mini.extra').pickers.git_commits() end, { desc = "[Git] [C]ommits" })
	keymap("n", "<leader>gh", function() require('mini.extra').pickers.git_hunks() end, { desc = "[Git] [H]unks" })

	-- Highlights are managed in lua/colors.lua
end)

later(function()
	add({
		source = "f-person/git-blame.nvim",
	})

	require("gitblame").setup({
		enabled = false, -- Don't enable by default
		message_template = " <author> • <date> • <summary>",
		date_format = "%c",
		virtual_text_column = 2,
	})

	-- Set up GitBlame keymap after loading
	vim.keymap.set("n", "<leader>gB", "<cmd>GitBlameToggle<cr>", { desc = "[Git] [B]lame Toggle" })
end)
