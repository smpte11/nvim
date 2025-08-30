local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local keymap = vim.keymap.set

later(function()
	add({
		source = "shortcuts/no-neck-pain.nvim",
	})

	require("no-neck-pain").setup({
		mappings = { enabled = false },
	})

	vim.keymap.set("n", "<leader>uzt", "<cmd>NoNeckPain<cr>", { desc = "Toggle" })
	vim.keymap.set("n", "<leader>uzl", "<cmd>NoNeckPainToggleLeftSide<cr>", { desc = "Toggle Left Side" })
	vim.keymap.set("n", "<leader>uzr", "<cmd>NoNeckPainToggleRightSide<cr>", { desc = "Toggle Right Side" })
	vim.keymap.set("n", "<leader>uz=", "<cmd>NoNeckPainWidthUp<cr>", { desc = "Increase Width" })
	vim.keymap.set("n", "<leader>uz-", "<cmd>NoNeckPainWidthDown<cr>", { desc = "Decrease Width" })
	vim.keymap.set("n", "<leader>uzs", "<cmd>NoNeckPainScratchPad<cr>", { desc = "Toggle ScratchPad" })
end)

later(function()
	add({
		source = "HakonHarnes/img-clip.nvim",
		--rocks = { "magick" }, -- Example of rock
	})

	require("img-clip").setup({
		-- add options here
		-- or leave it empty to use the default settings
	})
end)

later(function()
	local split_sensibly = function()
		if vim.api.nvim_win_get_width(0) > math.floor(vim.api.nvim_win_get_height(0) * 2.3) then
			vim.cmd("vs")
		else
			vim.cmd("split")
		end
	end
	keymap("n", "<leader>ws", split_sensibly, { desc = "[S]plit [S]ensibly", remap = true })
	keymap("n", "<leader>wh", "<C-W>s", { desc = "Split [W]indow [H]orizontally", remap = true })
	keymap("n", "<leader>wv", "<C-W>v", { desc = "Split [W]indow [V]ertically", remap = true })
	keymap("n", "<leader>wd", "<C-W>c", { desc = "[W]indow [D]elete", remap = true })

	keymap("n", "<leader>ui", "<cmd>PasteImage<cr>", { desc = "[U]I Paste [I]mage" })

	keymap("n", "<leader>fp", function()
		MiniExtra.pickers.explorer()
	end, { desc = "[U]I [F]ile Picker" })
	keymap("n", "<leader>ff", function()
		MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
	end, { desc = "[U]I [F]ile Explorer" })
	keymap("n", "<leader>fF", function()
		MiniFiles.open(vim.uv.cwd(), true)
	end, { desc = "[U]I [F]ile Explorer (cwd)" })

	keymap("n", "<leader>vp", function()
		MiniExtra.pickers.visit_paths()
	end, { desc = "[V]isit [P]aths" })
	keymap("n", "<leader>vl", function()
		MiniExtra.pickers.visit_labels()
	end, { desc = "[V]isit [L]abels" })

	local map_vis = function(keys, call, desc)
		local rhs = "<Cmd>lua MiniVisits." .. call .. "<CR>"
		vim.keymap.set("n", "<Leader>" .. keys, rhs, { desc = desc })
	end

	map_vis("va", "add_label()", "[A]dd Label")
	map_vis("vr", "remove_label()", "[R]emove Label")
end)
