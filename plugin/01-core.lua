-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Core Mini.nvim Plugins                                                      │
-- │                                                                             │
-- │ All mini.nvim plugins configured here. These are the foundation of the     │
-- │ configuration and most load immediately for UI/functionality.              │
-- │                                                                             │
-- │ Note: All mini.nvim modules use setup_only=true since mini.nvim is already │
-- │       loaded in 00-bootstrap.lua. We only need to configure them.          │
-- │                                                                             │
-- │ Uses global: spec (from 00-bootstrap.lua)                                  │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.EXTRA - Additional pickers and utilities
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.extra").setup()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.COLORS - Color manipulation utilities (needed for transparency)
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        -- No setup needed, just ensure it's loaded before colorscheme
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- COLORSCHEME - Using mini.base16 with custom palettes
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("config.colors").setup()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SESSIONS - Session management
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.sessions").setup({ autowrite = true })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.PICK - Fuzzy finder (our telescope replacement)
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
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
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.NOTIFY - Notification manager
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.notify").setup()
        vim.notify = require("mini.notify").make_notify()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.CMDLINE - Better command line
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.cmdline").setup()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SPLITJOIN - Split/join code blocks
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.splitjoin").setup()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.HIPATTERNS - Highlight patterns in text
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
            highlighters = {
                -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

                -- Highlight hex color strings (`#rrggbb`) using that color
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.BASICS - Basic functionality improvements
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.basics").setup({
            options = {
                extra_ui = true, -- Extra UI features ('winblend', 'cmdheight=0', ...)
            },
            mappings = {
                windows = true,       -- Window navigation with <C-hjkl>, resize with <C-arrow>
                move_with_alt = true, -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
            },
            silent = true,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.ICONS - Icon provider
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.icons").setup()
        MiniIcons.mock_nvim_web_devicons()

        -- Custom filetypes
        MiniIcons.config.file["gotmpl"] = { glyph = "󰟓", hl = "MiniIconsBlue" }
        MiniIcons.config.file[".go-version"] = { glyph = "󰟓", hl = "MiniIconsBlue" }
        MiniIcons.config.file[".mise.toml"] = { glyph = "", hl = "MiniIconsOrange" }
        MiniIcons.config.extension["tmpl"] = { glyph = "󰈙", hl = "MiniIconsGrey" }
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.TABLINE - Tabline display
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.tabline").setup()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.STATUSLINE - Statusline
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        local statusline = require("config.statusline")

        require("mini.statusline").setup({
            content = {
                active = statusline.active,
            },
            use_icons = true, -- Explicitly enable icons (you have mini.icons configured)
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.SURROUND - Surround operations
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
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
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.FILES - File explorer
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        require("mini.files").setup({
            windows = {
                preview = true,
                width_focus = 30,
                width_preview = 50,
            },
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.STARTER - Start screen
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
        local starter = require("mini.starter")
        starter.setup({
            header = Utils.starter.header(),
            items = {
                starter.sections.sessions(5, true),
                {
                    { name = "Git Status", action = function() require("neogit").open() end, section = "Git" },
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
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- MINI.CLUE - Keymap hints
-- ═══════════════════════════════════════════════════════════════════════════════
spec({
    setup_only = true,
    immediate = true,
    config = function()
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
                -- Leader key descriptions (Normal mode)
                { mode = "n", keys = "<leader>a", desc = "󰚩 ai" },
                { mode = "n", keys = "<leader>b", desc = "󰓩 buffer" },
                { mode = "n", keys = "<leader>d", desc = "󰃤 debug" },
                { mode = "n", keys = "<leader>e", desc = "󰌌 editor" },
                { mode = "n", keys = "<leader>s", desc = "󰱼 search" },
                { mode = "n", keys = "<leader>g", desc = "󰊢 git" },
                { mode = "n", keys = "<leader>gh", desc = " github" },
                { mode = "n", keys = "<leader>gc", desc = " conflict" },
                { mode = "n", keys = "<leader>gd", desc = " diff" },
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

                -- Leader key descriptions (Visual/Select modes)
                { mode = "x", keys = "<leader>a", desc = "󰚩 ai" },
                { mode = "x", keys = "<leader>l", desc = "󰘦 lsp" },

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
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════

