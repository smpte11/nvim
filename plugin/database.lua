-- Database plugin configuration (nvim-dbee)
-- 
-- Dependencies: nui.nvim (for UI components)
-- 
-- In the database drawer:
--   - Press "<CR>" to open connections/scratchpads and confirm menu items
--   - Press "h"/"l" to collapse/expand tree nodes
--   - Press "cw" to rename, "dd" to delete items
--   - Press "r" to refresh, "<Tab>" to toggle nodes
--   - Press "y" to yank in menus, "q"/<Esc> to close menus

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Add the plugin first
add({
	source = "kndndrj/nvim-dbee",
	depends = { "MunifTanjim/nui.nvim" },
	hooks = {
		-- Automatically install database backend binaries after plugin install/update
		post_install = function()
			vim.schedule(function()
				require("dbee").install()
			end)
		end,
		post_checkout = function()
			vim.schedule(function()
				require("dbee").install()
			end)
		end,
	},
})

-- Setup the plugin after ensuring it's loaded
later(function()
	local ok, dbee = pcall(require, "dbee")
	if not ok then
		vim.notify("nvim-dbee not loaded yet, skipping setup", vim.log.levels.WARN)
		return
	end
	
	dbee.setup({
		sources = {
			-- Load connections from a file (persisted across sessions)
			require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/connections.json"),
			-- Load connections from environment variable
			require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
			-- Memory source for temporary connections
			require("dbee.sources").MemorySource:new({}),
		},
		-- Result window configuration
		result = {
			page_size = 100, -- Number of results per page
		},
		-- Editor configuration
		editor = {
			directory = vim.fn.stdpath("cache") .. "/dbee/scratchpads",
		},
		-- UI configuration
		drawer = {
			disable_help = false,
			mappings = {
				-- manually refresh drawer
				{ key = "r", mode = "n", action = "refresh" },
				-- actions perform different stuff depending on the node:
				-- action_1 opens a note or executes a helper
				{ key = "<CR>", mode = "n", action = "action_1" },
				-- action_2 renames a note or sets the connection as active manually
				{ key = "cw", mode = "n", action = "action_2" },
				-- action_3 deletes a note or connection (removes connection from the file if you configured it like so)
				{ key = "dd", mode = "n", action = "action_3" },
				-- tree navigation:
				{ key = "h", mode = "n", action = "collapse" },
				{ key = "l", mode = "n", action = "expand" },
				{ key = "<Tab>", mode = "n", action = "toggle" },
				-- mappings for menu popups:
				{ key = "<CR>", mode = "n", action = "menu_confirm" },
				{ key = "y", mode = "n", action = "menu_yank" },
				{ key = "<Esc>", mode = "n", action = "menu_close" },
				{ key = "q", mode = "n", action = "menu_close" },
			},
		},
	})

	-- Database keymappings
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- Main controls
	keymap("n", "<leader>Do", function() require("dbee").open() end, vim.tbl_extend("force", opts, { desc = "[D]atabase [O]pen" }))
	keymap("n", "<leader>Dc", function() require("dbee").close() end, vim.tbl_extend("force", opts, { desc = "[D]atabase [C]lose" }))
	keymap("n", "<leader>Dt", function() require("dbee").toggle() end, vim.tbl_extend("force", opts, { desc = "[D]atabase [T]oggle" }))
	keymap("n", "<leader>Dn", function() require("dbee").api.ui.drawer_toggle() end, vim.tbl_extend("force", opts, { desc = "[D]atabase [N]avigator" }))

	-- Result navigation
	keymap("n", "<leader>Dl", function() require("dbee").api.ui.result_page_next() end, vim.tbl_extend("force", opts, { desc = "[D]atabase Next Page" }))
	keymap("n", "<leader>Dh", function() require("dbee").api.ui.result_page_prev() end, vim.tbl_extend("force", opts, { desc = "[D]atabase Prev Page" }))
	keymap("n", "<leader>DF", function() require("dbee").api.ui.result_page_first() end, vim.tbl_extend("force", opts, { desc = "[D]atabase First Page" }))
	keymap("n", "<leader>DL", function() require("dbee").api.ui.result_page_last() end, vim.tbl_extend("force", opts, { desc = "[D]atabase Last Page" }))

	-- Store results
	keymap("n", "<leader>Dsj", function() require("dbee").store("json", "yank", { from = 0, to = 1 }) end, vim.tbl_extend("force", opts, { desc = "[D]atabase [S]tore row as [j]son" }))
	keymap("n", "<leader>Dsc", function() require("dbee").store("csv", "yank", { from = 0, to = 1 }) end, vim.tbl_extend("force", opts, { desc = "[D]atabase [S]tore row as [c]sv" }))
	keymap("n", "<leader>DsJ", function() require("dbee").store("json", "yank", {}) end, vim.tbl_extend("force", opts, { desc = "[D]atabase [S]tore all as [J]son" }))
	keymap("n", "<leader>DsC", function() require("dbee").store("csv", "yank", {}) end, vim.tbl_extend("force", opts, { desc = "[D]atabase [S]tore all as [C]sv" }))
	keymap("n", "<leader>Dsf", function() 
		local filename = vim.fn.input("Save to file: ", vim.fn.expand("%:p:h") .. "/query_results.json")
		if filename ~= "" then
			require("dbee").store("json", "file", { extra_arg = filename })
		end
	end, vim.tbl_extend("force", opts, { desc = "[D]atabase [S]tore to [f]ile" }))

	-- Execute queries (these work in visual mode too for selected text)
	keymap({"n", "v"}, "<leader>De", "BB", vim.tbl_extend("force", opts, { desc = "[D]atabase [E]xecute query", remap = true }))

	-- Manual installation command and keymap
	vim.api.nvim_create_user_command("DbeeInstall", function()
		local install_ok, err = pcall(function()
			require("dbee").install()
		end)
		if not install_ok then
			vim.notify("Failed to install nvim-dbee backend: " .. tostring(err), vim.log.levels.ERROR)
		else
			vim.notify("nvim-dbee backend installation started", vim.log.levels.INFO)
		end
	end, { desc = "Manually install/reinstall nvim-dbee backend" })

	keymap("n", "<leader>Di", function()
		local install_ok, err = pcall(function()
			require("dbee").install()
		end)
		if not install_ok then
			vim.notify("Failed to install nvim-dbee backend: " .. tostring(err), vim.log.levels.ERROR)
		else
			vim.notify("nvim-dbee backend installation started", vim.log.levels.INFO)
		end
	end, vim.tbl_extend("force", opts, { desc = "[D]atabase [I]nstall backend" }))
end)
