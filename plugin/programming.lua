local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	-- Use other plugins with `add()`. It ensures plugin is available in current
	-- session (installs if absent)
	add({
		source = "neovim/nvim-lspconfig",
		-- Supply dependencies near target plugin
		depends = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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
		},
		checkout = "v0.11.0",
	})
	require("blink.cmp").setup({
		appearance = {},
		sources = {
			default = { "lsp", "lazydev", "path", "snippets", "buffer", "copilot" },
			cmdline = {},
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
				},
			},
			per_filetype = {
				codecompanion = { "codecompanion" },
			},
		},
		keymap = {
			preset = "enter",
			["<C-y>"] = { "select_and_accept" },
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
							-- customize the drawing of kind icons
							ellipsis = false,
							text = function(ctx)
								-- default kind icon
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								-- if LSP source, check for color derived from documentation
								if ctx.item.source_name == "LSP" then
									local color_item = require("nvim-highlight-colors").format(
										ctx.item.documentation,
										{ kind = ctx.kind }
									)
									if color_item and color_item.abbr then
										kind_icon = color_item.abbr
									end
								end
								return kind_icon .. ctx.icon_gap
							end,
							highlight = function(ctx)
								-- default highlight group
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								local highlight = "BlinkCmpKind" .. hl
								-- if LSP source, check for color derived from documentation
								if ctx.item.source_name == "LSP" then
									local color_item = require("nvim-highlight-colors").format(
										ctx.item.documentation,
										{ kind = ctx.kind }
									)
									if color_item and color_item.abbr_hl_group then
										highlight = color_item.abbr_hl_group
									end
								end
								return highlight
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
			yaml = { "prettierd", "prettier" },
			markdown = { "prettier" },
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
					-- diagnostics = { disable = { 'missing-fields' } },
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

	later(function()
		add({
			source = "nvim-treesitter/nvim-treesitter",
			-- use 'master' while monitoring updates in 'main'
			checkout = "master",
			monitor = "main",
			-- perform action after every checkout
			hooks = {
				post_checkout = function()
					vim.cmd("TsUpdate")
				end,
			},
		})
		-- possible to immediately execute code which depends on the added plugin
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"diff",
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
				"norg",
				"norg_meta",
			},
			auto_install = true,
			highlight = { enable = true },
		})
	end)

	later(function()
		add({
			source = "brenoprata10/nvim-highlight-colors",
		})

		require("nvim-highlight-colors").setup({})
	end)

	later(function()
		add({
			source = "MeanderingProgrammer/render-markdown.nvim",
		})

		require("render-markdown").setup({})
	end)

	later(function()
		add({
			source = "ray-x/go.nvim",
			depends = {
				"ray-x/guihua.lua",
				"neovim/nvim-lspconfig",
				"nvim-treesitter/nvim-treesitter",
			},
		})

		vim.api.nvim_create_autocmd("CmdlineEnter", {
			pattern = { "go", "gomod" },
			callback = function()
				require("go").setup()
			end,
		})
	end)

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

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
			pattern = { "scala", "sbt", "java" },
			callback = function()
				require("metals").initialize_or_attach(metals_config)
			end,
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
				"williamboman/mason.nvim",
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
			source = "akinsho/git-conflict.nvim",
		})
		add({
			source = "neogitorg/neogit",
			depends = {
				"nvim-lua/plenary.nvim",
				-- "sindrets/diffview.nvim",
				"akinsho/git-conflict.nvim",
				"echasnovski/mini.pick",
			},
		})
		-- require("diffview").setup({
		-- 	hooks = {
		-- 		view_opened = function(_)
		-- 			table.insert(MiniClue.config.clues, { mode = "n", keys = "<leader>c", desc = " conflicts" })
		-- 		end,
		-- 		view_closed = function(_)
		-- 			for i, entry in ipairs(MiniClue.config.clues) do
		-- 				if entry.mode == "n" and entry.keys == "<leader>c" and entry.desc == " conflicts" then
		-- 					table.remove(MiniClue.config.clues, i)
		-- 					break
		-- 				end
		-- 			end
		-- 		end,
		-- 	},
		-- })
		require("git-conflict").setup()

		require("neogit").setup({
			integrations = {
				mini_pick = true,
				diffview = true,
			},
		})

		vim.api.nvim_set_hl(0, "NeogitChangeDeleted", { fg = Utils.palette.base08, bg = "NONE" })
	end)
end)
