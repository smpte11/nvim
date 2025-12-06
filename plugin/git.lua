-- Uses global: spec (from 00-bootstrap.lua)

-- Diffview - Git diff viewer with automatic 3-way merge support
spec({
	source = "sindrets/diffview.nvim",
	depends = { "nvim-lua/plenary.nvim" },
	config = function()
		local actions = require("diffview.actions")
		require("diffview").setup({
			enhanced_diff_hl = true,
			keymaps = {
				view = {
					-- Move default <leader> mappings to <leader>gc submenu
					{ "n", "<leader>e", false }, -- Disable default
					{ "n", "<leader>b", false }, -- Disable default
					{
						"n",
						"<leader>gcpe",
						actions.focus_files,
						{ desc = "[Commit/Diff] [P]anel focus" },
					},
					{
						"n",
						"<leader>gcpt",
						actions.toggle_files,
						{ desc = "[Commit/Diff] [P]anel [T]oggle" },
					},
					-- Conflict resolution mappings under <leader>gc
					{ "n", "<leader>co", false }, -- Disable default
					{ "n", "<leader>ct", false }, -- Disable default
					{ "n", "<leader>cb", false }, -- Disable default
					{ "n", "<leader>ca", false }, -- Disable default
					{ "n", "<leader>cO", false }, -- Disable default
					{ "n", "<leader>cT", false }, -- Disable default
					{ "n", "<leader>cB", false }, -- Disable default
					{ "n", "<leader>cA", false }, -- Disable default
					{
						"n",
						"<leader>gco",
						actions.conflict_choose("ours"),
						{ desc = "[Commit/Diff] Conflict: choose [O]urs" },
					},
					{
						"n",
						"<leader>gct",
						actions.conflict_choose("theirs"),
						{ desc = "[Commit/Diff] Conflict: choose [T]heirs" },
					},
					{
						"n",
						"<leader>gcb",
						actions.conflict_choose("base"),
						{ desc = "[Commit/Diff] Conflict: choose [B]ase" },
					},
					{
						"n",
						"<leader>gca",
						actions.conflict_choose("all"),
						{ desc = "[Commit/Diff] Conflict: choose [A]ll" },
					},
					{
						"n",
						"<leader>gcO",
						actions.conflict_choose_all("ours"),
						{ desc = "[Commit/Diff] Conflict: [O]urs (whole file)" },
					},
					{
						"n",
						"<leader>gcT",
						actions.conflict_choose_all("theirs"),
						{ desc = "[Commit/Diff] Conflict: [T]heirs (whole file)" },
					},
					{
						"n",
						"<leader>gcB",
						actions.conflict_choose_all("base"),
						{ desc = "[Commit/Diff] Conflict: [B]ase (whole file)" },
					},
					{
						"n",
						"<leader>gcA",
						actions.conflict_choose_all("all"),
						{ desc = "[Commit/Diff] Conflict: [A]ll (whole file)" },
					},
				},
				file_panel = {
					-- Move default <leader> mappings to <leader>gc submenu
					{ "n", "<leader>e", false }, -- Disable default
					{ "n", "<leader>b", false }, -- Disable default
					{
						"n",
						"<leader>gcpe",
						actions.focus_files,
						{ desc = "[Commit/Diff] [P]anel focus" },
					},
					{
						"n",
						"<leader>gcpt",
						actions.toggle_files,
						{ desc = "[Commit/Diff] [P]anel [T]oggle" },
					},
					-- Conflict resolution in file panel
					{ "n", "<leader>cO", false }, -- Disable default
					{ "n", "<leader>cT", false }, -- Disable default
					{ "n", "<leader>cB", false }, -- Disable default
					{ "n", "<leader>cA", false }, -- Disable default
					{
						"n",
						"<leader>gcO",
						actions.conflict_choose_all("ours"),
						{ desc = "[Commit/Diff] Conflict: [O]urs (whole file)" },
					},
					{
						"n",
						"<leader>gcT",
						actions.conflict_choose_all("theirs"),
						{ desc = "[Commit/Diff] Conflict: [T]heirs (whole file)" },
					},
					{
						"n",
						"<leader>gcB",
						actions.conflict_choose_all("base"),
						{ desc = "[Commit/Diff] Conflict: [B]ase (whole file)" },
					},
					{
						"n",
						"<leader>gcA",
						actions.conflict_choose_all("all"),
						{ desc = "[Commit/Diff] Conflict: [A]ll (whole file)" },
					},
				},
				file_history_panel = {
					-- Move default <leader> mappings to <leader>gc submenu
					{ "n", "<leader>e", false }, -- Disable default
					{ "n", "<leader>b", false }, -- Disable default
					{ "n", "<leader>gcpe", actions.focus_files, { desc = "[Commit/Diff] [P]anel focus" } },
					{ "n", "<leader>gcpt", actions.toggle_files, { desc = "[Commit/Diff] [P]anel [T]oggle" } },
				},
			},
		})
	end,
    -- stylua: ignore start
    keys = {
        { "<leader>gcd", "<cmd>DiffviewOpen<cr>",                    desc = "[Commit/Diff] [D]iffview Open (auto 3-way merge)" },
        { "<leader>gcD", "<cmd>DiffviewClose<cr>",                   desc = "[Commit/Diff] [D]iffview Close" },
        { "<leader>gcf", "<cmd>DiffviewFileHistory %<cr>",           desc = "[Commit/Diff] [F]ile History" },
        { "<leader>gcF", "<cmd>DiffviewFileHistory<cr>",             desc = "[Commit/Diff] [F]ile History (All)" },
        { "<leader>gcm", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "[Commit/Diff] [M]erge Base Diff" },
    },
	-- stylua: ignore end
})

