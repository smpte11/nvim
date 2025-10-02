local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = "shortcuts/no-neck-pain.nvim",
	})

	require("no-neck-pain").setup({
		mappings = { enabled = false },
	})

	-- Create dot-repeatable zen width adjustment functions using operatorfunc
	function _G.__zen_width_increase(motion)
		if motion == nil then
			vim.o.operatorfunc = "v:lua.__zen_width_increase"
			return "g@l" -- Use minimal motion to execute immediately
		end
		-- Execute the actual width increase (called after motion)
		-- vim.v.count1 starts from 1 (unlike vim.v.count which starts from 0)
		local count = vim.v.count1
		for i = 1, count do
			vim.cmd("NoNeckPainWidthUp")
		end
	end

	function _G.__zen_width_decrease(motion)
		if motion == nil then
			vim.o.operatorfunc = "v:lua.__zen_width_decrease"  
			return "g@l" -- Use minimal motion to execute immediately
		end
		-- Execute the actual width decrease (called after motion)
		local count = vim.v.count1
		for i = 1, count do
			vim.cmd("NoNeckPainWidthDown")
		end
	end

	vim.keymap.set("n", "<leader>uzt", "<cmd>NoNeckPain<cr>", { desc = "Toggle" })
	vim.keymap.set("n", "<leader>uzl", "<cmd>NoNeckPainToggleLeftSide<cr>", { desc = "Toggle Left Side" })
	vim.keymap.set("n", "<leader>uzr", "<cmd>NoNeckPainToggleRightSide<cr>", { desc = "Toggle Right Side" })
	vim.keymap.set("n", "<leader>uz=", _G.__zen_width_increase, { expr = true, desc = "Increase Width (dot-repeatable)" })
	vim.keymap.set("n", "<leader>uz-", _G.__zen_width_decrease, { expr = true, desc = "Decrease Width (dot-repeatable)" })
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
