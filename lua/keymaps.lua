-- ╔═══════════════════════╗
-- ║    Local Variables    ║
-- ╚═══════════════════════╝
local keymap = vim.keymap.set

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

local split_sensibly = function()
	if vim.api.nvim_win_get_width(0) > math.floor(vim.api.nvim_win_get_height(0) * 2.3) then
		vim.cmd("vs")
	else
		vim.cmd("split")
	end
end

-- stylua: ignore start
-- ╔═══════════════════════╗
-- ║    General Keymaps    ║
-- ╚═══════════════════════╝
keymap("n", "<leader>mu", function() require("mini.deps").update() end, { desc = "Update Plugins" })

-- Buffers
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer", silent = true })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer", silent = true })
keymap("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window", silent = true })
keymap("n", "<leader>bd", ":lua MiniBufremove.delete()<cr>", { desc = "Delete Buffer", silent = true })

-- Windows
keymap("n", "<leader>ws", split_sensibly, { desc = "[S]plit [S]ensibly", remap = true })
keymap("n", "<leader>wh", "<C-W>s", { desc = "Split [W]indow [H]orizontally", remap = true })
keymap("n", "<leader>wv", "<C-W>v", { desc = "Split [W]indow [V]ertically", remap = true })
keymap("n", "<leader>wd", "<C-W>c", { desc = "[W]indow [D]elete", remap = true })

-- Search
--vim.keymap.set('n', '<leader>"', builtin.registers, { desc = '["] Registers' })

keymap('n', '<leader><leader>', function() MiniPick.builtin.buffers() end, { desc = '[ ] Find existing buffers' })
keymap("n", "<leader>sh", function() MiniPick.builtin.help_tags() end, { desc = "[S]earch [H]elp" })
keymap("n", "<leader>sf", function() MiniPick.builtin.files() end, { desc = "[S]earch [F]iles" })
keymap("n", "<leader>sh", function() MiniPick.builtin.help() end, { desc = "[S]earch [H]elp" })
keymap('n', '<leader>sk', function() MiniExtra.pickers.keymaps() end, { desc = '[S]earch [K]eymaps' })
keymap('n', '<leader>sd', function() MiniExtra.pickers.diagnostic() end, { desc = '[S]earch [D]iagnostics' })
keymap('n', '<leader>so', function() MiniExtra.pickers.options() end, { desc = '[S]earch [O]ptions' })
keymap('n', '<leader>s"', function() MiniExtra.pickers.registers() end, { desc = '[S]earch Registers' })
keymap('n', '<leader>st', function() MiniExtra.pickers.treesitter() end, { desc = '[S]earch [T]reesitter' })
keymap('n', '<leader>ss', function() MiniExtra.pickers.spellsuggest() end, { desc = '[S]pelling [S]uggestions' })
keymap('n', '<leader>sR', function() MiniPick.builtin.resume() end, { desc = '[S]earch [R]esume' })
keymap('n', '<leader>s.', function() MiniExtra.pickers.oldfiles() end,
    { desc = '[S]earch Recent Files ("." for repeat)' })
keymap('n', '<leader>sg', function() MiniPick.builtin.grep_live() end, { desc = '[S]earch by [G]rep' })
keymap('n', '<leader>sw', function() MiniPick.builtin.grep({ pattern = vim.fn.expand('<cword>') }) end,
    { desc = '[S]earch current [W]ord' })
