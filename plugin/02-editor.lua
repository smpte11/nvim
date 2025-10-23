-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Editor Enhancement Plugins                                                  │
-- │                                                                             │
-- │ These plugins enhance the editing experience with text objects, operators,  │
-- │ movement, visual feedback, and editing utilities. They load asynchronously  │
-- │ after startup using later() since they're not critical for initial UI.     │
-- │                                                                             │
-- │ Includes: Text objects, operators, auto-pairs, commenting, jumping,        │
-- │           animations, alignment, and more mini.nvim editing features.      │
-- │                                                                             │
-- │ Note: Uses later() directly since these are all mini.nvim modules that     │
-- │       don't require add() - mini.nvim is already loaded in 01-core.lua.    │
-- │       Could use spec({ setup_only = true, ... }) but later() is cleaner.   │
-- │                                                                             │
-- │ Uses global: later (from 00-bootstrap.lua)                                 │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.AI - Enhanced text objects
-- ═══════════════════════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.OPERATORS - Text transformation operators
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.operators").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.PAIRS - Auto-pair brackets
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.pairs").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.KEYMAP - Keymap visualization
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.keymap").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SNIPPETS - Snippet support
-- ═══════════════════════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.COMMENT - Commenting
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.comment").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BUFREMOVE - Buffer removal
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.bufremove").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BRACKETED - Navigate with brackets
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.bracketed").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.DIFF - Diff visualization
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.diff").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MAP - Code minimap
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.map").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MISC - Miscellaneous utilities
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.misc").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ALIGN - Text alignment
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.align").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.VISITS - Track visited files
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.visits").setup()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.HIPATTERNS - Highlight patterns
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = require("mini.extra").gen_highlighter.words

	hipatterns.setup({
		highlighters = {
			-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
			fixme = hi_words({ "FIXME" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE" }, "MiniHipatternsNote"),

			-- Additional useful comment patterns
			warning = hi_words({ "WARNING", "WARN" }, "DiagnosticWarn"),
			danger = hi_words({ "DANGER", "BUG" }, "DiagnosticError"),

			-- Highlight hex color strings (`#rrggbb`) with that color
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.JUMP - Quick jumping
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.jump").setup({})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.JUMP2D - Two-dimensional jumping
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	require("mini.jump2d").setup({
		allowed_windows = {
			not_current = false,
		},
		-- Remap from <CR> to 'go' to avoid conflicts with nvim-dbee and other plugins
		mappings = {
			start_jumping = "go",
		},
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.INDENTSCOPE - Indent scope visualization
-- ═══════════════════════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ANIMATE - Smooth animations
-- ═══════════════════════════════════════════════════════════════════════════════
later(function()
	local animate = require("mini.animate")
	animate.setup({
		-- Disable scroll animations (as requested)
		scroll = {
			enable = false,
		},

		-- Smooth and quick cursor movement
		cursor = {
			enable = true,
			timing = animate.gen_timing.cubic({ duration = 80, unit = "total" }),
		},

		-- Fun window open/close animations
		open = {
			enable = true,
			timing = animate.gen_timing.exponential({ duration = 120, unit = "total" }),
		},
		close = {
			enable = true,
			timing = animate.gen_timing.exponential({ duration = 100, unit = "total" }),
		},

		-- Smooth window resizing
		resize = {
			enable = true,
			timing = animate.gen_timing.cubic({ duration = 150, unit = "total" }),
		},
	})
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MOVE - Move text
-- ═══════════════════════════════════════════════════════════════════════════════
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
