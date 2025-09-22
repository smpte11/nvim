vim.loader.enable()
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		-- Uncomment next line to use 'stable' branch
		-- '--branch', 'stable',
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
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

require("utils")

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
	require("mini.extra").setup()
end)

now(function()
	require("mini.base16").setup({
		palette = Utils.palette,
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

	MiniPick.registry.directories = function(path)
		local dirs = {}
		local handle = vim.loop.fs_scandir(path or vim.fn.getcwd())
		if handle then
			while true do
				local name, type = vim.loop.fs_scandir_next(handle)
				if not name then
					break
				end
				if type == "directory" and not name:match("^%.") then
					table.insert(dirs, name)
				end
			end
		end

		-- TODO: could be useful in other contexts. Check to add to registry
		return MiniPick.start({ source = {
			name = "Select destination directory",
			items = dirs,
		} })
	end
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
	local mini_icons = require("mini.icons")
	mini_icons.setup({
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
			[".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
		},
		filetype = {
			gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
		},
		lsp = {
			copilot = { glyph = "", hl = "MiniIconsOrange" },
		},
	})
	mini_icons.mock_nvim_web_devicons()
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
	local starter = require("mini.starter")
	starter.setup({
		header = Utils.starter.header(),
		items = {
			starter.sections.sessions(3, true),
			{
				{ name = "Git Status", action = "Neogit", section = "Git" },
			},
			starter.sections.builtin_actions(),
			starter.sections.recent_files(5, false, true),
			starter.sections.recent_files(5, true, false),
			{
				{ name = "Notes", action = "ZkNotes { sort = { 'modified' } }", section = "Notes" },
				{ name = "Dashboard 📈", action = "ZkDashboard", section = "Productivity" },
				{ name = "Journal", action = "ZkNew { dir = 'journal/daily', date = 'today' }", section = "Notes" },
				{ name = "Today's Overview 📅", action = "ZkToday", section = "Productivity" },
				{ name = "Yesterday Review 📊", action = "ZkYesterday", section = "Productivity" },
				{ name = "Weekly Progress 📋", action = "ZkWeekly", section = "Productivity" },
				{ name = "Friday Review 🎉", action = "ZkFridayReview", section = "Productivity" },
				{ name = "Create Task ✅", action = "ZkNewTask", section = "Productivity" },
			},
		},
		content_hooks = {
			starter.gen_hook.aligning("center", "center"),
			starter.gen_hook.adding_bullet(),
		},
	})
end)

now(function()
	require("mini.clue").setup({
		triggers = {
			-- leader triggers
			{ mode = "n", keys = "<leader>" },
			{ mode = "x", keys = "<leader>" },

			{ mode = "n", keys = "<localleader>" },
			{ mode = "x", keys = "<localleader>" },

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
			{ mode = "n", keys = "<leader>d", desc = " debug" },
			{ mode = "n", keys = "<leader>D", desc = "󰆼 database" },
			{ mode = "n", keys = "<leader>Ds", desc = "󰆼 store results" },
			{ mode = "n", keys = "<leader>s", desc = " search" },
			{ mode = "n", keys = "<leader>g", desc = "󰊢 git" },
			{ mode = "n", keys = "<leader>go", desc = " octo" },
			{ mode = "n", keys = "<leader>l", desc = "󰘦 lsp" },
			{ mode = "n", keys = "<leader>m", desc = " mini" },
			{ mode = "n", keys = "<leader>n", desc = " notes" },
			{ mode = "n", keys = "<leader>q", desc = " nvim" },
			{ mode = "n", keys = "<leader>S", desc = "󰆓 session" },
			{ mode = "n", keys = "<leader>u", desc = "󰔃 ui" },
			{ mode = "n", keys = "<leader>up", desc = "󰯓 pipeline" },
			{ mode = "n", keys = "<leader>uz", desc = "󰢄 zen" },
			{ mode = "n", keys = "<leader>v", desc = " visit" },
			{ mode = "n", keys = "<leader>w", desc = " window" },
			{ mode = "n", keys = "<leader>f", desc = "󱧷 file" },
			require("mini.clue").gen_clues.g(),
			require("mini.clue").gen_clues.builtin_completion(),
			require("mini.clue").gen_clues.marks(),
			require("mini.clue").gen_clues.registers(),
			require("mini.clue").gen_clues.windows({
				submode_move = true,
				submode_navigate = true,
				submode_resize = true,
			}),
			require("mini.clue").gen_clues.z(),
		},
		window = {
			delay = 0,
			config = {
				width = "auto",
			},
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
	require("mini.operators").setup()
end)

later(function()
	require("mini.pairs").setup()
end)

later(function()
	local gen_loader = require("mini.snippets").gen_loader
	require("mini.snippets").setup({
		snippets = {
			-- Load custom file with global snippets first (adjust for Windows)
			gen_loader.from_file("~/.config/nvim/snippets/global.json"),

			-- Load snippets based on current language by reading files from
			-- "snippets/" subdirectories from 'runtimepath' directories.
			gen_loader.from_lang(),
		},
	})
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
		-- Remap from <CR> to 'go' to avoid conflicts with nvim-dbee and other plugins
		mappings = {
			start_jumping = 'go',
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

require("keymaps")
require("autocmd")
require("cmd")
