-- Enable faster Lua module loading
vim.loader.enable()

-- Load utilities first (provides Utils global namespace)
require("utils")

-- Load core configuration (options, keymaps, autocmds, commands)
require("config.init")

-- Load all plugin configurations
require("plugins.init")
