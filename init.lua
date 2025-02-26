vim.loader.enable()

local palette = {
	base00 = "#1F1F28",
	base01 = "#2A2A37",
	base02 = "#223249",
	base03 = "#727169",
	base04 = "#C8C093",
	base05 = "#DCD7BA",
	base06 = "#938AA9",
	base07 = "#363646",
	base08 = "#C34043",
	base09 = "#FFA066",
	base0A = "#DCA561",
	base0B = "#98BB6C",
	base0C = "#7FB4CA",
	base0D = "#7E9CD8",
	base0E = "#957FB8",
	base0F = "#D27E99",
}

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

--          ┌─────────────────────────────────────────────────────────┐
--			          Loading now
--          └─────────────────────────────────────────────────────────┘
--
now(function()
	vim.g.have_nerd_font = true
	vim.o.list = true
	vim.o.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
	vim.o.autoindent = true
	vim.o.shiftwidth = 4
	vim.o.breakindent = true
	vim.o.undofile = true
	vim.o.tabstop = 4
	vim.o.expandtab = true
	vim.o.scrolloff = 10
	vim.opt.iskeyword:append("-")
	vim.o.spelllang = "en"
	vim.o.spelloptions = "camel"
	vim.opt.complete:append("kspell")
	vim.o.path = vim.o.path .. ",**"
	vim.opt.sessionoptions:remove("blank")
	vim.o.termguicolors = true

	-- Set <space> as the leader key
	-- See `:help mapleader`
	--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
	vim.g.mapleader = " "
	vim.g.maplocalleader = ","

	-- Set to true if you have a Nerd Font installed and selected in the terminal
	vim.g.have_nerd_font = false

	-- [[ Setting options ]]
	-- See `:help vim.opt`
	-- NOTE: You can change these options as you wish!
	--  For more options, you can see `:help option-list`

	-- global statusline
	vim.opt.laststatus = 3

	-- Make line numbers default
	vim.opt.number = true
	-- You can also add relative line numbers, to help with jumping.
	--  Experiment for yourself to see if you like it!
	vim.opt.relativenumber = true

	-- Enable mouse mode, can be useful for resizing splits for example!
	vim.opt.mouse = "a"

	-- Don't show the mode, since it's already in the status line
	vim.opt.showmode = false

	-- Sync clipboard between OS and Neovim.
	--  Schedule the setting after `UiEnter` because it can increase startup-time.
	--  Remove this option if you want your OS clipboard to remain independent.
	--  See `:help 'clipboard'`
	vim.schedule(function()
		vim.opt.clipboard = "unnamedplus"
	end)

	-- Enable break indent
	vim.opt.breakindent = true

	-- Save undo history
	vim.opt.undofile = true

	-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
	vim.opt.ignorecase = true
	vim.opt.smartcase = true

	-- Keep signcolumn on by default
	vim.opt.signcolumn = "yes"

	-- Decrease update time
	vim.opt.updatetime = 250

	-- Decrease mapped sequence wait time
	vim.opt.timeoutlen = 300

	-- Configure how new splits should be opened
	vim.opt.splitright = true
	vim.opt.splitbelow = true

	-- Sets how neovim will display certain whitespace characters in the editor.
	--  See `:help 'list'`
	--  and `:help 'listchars'`
	vim.opt.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

	-- Preview substitutions live, as you type!
	vim.opt.inccommand = "split"

	-- Show which line your cursor is on
	vim.opt.cursorline = true

	-- Minimal number of screen lines to keep above and below the cursor.
	vim.opt.scrolloff = 10

	-- no swap
	vim.opt.swapfile = false
end)

now(function()
	add({
		source = "christoomey/vim-tmux-navigator",
	})
end)

now(function()
	require("mini.extra").setup()
end)

now(function()
	require("mini.base16").setup({
		palette = palette,
	})
end)

now(function()
	require("mini.sessions").setup({ autowrite = true })
end)

now(function()
	-- Centered on screen
	local win_config = function()
		local height = math.floor(0.75 * vim.o.lines)
		local width = math.floor(0.75 * vim.o.columns)
		return {
			anchor = "NW",
			height = height,
			width = width,
			row = math.floor(0.5 * (vim.o.lines - height)),
			col = math.floor(0.5 * (vim.o.columns - width)),
		}
	end
	local window = { config = win_config }
	require("mini.pick").setup({
		window = window,
	})

	vim.ui.select = MiniPick.ui_select
end)

now(function()
	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()
end)

now(function()
	require("mini.basics").setup(
		-- No need to copy this inside `setup()`. Will be used automatically.
		{
			-- Options. Set to `false` to disable.
			options = {
				-- Extra UI features ('winblend', 'cmdheight=0', ...)
				extra_ui = true,
			},

			-- Mappings. Set to `false` to disable.
			mappings = {
				-- Window navigation with <C-hjkl>, resize with <C-arrow>
				windows = true,
				-- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
				move_with_alt = true,
			},

			-- Whether to disable showing non-error feedback
			silent = true,
		}
	)
end)

