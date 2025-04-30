local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add("zk-org/zk-nvim")

	local zk = require("zk")
	zk.setup({
		piker = "minipick",
		lsp = {
			config = {
				on_attach = function(_, _)
					local function map(...)
						vim.api.nvim_buf_set_keymap(0, ...)
					end
					local opts = { noremap = true, silent = false }
					-- Create a new note in the same directory as the current buffer, using the current selection for title.
					map(
						"v",
						"<leader>nnt",
						":'<,'>ZkNewFromTitleSelection<CR>",
						vim.tbl_extend("force", opts, { desc = "Create new from selection (Title)" })
					)
					-- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
					map(
						"v",
						"<leader>nnc",
						":'<,'>ZkNewFromContentSelection { title = vim.fn.input('Title: ') }<CR>",
						vim.tbl_extend("force", opts, { desc = "Create new from selection (Content)" })
					)
				end,
			},
		},
	})

	local commands = require("zk.commands")

	commands.add("ZkNewAtDir", function(options)
		options = options or {}

		local notedir = vim.env.ZK_NOTEBOOK_DIR

		local dir = MiniPick.registry.directories(notedir)

		if dir ~= nil then
			vim.notify("Creating new note in" .. dir)
			zk.new({ dir = dir, title = vim.fn.input("Title: ") })
		else
			return
		end
	end)
end)
