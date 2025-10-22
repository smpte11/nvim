-- Uses global: add, later (from 00-bootstrap.lua)

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
