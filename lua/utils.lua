local M = {}

M.starter = {
	header = function()
		local day = os.date("%A")
		local headers = {
			["Monday"] = [[
███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██╗
████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Tuesday"] = [[
████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║
   ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Wednesday"] = [[
██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Thursday"] = [[
████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Friday"] = [[
███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝
█████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝
██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝
██║     ██║  ██║██║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Saturday"] = [[
███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝
╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝
███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
			["Sunday"] = [[
███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝
            ]],
		}
		return headers[day]
	end,
}

M.palette = {
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

-- UUID generation utility
M.generate_uuid = function()
	-- Execute a system command and capture output as a list of lines
	-- vim.fn.systemlist(command) runs the command in the shell and returns:
	-- - A table where each element is a line of output
	-- - Empty table if command fails or produces no output
	-- "uuidgen" generates a UUID, "tr A-F a-f" converts uppercase to lowercase
	local command = "uuidgen | tr A-F a-f"
	local result = vim.fn.systemlist(command)
	
	-- Return the first line of output, or empty string if no output
	-- result[1] gets the first element of the table
	-- "or ''" provides a fallback if result[1] is nil
	return result[1] or ""
end

-- VSCode-style Command Palette Builder using MiniPick with mini.icons
M.create_command_palette = function()
	-- Define commands with their categories and actions for dynamic icon lookup
	local command_data = {
		-- File operations
		{ name = "File: Open File", category = "file", action = function() MiniPick.builtin.files() end },
		{ name = "File: Recent Files", category = "file", action = function() MiniExtra.pickers.oldfiles() end },
		{ name = "File: File Explorer", category = "directory", action = function() MiniExtra.pickers.explorer() end },
		
		-- Search operations
		{ name = "Search: Live Grep", category = "search", action = function() MiniPick.builtin.grep_live() end },
		{ name = "Search: Buffers", category = "search", action = function() MiniPick.builtin.buffers() end },
		{ name = "Search: Help", category = "search", action = function() MiniPick.builtin.help() end },
		{ name = "Search: Current Buffer Lines", category = "search", action = function() MiniExtra.pickers.buf_lines() end },
		{ name = "Search: Commands", category = "search", action = function() MiniExtra.pickers.commands() end },
		{ name = "Search: Keymaps", category = "search", action = function() MiniExtra.pickers.keymaps() end },
		{ name = "Search: Diagnostics", category = "search", action = function() MiniExtra.pickers.diagnostic() end },
		{ name = "Search: Options", category = "search", action = function() MiniExtra.pickers.options() end },
		{ name = "Search: Registers", category = "search", action = function() MiniExtra.pickers.registers() end },
		{ name = "Search: TreeSitter", category = "search", action = function() MiniExtra.pickers.treesitter() end },
		
		-- Git operations
		{ name = "Git: Status", category = "git", action = function() require('neogit').open() end },
		{ name = "Git: Branches", category = "git", action = function() MiniExtra.pickers.git_branches() end },
		{ name = "Git: Commits", category = "git", action = function() MiniExtra.pickers.git_commits() end },
		{ name = "Git: Hunks", category = "git", action = function() MiniExtra.pickers.git_hunks() end },
		
		-- LSP operations  
		{ name = "LSP: References", category = "lsp", action = function() MiniExtra.pickers.lsp({ scope = "references" }) end },
		{ name = "LSP: Definitions", category = "lsp", action = function() MiniExtra.pickers.lsp({ scope = "definition" }) end },
		{ name = "LSP: Document Symbols", category = "lsp", action = function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end },
		{ name = "LSP: Workspace Symbols", category = "lsp", action = function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end },
		
		-- Session operations
		{ name = "Session: Save Session", category = "default", icon = "󰆓", action = function()
			local cwd = vim.fn.getcwd()
			local last_folder = cwd:match("([^/]+)$")
			require('mini.sessions').write(last_folder)
			print("Session saved as: " .. last_folder)
		end },
		{ name = "Session: Load Session", category = "default", icon = "󰦛", action = function()
			vim.cmd('wa')
			require('mini.sessions').select()
		end },
		
		-- Buffer operations
		{ name = "Buffer: Close Buffer", category = "default", icon = "󰅖", action = function() MiniBufremove.delete() end },
		{ name = "Buffer: Close All Buffers", category = "default", icon = "󰱝", action = function() vim.cmd('bufdo bd') end },
		{ name = "Buffer: Next Buffer", category = "default", icon = "󰮰", action = function() vim.cmd('bnext') end },
		{ name = "Buffer: Previous Buffer", category = "default", icon = "󰮲", action = function() vim.cmd('bprevious') end },
		
		-- Window operations
		{ name = "Window: Split Horizontally", category = "default", icon = "󱂬", action = function() vim.cmd('split') end },
		{ name = "Window: Split Vertically", category = "default", icon = "󱂫", action = function() vim.cmd('vsplit') end },
		{ name = "Window: Close Window", category = "default", icon = "󰖭", action = function() vim.cmd('close') end },
		
		-- AI operations
		{ name = "AI: Chat", category = "default", icon = "󰚩", action = function() vim.cmd('CodeCompanionChat') end },
		{ name = "AI: Actions", category = "default", icon = "󰒓", action = function() vim.cmd('CodeCompanionActions') end },
		{ name = "AI: Explain", category = "default", icon = "󰙎", action = function() vim.cmd('CodeCompanionExplain') end },
		{ name = "AI: Generate", category = "default", icon = "󰦨", action = function() vim.cmd('CodeCompanionGenerate') end },
		
		-- Visits
		{ name = "Visit: Paths", category = "directory", action = function() MiniExtra.pickers.visit_paths() end },
		{ name = "Visit: Labels", category = "default", icon = "󰃃", action = function() MiniExtra.pickers.visit_labels() end },
		
		-- Neovim operations
		{ name = "Neovim: Reload Config", category = "default", icon = "󰑓", action = function() vim.cmd('source $MYVIMRC'); print("Configuration reloaded!") end },
		{ name = "Neovim: Quit", category = "default", icon = "󰗼", action = function() vim.cmd('qa') end },
		{ name = "Neovim: Write & Quit", category = "default", icon = "󰈆", action = function() vim.cmd('wqa') end },
	}
	
	-- Build display items with mini.icons and create action lookup
	local commands = {}
	local action_lookup = {}
	
	for _, cmd_info in ipairs(command_data) do
		local icon = ""
		if cmd_info.icon then
			-- Use provided icon as fallback
			icon = cmd_info.icon
		elseif cmd_info.category == "file" then
			icon = require("mini.icons").get("file", "file")
		elseif cmd_info.category == "directory" then
			icon = require("mini.icons").get("directory", "directory")
		elseif cmd_info.category == "search" then
			-- Use search-related mini.icons  
			icon = require("mini.icons").get("file", "search") or ""
		elseif cmd_info.category == "git" then
			-- Use git-related mini.icons
			icon = require("mini.icons").get("file", ".git") or "󰊢"
		elseif cmd_info.category == "lsp" then
			-- Use different LSP icons based on the operation
			local lsp_type = cmd_info.name:match("LSP: (%w+)"):lower() or "definition"
			icon = require("mini.icons").get("lsp", lsp_type)
		else
			-- Try to get mini.icons default based on the command name
			if cmd_info.name:match("Buffer:") then
				icon = require("mini.icons").get("default", "buffer") or ""
			elseif cmd_info.name:match("Window:") then
				icon = require("mini.icons").get("default", "window") or ""
			elseif cmd_info.name:match("Session:") then
				icon = require("mini.icons").get("file", ".session") or "󰆓"
			else
				icon = require("mini.icons").get("default", "default") or ""
			end
		end
		
		local display_item = icon .. " " .. cmd_info.name
		table.insert(commands, display_item)
		action_lookup[display_item] = cmd_info.action
	end
	
	local choose_action = function(item)
		local action = action_lookup[item]
		if action then
			action()
		else
			print("Command not found: " .. item)
		end
	end
	
	return MiniPick.start({
		source = {
			items = commands,
			name = "Command Palette",
			choose = choose_action,
		},
		window = {
			config = function()
				local height = math.floor(0.8 * vim.o.lines)
				local width = math.floor(0.7 * vim.o.columns)
				return {
					anchor = "NW",
					height = height,
					width = width,
					row = math.floor(0.1 * vim.o.lines),
					col = math.floor(0.5 * (vim.o.columns - width)),
				}
			end
		}
	})
end

_G.Utils = M
