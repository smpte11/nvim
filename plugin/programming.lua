local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	-- This is a good place to add any global options you want to set for
	-- all of the plugins in this file. For example, you could set
	-- `vim.g.mapleader = " "` here, and it would be available for all
	-- of the plugins below.
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = "single", source = "if_many" },
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
	require("mason").setup({})

	add({
		source = "folke/lazydev.nvim",
	})
	require("lazydev").setup({
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

	add({
		source = "saghen/blink.cmp",
		depends = {
			"giuxtaposition/blink-cmp-copilot",
			"Kaiser-Yang/blink-cmp-git",
		},
		checkout = "v0.11.0",
	})
	require("blink.cmp").setup({
		appearance = {},
		cmdline = { enabled = false },
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
			preset = "default", -- Use default preset but disable conflicting keys
			-- Disable keys that conflict with mini.keymap
			['<Tab>'] = false,    -- Let mini.keymap handle smart tab
			['<S-Tab>'] = false,  -- Let mini.keymap handle smart shift-tab
			['<CR>'] = false,     -- Let mini.keymap handle smart enter (if using enter preset)
		},
		signature = { enabled = true, window = { border = "single" } },
		completion = {
			menu = {
				border = "single",
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
				window = { border = "single" },
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			ghost_text = { enabled = true },
		},
	})

	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu" })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "Pmenu" })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { link = "PmenuSel" })
	vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat" })
	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "NormalFloat" })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { link = "NormalFloat" })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { link = "NormalFloat" })

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
		gopls = {
			settings = {
				gopls = {
					gofumpt = true,
					codelenses = {
						gc_details = false,
						generate = true,
						regenerate_cgo = true,
						run_govulncheck = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					analyses = {
						nilness = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
					semanticTokens = true,
				},
			},
		},
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
		elixirls = {},
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
		"elixirls",
		"goimports",
		"gofumpt",
		"gomodifytags",
		"impl",
		"delve",
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
				
				-- Set up LSP server with custom handlers for consistent borders
				server.handlers = vim.tbl_deep_extend("force", server.handlers or {}, {
					["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
						border = "single",
					}),
					["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
						border = "single",
					}),
				})
				
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

-- later(function()
-- 	add({
-- 		source = "ray-x/go.nvim",
-- 		depends = {
-- 			"ray-x/guihua.lua",
-- 			"neovim/nvim-lspconfig",
-- 			"nvim-treesitter/nvim-treesitter",
-- 		},
-- 	})
--
-- 	require("go").setup()
-- end)

later(function()
	add({
		source = "scalameta/nvim-metals",
	})

	local metals_config = require("metals").bare_config()

	-- Example of settings
	metals_config.settings = {
		showImplicitArguments = true,
		excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
	}

	metals_config.init_options.statusBarProvider = "off"

	-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
	metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()

	-- Configure Metals-specific LSP handlers for consistent borders
	metals_config.handlers = {
		["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "single",
		}),
		["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "single",
		}),
	}

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
		pattern = { "scala", "sbt", "java", "sc" },
		callback = function()
			require("metals").initialize_or_attach(metals_config)
			
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

	require("typescript-tools").setup({
		handlers = {
			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			}),
			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "single",
			}),
		},
	})
end)

later(function()
	add({
		source = "nvim-neotest/neotest",
		depends = {
			"nvim-neotest/nvim-nio",
			"fredrikaverpil/neotest-golang",
			"leoluz/nvim-dap-go",
		},
	})

	require("neotest").setup({
		adapters = {
			["neotest-golang"] = {
				-- Here we can set options for neotest-golang, e.g.
				-- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
				dap_go_enabled = true, -- requires leoluz/nvim-dap-go
			},
		},
	})
end)

-- dap
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
			"leoluz/nvim-dap-go",
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

		-- You'll need to check that you have the required things installed
		-- online, please don't ask me how to install them :)
		ensure_installed = {
			-- Update this to ensure that you have the debuggers for the langs you want
			"delve",
		},
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

	dap.listeners.after.event_initialized["dapui_config"] = dapui.open
	dap.listeners.before.event_terminated["dapui_config"] = dapui.close
	dap.listeners.before.event_exited["dapui_config"] = dapui.close
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

	vim.api.nvim_set_hl(0, "NeogitChangeDeleted", { fg = Utils.palette.base08, bg = "NONE" })
end)
