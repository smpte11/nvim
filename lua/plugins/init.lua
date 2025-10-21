-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Plugin Loader                                                               │
-- │                                                                             │
-- │ This module loads all plugin configurations in the correct order.          │
-- │ Plugins are organized by purpose:                                          │
-- │   - core.lua: Mini.nvim core UI plugins (load immediately with now())      │
-- │   - editor.lua: Editor enhancements (load after startup with later())      │
-- │   - /plugin/*.lua: Auto-loaded by Neovim (ui, system, programming, etc.)   │
-- │                                                                             │
-- │ NOTE: Files in /plugin/ directory are automatically sourced by Neovim      │
-- │       after init.lua completes. We don't need to require() them.           │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Bootstrap mini.deps (sets up _G.MiniDeps globally)
require("config.bootstrap")

-- Get mini.deps functions for use in this file
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Load mini.nvim core plugins first (these use now() for immediate loading)
require("plugins.core")

-- Load editor enhancement plugins (these load asynchronously with later())
require("plugins.editor")

-- NOTE: Files in /plugin/*.lua will be automatically loaded by Neovim
-- after init.lua completes. No need to require them here.
-- This includes:
--   - /plugin/ui.lua (no-neck-pain, etc.)
--   - /plugin/system.lua (chezmoi, etc.)
--   - /plugin/programming.lua (LSP, Treesitter, languages)
--   - /plugin/ai.lua (Copilot, CodeCompanion)
--   - /plugin/notes.lua (Zk notes system)
--   - /plugin/octo.lua (GitHub integration)
--   - /plugin/pipeline.lua (CI/CD pipeline)
--   - /plugin/tmux.lua (Tmux integration)

return {}
