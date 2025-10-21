-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ Main Configuration Entry Point                                              │
-- │                                                                             │
-- │ This module loads all core configuration:                                  │
-- │   - Options (vim settings)                                                 │
-- │   - Keymaps (global keybindings)                                           │
-- │   - Autocmds (autocommands)                                                │
-- │   - Commands (user commands)                                               │
-- │   - Utils (global utilities)                                               │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Load global utilities first (provides Utils namespace)
require("utils")

-- Load core configuration
require("config.options")  -- vim.opt, vim.g settings
require("keymaps")         -- Global keymaps
require("autocmd")         -- Autocommands
require("cmd")             -- User commands
