local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local keymap = vim.keymap.set

-- chezmoi
later(function()
	add({
		source = "xvzc/chezmoi.nvim",
	})

	require("chezmoi").setup({
		edit = {
			watch = false,
			force = false,
		},
		notification = {
			on_open = true,
			on_apply = true,
			on_watch = false,
		},
	})

	--  e.g. ~/.local/share/chezmoi/*
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
		callback = function(ev)
			local bufnr = ev.buf
			local edit_watch = function()
				require("chezmoi.commands.__edit").watch(bufnr)
			end
			vim.schedule(edit_watch)
		end,
	})
end)

later(function()
	local insert_password = function()
		local command = "openssl rand -base64 18"
		for _, line in ipairs(vim.fn.systemlist(command)) do
			vim.api.nvim_put({ line }, "", true, true)
		end
	end

	local insert_uuid = function()
		local command = "uuidgen | tr A-F a-f"
		for _, line in ipairs(vim.fn.systemlist(command)) do
			vim.api.nvim_put({ line }, "", true, true)
		end
	end

	keymap("n", "<leader>ip", insert_password, { desc = "Insert Password" })
	keymap("n", "<leader>iu", insert_uuid, { desc = "Insert uuid" })

	keymap("n", "<leader>Ss", function()
		vim.cmd("wa")
		require("mini.sessions").write()
		require("mini.sessions").select()
	end, { desc = "Switch Session" })

	keymap("n", "<leader>Sw", function()
		local cwd = vim.fn.getcwd()
		local last_folder = cwd:match("([^/]+)$")
		require("mini.sessions").write(last_folder)
	end, { desc = "Save Session" })

	keymap("n", "<leader>Sf", function()
		vim.cmd("wa")
		require("mini.sessions").select()
	end, { desc = "Load Session" })
end)