-- Neogit - Git interface
spec({
	source = "neogitorg/neogit",
	depends = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"echasnovski/mini.pick",
	},
	config = function()
		require("neogit").setup({
			integrations = {
				mini_pick = true,
				fzf_lua = false,
				telescope = false,
				snacks = false,
				diffview = true,
			},
		})
	end,
    -- stylua: ignore start
    keys = {
        { "<leader>gg",  function() require("neogit").open() end,                     desc = "[Git] Status" },
        { "<leader>gb",  function() require("mini.extra").pickers.git_branches() end, desc = "[Git] [B]ranches" },
        { "<leader>gcc", function() require("mini.extra").pickers.git_commits() end,  desc = "[Commit/Diff] [C]ommits" },
        { "<leader>gH",  function() require("mini.extra").pickers.git_hunks() end,    desc = "[Git] [H]unks" },
    },
	-- stylua: ignore end
})

-- Git Blame
spec({
	source = "f-person/git-blame.nvim",
	config = function()
		require("gitblame").setup({
			enabled = false, -- Don't enable by default
			message_template = " <author> • <date> • <summary>",
			date_format = "%c",
			virtual_text_column = 2,
		})
	end,
    -- stylua: ignore start
    keys = {
        { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "[Git] [B]lame Toggle" },
    },
	-- stylua: ignore end
})

-- fzf-lua - Fuzzy finder (used by octo.nvim)
-- spec({
-- 	source = "ibhagwan/fzf-lua",
-- 	depends = { "echasnovski/mini.icons" },
-- 	immediate = true,
-- 	config = function()
-- 		require("fzf-lua").setup({
-- 			winopts = {
-- 				border = "double",
-- 				preview = {
-- 					border = "double",
-- 					scrollbar = "border",
-- 				},
-- 			},
-- 			fzf_opts = {
-- 				["--layout"] = "reverse",
-- 				["--info"] = "inline",
-- 			},
-- 		})
-- 	end,
-- })

-- Octo - GitHub integration
spec({
	source = "pwntester/octo.nvim",
	depends = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("octo").setup({
			enable_builtin = true, -- Enable builtin actions menu
			picker = "default",
			picker_config = {
				use_emojis = true,
			},
			default_remote = { "upstream", "origin" }, -- order to try remotes
			default_merge_method = "squash", -- default merge method
			ssh_aliases = {
				["me.github.com"] = "github.com", -- Map SSH alias to github.com
				["kivra.github.com"] = "github.com", -- Map work SSH alias to github.com
			},
			timeout = 5000, -- timeout for requests
			gh_env = {
				GH_PROMPT_DISABLED = "1", -- Disable interactive prompts in gh CLI
			},
		})
	end,
    -- stylua: ignore start
    keys = {
        -- GitHub integration (grouped under <leader>gh to match snacks conventions)
        { "<leader>ghi", "<cmd>Octo issue list<cr>",           desc = "[GitHub] [I]ssues (open)" },
        { "<leader>ghI", "<cmd>Octo issue list state=all<cr>", desc = "[GitHub] [I]ssues (all)" },
        { "<leader>ghp", "<cmd>Octo pr list<cr>",              desc = "[GitHub] [P]ull Requests (open)" },
        { "<leader>ghP", "<cmd>Octo pr list state=all<cr>",    desc = "[GitHub] [P]ull Requests (all)" },
        { "<leader>gha", "<cmd>Octo actions<cr>",              desc = "[GitHub] [A]ctions" },
        { "<leader>ghc", "<cmd>Octo issue create<cr>",         desc = "[GitHub] [C]reate Issue" },
        { "<leader>ghC", "<cmd>Octo pr create<cr>",            desc = "[GitHub] [C]reate PR" },
        { "<leader>ghr", "<cmd>Octo review start<cr>",         desc = "[GitHub] Start [R]eview" },
        { "<leader>ghs", "<cmd>Octo review submit<cr>",        desc = "[GitHub] [S]ubmit Review" },
    },
	-- stylua: ignore end
})