now(function()
	require("mini.icons").setup({
		file = {
			[".chezmoiignore"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiremove"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiroot"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" },
			["bash.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["ps1.tmpl"] = { glyph = "󰨊", hl = "MiniIconsGrey" },
			["sh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["zsh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
		},
	})
end)

now(function()
	require("mini.tabline").setup()
end)

now(function()
	-- Simple and easy statusline.
	--  You could remove this setup call if you don't like it,
	--  and try some other statusline plugin
	local statusline = require("mini.statusline")
	-- set use_icons to true if you have a Nerd Font
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	-- You can configure sections in the statusline by overriding their
	-- default behavior. For example, here we set the section for
	-- cursor location to LINE:COLUMN
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end
end)

now(function()
	vim.keymap.set({ "n", "x" }, "s", "<Nop>")
	require("mini.surround").setup({
		add = "sa", -- Add surrounding in Normal and Visual modes
		delete = "sd", -- Delete surrounding
		find = "sf", -- Find surrounding (to the right)
		find_left = "sF", -- Find surrounding (to the left)
		highlight = "sh", -- Highlight surrounding
		replace = "sr", -- Replace surrounding
		update_n_lines = "sn", -- Update `n_lines
	})
end)

now(function()
	require("mini.files").setup({
		windows = {
			preview = true,
			width_focus = 30,
			width_preview = 50,
		},
	})
end)

now(function()
	add({
		source = "nvim-neorg/neorg",
		checkout = "v9.2.0",
		depends = {
			"nvim-neorg/lua-utils.nvim",
			"pysan3/pathlib.nvim",
			"nvim-neotest/nvim-nio",
			"nvim-treesitter",
		},
	})

	require("neorg").setup({
		load = {
			["core.defaults"] = {},
			["core.neorgcmd"] = {},
			["core.summary"] = {},
			["core.journal"] = {},
			["core.autocommands"] = {},
			["core.export"] = { config = {} },
			["core.export.markdown"] = { config = {} },
			["core.integrations.treesitter"] = { config = {} },
			["core.ui"] = {},
			["core.ui.calendar"] = {},
			["core.qol.todo_items"] = {
				config = {
					create_todo_items = true,
					create_todo_parents = true,
				},
			},
			["core.concealer"] = {
				config = {
					icons = {
						code_block = {
							conceal = true,
						},
					},
				},
			},
			["core.dirman"] = {
				config = {
					workspaces = {
						notes = "~/notes",
					},
					default_workspace = "notes",
				},
			},
		},
	})
	vim.wo.foldlevel = 99
	vim.wo.conceallevel = 2
end)

now(function()
	local utils = require("utils")
	local starter = require("mini.starter")
	starter.setup({
		header = utils.starter.header(),
		items = {
			starter.sections.sessions(3, true),
			{
				{ name = "Git Status", action = "Neogit", section = "Git" },
			},
			starter.sections.builtin_actions(),
			starter.sections.recent_files(5, false, true),
			starter.sections.recent_files(5, true, false),
			{
				{ name = "Notes", action = "Neorg index", section = "Notes" },
				{ name = "Journal", action = "Neorg journal toc open", section = "Notes" },
			},
		},
		content_hooks = {
			starter.gen_hook.indexing(
				"Notes",
				{ "Builtin actions", "Sessions", "Recent files (current directory)", "Recent files" }
			),
			starter.gen_hook.aligning("center", "center"),
			starter.gen_hook.adding_bullet(),
		},
	})
end)

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
			{
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
		gopls = {},
		groovyls = {},
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
		-- "stylua", -- used to format lua code
		-- "tflint",
	})
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

--          ┌─────────────────────────────────────────────────────────┐
--			          loading later
--          └─────────────────────────────────────────────────────────┘
later(function()
	local gen_ai_spec = MiniExtra.gen_ai_spec
	require("mini.ai").setup({
		custom_textobjects = {
			B = gen_ai_spec.buffer(),
			D = gen_ai_spec.diagnostic(),
			I = gen_ai_spec.indent(),
			L = gen_ai_spec.line(),
			N = gen_ai_spec.number(),
		},
	})
end)

later(function()
	require("mini.bracketed").setup()
end)

later(function()
	require("mini.operators").setup()
end)

later(function()
	require("mini.pairs").setup()
end)

later(function()
	require("mini.tabline").setup()
end)

later(function()
	require("mini.comment").setup()
end)

later(function()
	require("mini.bufremove").setup()
end)

later(function()
	require("mini.bracketed").setup()
end)

later(function()
	require("mini.diff").setup()
end)

later(function()
	require("mini.map").setup()
end)

later(function()
	require("mini.misc").setup()
end)

later(function()
	require("mini.align").setup()
end)

later(function()
	require("mini.visits").setup()
end)

later(function()
	require("mini.jump").setup()
end)

later(function()
	require("mini.jump2d").setup({
		allowed_windows = {
			not_current = false,
		},
		mappings = {
			start_jumping = "<C-CR>",
		},
	})
	vim.api.nvim_set_hl(0, "MiniJump2dSpot", { reverse = true })
end)

later(function()
	require("mini.indentscope").setup({
		draw = {
			animation = function()
				return 1
			end,
		},
		symbol = "│",
	})
end)

later(function()
	local animate = require("mini.animate")
	animate.setup({
		scroll = {
			-- Disable Scroll Animations, as the can interfer with mouse Scrolling
			enable = false,
		},
		cursor = {
			timing = animate.gen_timing.cubic({ duration = 50, unit = "total" }),
		},
	})
end)

later(function()
	require("mini.move").setup({
		mappings = {
			-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
			left = "<M-S-h>",
			right = "<M-S-l>",
			down = "<M-S-j>",
			up = "<M-S-k>",

			-- Move current line in Normal mode
			line_left = "<M-S-h>",
			line_right = "<M-S-l>",
			line_down = "<M-S-j>",
			line_up = "<M-S-k>",
		},
	})
end)

later(function()
	require("mini.clue").setup({
		triggers = {
			-- leader triggers
			{ mode = "n", keys = "<leader>" },
			{ mode = "x", keys = "<leader>" },

			{ mode = "n", keys = "\\" },

			-- built-in completion
			{ mode = "i", keys = "<c-x>" },

			-- `g` key
			{ mode = "n", keys = "g" },
			{ mode = "x", keys = "g" },

			-- marks
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "`" },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "`" },

			-- registers
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = '"' },
			{ mode = "i", keys = "<c-r>" },
			{ mode = "c", keys = "<c-r>" },

			-- window commands
			{ mode = "n", keys = "<c-w>" },

			-- `z` key
			{ mode = "n", keys = "z" },
			{ mode = "x", keys = "z" },

			-- `s` key
			{ mode = "n", keys = "s" },
			{ mode = "x", keys = "s" },
		},

		clues = {
			{ mode = "n", keys = "<leader>a", desc = " ai" },
			{ mode = "n", keys = "<leader>b", desc = " buffer" },
			{ mode = "n", keys = "<leader>s", desc = " search" },
			{ mode = "n", keys = "<leader>g", desc = "󰊢 git" },
			{ mode = "n", keys = "<leader>i", desc = "󰏪 insert" },
			{ mode = "n", keys = "<leader>l", desc = "󰘦 lsp" },
			{ mode = "n", keys = "<leader>m", desc = " mini" },
			{ mode = "n", keys = "<leader>n", desc = " notes" },
			{ mode = "n", keys = "<leader>q", desc = " nvim" },
			{ mode = "n", keys = "<leader>S", desc = "󰆓 session" },
			{ mode = "n", keys = "<leader>u", desc = "󰔃 ui" },
			{ mode = "n", keys = "<leader>v", desc = " visit" },
			{ mode = "n", keys = "<leader>w", desc = " window" },
			require("mini.clue").gen_clues.g(),
			require("mini.clue").gen_clues.builtin_completion(),
			require("mini.clue").gen_clues.marks(),
			require("mini.clue").gen_clues.registers(),
			require("mini.clue").gen_clues.windows(),
			require("mini.clue").gen_clues.z(),
		},
		window = {
			delay = 0,
		},
	})
end)

later(function()
	add({
		source = "neogitorg/neogit",
		depends = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "echasnovski/mini.pick" },
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
			diffview = true,
		},
	})

	vim.api.nvim_set_hl(0, "NeogitChangeDeleted", { fg = palette.base08, bg = "NONE" })
end)

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- use 'master' while monitoring updates in 'main'
		checkout = "master",
		monitor = "main",
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

later(function()
	add({
		source = "zbirenbaum/copilot.lua",
	})

	require("copilot").setup({})

	add({
		source = "olimorris/codecompanion.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})

	require("codecompanion").setup({
		strategies = {
			chat = {
				adapter = "copilot",
				keymaps = {
					close = {
						modes = { n = "q", i = "<C-c>" },
					},
				},
			},
			inline = {
				adapter = "copilot",
			},
		},
		display = {
			action_palette = {
				width = 95,
				height = 10,
				prompt = "Prompt ", -- Prompt used for interactive LLM calls
				provider = "mini_pick", -- default|telescope|mini_pick
				opts = {
					show_default_actions = true, -- Show the default actions in the action palette?
					show_default_prompt_library = true, -- Show the default prompt library in the action palette?
				},
			},
		},
	})
end)

later(function()
	add({
		source = "xvzc/chezmoi.nvim",
		depends = {
			"alker0/chezmoi.vim",
		},
	})

	require("chezmoi").setup({
		edit = {
			watch = false,
			force = false,
		},
		notification = {
			on_open = true,
			on_apply = true,
			on_watch = false,
		},
	})

	vim.g["chezmoi#use_tmp_buffer"] = 1
	vim.g["chezmoi#source_dir_path"] = os.getenv("HOME") .. "/.local/share/chezmoi"
end)

require("keymaps")
require("autocmd")