-- keymap('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })

-- ╔═══════════════════════╗
-- ║	     Git           ║
-- ╚═══════════════════════╝

keymap("n", "<leader>gg", function() require('neogit').open() end, { desc = "[Git] Status" })
keymap("n", "<leader>gb", function () MiniExtra.pickers.git_branches() end, { desc = "[Git] [B]ranches" })
keymap("n", "<leader>gc", function () MiniExtra.pickers.git_commits() end, { desc = "[Git] [C]ommits" })
keymap("n", "<leader>gh", function () MiniExtra.pickers.git_hunks() end, { desc = "[Git] [H]unks" })


-- ╔═══════════════════════╗
-- ║	      UI           ║
-- ╚═══════════════════════╝
keymap('n', '<leader>uf', function() MiniFiles.open(vim.api.nvim_buf_get_name(0), true) end, { desc = "[U]I [F]ile Explorer" })
keymap('n', '<leader>uF', function() MiniFiles.open(vim.uv.cwd(), true) end, { desc = "[U]I [F]ile Explorer (cwd)" })

-- ╔═══════════════════════╗
-- ║	     LSP           ║
-- ╚═══════════════════════╝
-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
keymap("n", "gd", function() MiniExtra.pickers.lsp({ scope = "definition" }) end, { desc = "[G]oto [D]efinition" })

-- WARN: This is not Goto Definition, this is Goto Declaration.
--  For example, in C this would take you to the header.
keymap("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })

-- Find references for the word under your cursor.
keymap("n", "gr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "[G]oto [R]eferences" })

-- jump to the implementation of the word under your cursor.
--  useful when your language has ways of declaring types without an actual implementation.
keymap("n", "gi", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end,
    { desc = "[G]oto [I]mplementation" })

-- jump to the type of the word under your cursor.
--  useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.

-- todo: look into keymapping this the same as lazyvim
keymap("n", "<leader>lD", function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end,
    { desc = "[L]sp Type [D]efinition" })

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
keymap("n", "<leader>ls", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end,
    { desc = "[L]sp Document [S]ymbols" })

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
keymap("n", "<leader>lW", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end,
    { desc = "[L]sp workspace [S]ymbols" })

-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
keymap("n", "<leader>lr", vim.lsp.buf.rename, { desc = "[L]sp [R]ename" })

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
keymap({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })

keymap("n", "<leader>lf", function() require('conform').format { async = true, lsp_format = "fallback" } end,
    { desc = "[L]sp [F]ormat" })
-- ╔═══════════════════════╗
-- ║    Session Keymaps    ║
-- ╚═══════════════════════╝
keymap("n", "<leader>Ss", function()
    vim.cmd('wa')
    require('mini.sessions').write()
    require('mini.sessions').select()
end, { desc = 'Switch Session' })
keymap("n", "<leader>Sw",
    function()
        local cwd = vim.fn.getcwd()
        local last_folder = cwd:match("([^/]+)$")
        require('mini.sessions').write(last_folder)
    end, { desc = 'Save Session' })
keymap("n", "<leader>Sf", function()
    vim.cmd('wa')
    require('mini.sessions').select()
end, { desc = 'Load Session' })

-- ╔═══════════════════════╗
-- ║    Editing Keymaps    ║
-- ╚═══════════════════════╝
-- Insert a Password at point
keymap("n", "<leader>ip", insert_password, { desc = 'Insert Password' })
keymap("n", "<leader>iu", insert_uuid, { desc = 'Insert uuid' })
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')
keymap("n", "YY", "<cmd>%y<cr>", { desc = 'Yank Buffer' })
keymap("n", "<Esc>", "<cmd>noh<cr>", { desc = 'Clear Search' })

-- ╔═══════════════════════╗
-- ║          AI           ║
-- ╚═══════════════════════╝
keymap("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = 'Codecompanion [A]i [A]actions'})


-- ╔═══════════════════════╗
-- ║         Visit         ║
-- ╚═══════════════════════╝
keymap('n', '<leader>vp', function() MiniExtra.pickers.visit_paths() end, { desc = '[V]isit [P]aths' })
keymap('n', '<leader>vl', function() MiniExtra.pickers.visit_labels() end, { desc = '[V]isit [L]abels' })

local map_vis = function(keys, call, desc)
    local rhs = '<Cmd>lua MiniVisits.' .. call .. '<CR>'
    vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
end

map_vis('va', 'add_label()', '[A]dd Label')
map_vis('vr', 'remove_label()', '[R]emove Label')
-- stylua: ignore end
