-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Core Mini.nvim Plugins                                                      │
-- │                                                                             │
-- │ All mini.nvim plugins configured here. These are the foundation of the     │
-- │ configuration and most load with now() for immediate availability.         │
-- │                                                                             │
-- │ Uses global: add, now, later (from 00-bootstrap.lua)                       │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.EXTRA - Additional pickers and utilities
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.extra").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- COLORSCHEME - Using mini.base16 with custom palettes
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("colors").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SESSIONS - Session management
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.sessions").setup({ autowrite = true })
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.PICK - Fuzzy finder (our telescope replacement)
-- ═══════════════════════════════════════════════════════════════════════════════
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
			border = Utils.ui.border,
		}
	end
	
	require("mini.pick").setup({
		window = { config = win_config },
	})

	-- Use mini.pick for vim.ui.select
	vim.ui.select = MiniPick.ui_select

	-- Custom directory picker
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

		return MiniPick.start({
			source = {
				name = "Select destination directory",
				items = dirs,
			},
		})
	end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.NOTIFY - Notification manager
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SPLITJOIN - Split/join code blocks
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.splitjoin").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BASICS - Basic functionality improvements
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.basics").setup({
		options = {
			extra_ui = true, -- Extra UI features ('winblend', 'cmdheight=0', ...)
		},
		mappings = {
			windows = true,      -- Window navigation with <C-hjkl>, resize with <C-arrow>
			move_with_alt = true, -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
		},
		silent = true,
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ICONS - File icons
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	local mini_icons = require("mini.icons")
	mini_icons.setup({
		file = {
			-- Chezmoi template files
			[".chezmoiignore"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiremove"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiroot"] = { glyph = "", hl = "MiniIconsGrey" },
			[".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" },
			["bash.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["ps1.tmpl"] = { glyph = "󰨊", hl = "MiniIconsGrey" },
			["sh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			["zsh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
			-- Version files
			[".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
		},
		filetype = {
			gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
		},
		lsp = {
			copilot = { glyph = "", hl = "MiniIconsOrange" },
		},
	})
	mini_icons.mock_nvim_web_devicons()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.TABLINE - Tab line
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.tabline").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.STATUSLINE - Status line
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	-- Custom section for cursor location (LINE:COLUMN)
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SURROUND - Surround operations
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	-- Disable 's' key first (we use it for surround)
	vim.keymap.set({ "n", "x" }, "s", "<Nop>")
	
	require("mini.surround").setup({
		mappings = {
			add = "sa",            -- Add surrounding in Normal and Visual modes
			delete = "sd",         -- Delete surrounding
			find = "sf",           -- Find surrounding (to the right)
			find_left = "sF",      -- Find surrounding (to the left)
			highlight = "sh",      -- Highlight surrounding
			replace = "sr",        -- Replace surrounding
			update_n_lines = "sn", -- Update `n_lines`
		},
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.FILES - File explorer
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.files").setup({
		windows = {
			preview = true,
			width_focus = 30,
			width_preview = 50,
		},
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.STARTER - Start screen
-- ═══════════════════════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.CLUE - Keymap hints
-- ═══════════════════════════════════════════════════════════════════════════════
now(function()
	require("mini.clue").setup({
		triggers = {
			-- Leader triggers
			{ mode = "n", keys = "<leader>" },
			{ mode = "x", keys = "<leader>" },
			{ mode = "n", keys = "<localleader>" },
			{ mode = "x", keys = "<localleader>" },
			{ mode = "n", keys = "\\" },
			
			-- Built-in completion
			{ mode = "i", keys = "<c-x>" },
			
			-- `g` key
			{ mode = "n", keys = "g" },
			{ mode = "x", keys = "g" },
			
			-- Marks
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "`" },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "`" },
			
			-- Registers
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = '"' },
			{ mode = "i", keys = "<c-r>" },
			{ mode = "c", keys = "<c-r>" },
			
			-- Window commands
			{ mode = "n", keys = "<c-w>" },
			
			-- `z` key
			{ mode = "n", keys = "z" },
			{ mode = "x", keys = "z" },
			
			-- `s` key (surround)
			{ mode = "n", keys = "s" },
			{ mode = "x", keys = "s" },
		},

		clues = {
			-- Leader key descriptions
			{ mode = "n", keys = "<leader>a", desc = "󰚩 ai" },
			{ mode = "n", keys = "<leader>b", desc = "󰓩 buffer" },
			{ mode = "n", keys = "<leader>d", desc = "󰃤 debug" },
			{ mode = "n", keys = "<leader>s", desc = "󰱼 search" },
			{ mode = "n", keys = "<leader>g", desc = "󰊢 git" },
			{ mode = "n", keys = "<leader>go", desc = " octo" },
			{ mode = "n", keys = "<leader>i", desc = "󰼛 insert" },
			{ mode = "n", keys = "<leader>l", desc = "󰘦 lsp" },
			{ mode = "n", keys = "<leader>m", desc = "󰵮 mini" },
			{ mode = "n", keys = "<leader>n", desc = "󰠮 notes" },
			{ mode = "n", keys = "<leader>q", desc = "󰒲 nvim" },
			{ mode = "n", keys = "<leader>S", desc = "󰆓 session" },
			{ mode = "n", keys = "<leader>u", desc = "󰔃 ui" },
			{ mode = "n", keys = "<leader>up", desc = "󰯓 pipeline" },
			{ mode = "n", keys = "<leader>uz", desc = "󰢄 zen" },
			{ mode = "n", keys = "<leader>v", desc = "󰈙 visit" },
			{ mode = "n", keys = "<leader>w", desc = "󱂬 window" },
			{ mode = "n", keys = "<leader>f", desc = "󱧷 file" },
			
			-- Generated clues
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
			config = { width = "auto", border = Utils.ui.border },
		},
	})
end)
