-- ╔═══════════════════════╗
-- ║    Local Variables    ║
-- ╚═══════════════════════╝
local keymap = vim.keymap.set
local opts = { noremap = true, silent = false }

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

-- Copy
keymap("n", "<C-s>", "<cmd>:w<cr>", { silent = true })

-- Buffers
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer", silent = true })
keymap("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window", silent = true })
keymap("n", "<leader>bd", function () MiniBufremove.delete() end, { desc = "Delete Buffer", silent = true })

-- Windows
keymap("n", "<leader>ws", split_sensibly, { desc = "[S]plit [S]ensibly", remap = true })
keymap("n", "<leader>wh", "<C-W>s", { desc = "Split [W]indow [H]orizontally", remap = true })
keymap("n", "<leader>wv", "<C-W>v", { desc = "Split [W]indow [V]ertically", remap = true })
keymap("n", "<leader>wd", "<C-W>c", { desc = "[W]indow [D]elete", remap = true })

-- Search
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
keymap('n', '<leader>s.', function() MiniExtra.pickers.oldfiles() end, { desc = '[S]earch Recent Files ("." for repeat)' })
keymap('n', '<leader>sc', function() MiniExtra.pickers.commands() end, { desc = '[S]earch commands' })
keymap('n', '<leader>sg', function() MiniPick.builtin.grep_live() end, { desc = '[S]earch by [G]rep' })
keymap('n', '<leader>sw', function() MiniPick.builtin.grep({ pattern = vim.fn.expand('<cword>') }) end, { desc = '[S]earch current [W]ord' })
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
keymap('n', '<leader>up', function() MiniExtra.pickers.explorer() end, { desc = "[U]I [F]ile Picker" })

-- ╔═══════════════════════╗
-- ║	     LSP           ║
-- ╚═══════════════════════╝
-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
-- keymap("n", "gd", function() MiniExtra.pickers.lsp({ scope = "definition" }) end, { desc = "[G]oto [D]efinition" })

-- WARN: This is not Goto Definition, this is Goto Declaration.
--  For example, in C this would take you to the header.
-- keymap("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })

-- Find references for the word under your cursor.
-- keymap("n", "gr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "[G]oto [R]eferences" })

-- jump to the implementation of the word under your cursor.
--  useful when your language has ways of declaring types without an actual implementation.
-- keymap("n", "gi", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end,
    -- { desc = "[G]oto [I]mplementation" })

-- jump to the type of the word under your cursor.
--  useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.

-- todo: look into keymapping this the same as lazyvim
-- keymap("n", "<leader>lD", function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end,
    -- { desc = "[L]sp Type [D]efinition" })

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
-- keymap("n", "<leader>ls", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end,
    -- { desc = "[L]sp Document [S]ymbols" })

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
-- keymap("n", "<leader>lW", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end,
    -- { desc = "[L]sp workspace [S]ymbols" })

-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
-- keymap("n", "<leader>lr", vim.lsp.buf.rename, { desc = "[L]sp [R]ename" })

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
-- keymap({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })

-- keymap("n", "<leader>lf", function() require('conform').format { async = true, lsp_format = "fallback" } end, { desc = "[L]sp [F]ormat" })


-- keymap("n", "<leader>le", function() vim.diagnostic.open_float() end, { desc = "[L]sp [E]rror" })

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
-- ║         Notes         ║
-- ╚═══════════════════════╝

-- Create a new note after asking for its title.
keymap("n", "<leader>nn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", vim.tbl_extend('keep', opts, { desc = "New note" }))
keymap("n", "<leader>nN", "<Cmd>ZkNewAtDir<CR>", vim.tbl_extend('keep', opts, { desc = "New note at dir" }))
keymap("n", "<leader>nj", "<Cmd>ZkNew { dir = 'journal/daily', date = 'today' }<CR>", vim.tbl_extend('keep', opts, { desc = "Open todays plan" }))
keymap("n", "<leader>nJ", "<Cmd>ZkNew { dir = 'journal/daily', date = 'tomorrow' }<CR>", vim.tbl_extend('keep', opts, { desc = "Open tomorrows plan" }))

-- Open notes.
keymap("n", "<leader>no", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes" }))
-- Open notes associated with the selected tags.
keymap("n", "<leader>nt", "<Cmd>ZkTags<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes (tags)" }))

-- Search for the notes matching a given query.
keymap("n", "<leader>nf", "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", vim.tbl_extend('keep', opts, { desc = "Search notes" }))
-- Search for the notes matching the current visual selection.
keymap("v", "<leader>nf", ":'<,'>ZkMatch<CR>", vim.tbl_extend('keep', opts, { desc = 'Search notes'}))


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

-- ╔═══════════════════════╗
-- ║          DAP          ║
-- ╚═══════════════════════╝
keymap("n", "<F5>", function() require("dap").continue() end, { desc = "Debug: Start/Continue" })
keymap("n", "<F1>", function() require("dap").step_into() end, { desc = "Debug: Step Into" })
keymap("n", "<F2>", function() require("dap").step_over() end, { desc = "Debug: Step Over" })
keymap("n", "<F3>", function() require("dap").step_out() end, { desc = "Debug: Step Out" })
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
keymap("n", "<F7>", function() require("dapui").toggle() end, { desc = "Debug: See last session result." })
keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
keymap("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Breakpoint" })

-- ╔═══════════════════════╗
-- ║          DAP          ║
-- ╚═══════════════════════╝
local minikeymap = require('mini.keymap')
local map_combo = minikeymap.map_combo

map_combo({ 'n', 'x' }, 'll', 'g$')
map_combo({ 'n', 'x' }, 'hh', 'g^')
-- map_combo({ 'n', 'x' }, 'jj', '}')
-- map_combo({ 'n', 'x' }, 'kk', '{')
--
--
-- map_multistep('i', '<Tab>',   { 'blink_next' })
-- map_multistep('i', '<S-Tab>', { 'blink_prev' })
-- map_multistep('i', '<CR>',    { 'blink_accept' })
-- map_multistep('i', '<BS>',    { 'minipairs_bs' })
-- -- Support most common modes. This can also contain 't', but would
-- -- only mean to press `<Esc>` inside terminal.
local mode = { 'i', 'c', 'x', 's' }
map_combo(mode, 'jk', '<BS><BS><Esc>')

-- To not have to worry about the order of keys, also map "kj"
map_combo(mode, 'kj', '<BS><BS><Esc>')
-- stylua: ignore end
