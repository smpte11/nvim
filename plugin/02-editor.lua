-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Editor Enhancement Plugins                                                  │
-- │                                                                             │
-- │ These plugins enhance the editing experience with text objects, operators,  │
-- │ movement, visual feedback, and editing utilities.                          │
-- │                                                                             │
-- │ Includes: Text objects, operators, auto-pairs, commenting, jumping,        │
-- │           animations, alignment, and more mini.nvim editing features.      │
-- │                                                                             │
-- │ All mini.nvim modules use spec({ setup_only = true }) since mini.nvim      │
-- │ is already loaded in 01-core.lua.                                          │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.AI - Enhanced text objects
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
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
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.OPERATORS - Text transformation operators
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.operators").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.PAIRS - Auto-pair brackets
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.pairs").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.KEYMAP - Keymap visualization
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.keymap").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SNIPPETS - Snippet support
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
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
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.COMMENT - Commenting
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.comment").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BUFREMOVE - Buffer removal
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.bufremove").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.JUMP - Enhanced jumping
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.jump").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.JUMP2D - 2D jumping
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.jump2d").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BRACKETED - Bracketed movements
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.bracketed").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MOVE - Move lines and selections
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.move").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.HIPATTERNS - Highlight patterns
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.hipatterns").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.TRAILSPACE - Trailing space management
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.trailspace").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.DIFF - Diff visualization
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.diff").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MAP - Code minimap
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.map").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.MISC - Miscellaneous utilities
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.misc").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ALIGN - Text alignment
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.align").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.VISITS - Track visited files
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.visits").setup()
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.INDENTSCOPE - Indent scope visualization
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
		require("mini.indentscope").setup({
			draw = {
				animation = function()
					return 1
				end,
			},
			symbol = "│",
		})
	end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ANIMATE - Smooth animations
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
	setup_only = true,
	config = function()
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
	end,
})
