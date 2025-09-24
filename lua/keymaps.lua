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
	local uuid = Utils.generate_uuid()
	vim.api.nvim_put({ uuid }, "", true, true)
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

-- Quit
keymap("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
keymap("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Write and Quit All" })

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

-- Fuzzily search in current buffer (mini.pick equivalent of telescope current_buffer_fuzzy_find)
keymap('n', '<leader>/', function()
	MiniExtra.pickers.buf_lines({}, {
		window = {
			config = function()
				local height = math.floor(0.4 * vim.o.lines)
				local width = math.floor(0.8 * vim.o.columns)
				return {
					anchor = "NW",
					height = height,
					width = width,
					row = 1,
					col = math.floor(0.5 * (vim.o.columns - width)),
				}
			end
		}
	})
end, { desc = '[/] Fuzzily search in current buffer' })

-- keymap('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })

-- ╔═══════════════════════╗
-- ║   Command Palette     ║
-- ╚═══════════════════════╝

keymap('n', '<leader>cp', Utils.create_command_palette, { desc = 'Command Palette' })

-- ╔═══════════════════════╗
-- ║	     Git           ║
-- ╚═══════════════════════╝

keymap("n", "<leader>gg", function() require('neogit').open() end, { desc = "[Git] Status" })
keymap("n", "<leader>gb", function () MiniExtra.pickers.git_branches() end, { desc = "[Git] [B]ranches" })
keymap("n", "<leader>gc", function () MiniExtra.pickers.git_commits() end, { desc = "[Git] [C]ommits" })
keymap("n", "<leader>gh", function () MiniExtra.pickers.git_hunks() end, { desc = "[Git] [H]unks" })

-- Octo / GitHub
keymap("n", "<leader>goo", "<cmd>Octo actions<cr>", { desc = "[Git] Octo Actions" })
keymap("n", "<leader>gop", "<cmd>Octo pr list<cr>", { desc = "[Git] Octo PR List" })
keymap("n", "<leader>goi", "<cmd>Octo issue list<cr>", { desc = "[Git] Octo Issue List" })
keymap("n", "<leader>goc", "<cmd>Octo issue create<cr>", { desc = "[Git] Octo Create Issue" })
keymap("n", "<leader>gor", "<cmd>Octo review list<cr>", { desc = "[Git] Octo Review List" })
keymap("n", "<leader>goR", "<cmd>Octo review start<cr>", { desc = "[Git] Octo Start Review" })
keymap("n", "<leader>gos", "<cmd>Octo review submit<cr>", { desc = "[Git] Octo Submit Review" })

-- ╔═══════════════════════╗
-- ║	      UI           ║
-- ╚═══════════════════════╝
keymap("n", "<leader>ui", "<cmd>PasteImage<cr>", { desc = "[U]I Paste [I]mage" })

-- ╔═══════════════════════╗
-- ║	     File          ║
-- ╚═══════════════════════╝
keymap('n', '<leader>fp', function() MiniExtra.pickers.explorer() end, { desc = "[U]I [F]ile Picker" })
keymap('n', '<leader>ff', function() MiniFiles.open(vim.api.nvim_buf_get_name(0), true) end, { desc = "[U]I [F]ile Explorer" })
keymap('n', '<leader>fF', function() MiniFiles.open(vim.uv.cwd(), true) end, { desc = "[U]I [F]ile Explorer (cwd)" })

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
keymap("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = 'CodeCompanion [C]hat'})
keymap("n", "<leader>ae", "<cmd>CodeCompanionExplain<cr>", { desc = 'CodeCompanion [E]xplain'})
keymap("n", "<leader>ag", "<cmd>CodeCompanionGenerate<cr>", { desc = 'CodeCompanion [G]enerate'})

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
-- ║        COMBOS         ║
-- ╚═══════════════════════╝
local minikeymap = require('mini.keymap')
local map_combo = minikeymap.map_combo

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Navigation Combos (Normal & Visual)                             │
-- │ Quick line movement shortcuts                                   │
-- │                                                                 │
-- │ ll  →  g$ (end of visual line)                                  │
-- │ hh  →  g^ (start of visual line)                                │
-- │ Perfect for: Quick line navigation without reaching for $ ^     │
-- └─────────────────────────────────────────────────────────────────┘
map_combo({ 'n', 'x' }, 'll', 'g$')
map_combo({ 'n', 'x' }, 'hh', 'g^')
-- map_combo({ 'n', 'x' }, 'jj', '}')  -- Disabled: conflicts with common typing
-- map_combo({ 'n', 'x' }, 'kk', '{')  -- Disabled: conflicts with common typing

-- ╔═══════════════════════╗
-- ║   TEXT HELPER COMBOS  ║
-- ╚═══════════════════════╝

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Smart Semicolon (;;)                                            │
-- │ Add semicolon at end of line and return cursor to position      │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ let count = getMy|Value()  →  let count = getMy|Value();        │
-- │ println!("Debug: {}", var|) → println!("Debug: {}", var|);      │
-- │ Perfect for: C/C++/Java/JavaScript/Rust/Erlang                  │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', ';;', function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_input('<End>;<Esc>')
	vim.api.nvim_win_set_cursor(0, {row, col})
	vim.api.nvim_input('a')
end)

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Smart Comma (,,)                                                │
-- │ Add comma + space for function parameters and lists             │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ def func(arg1|)           →  def func(arg1, |)                  │
-- │ spawn(Module|, Function   →  spawn(Module, |, Function          │
-- │ [item1| item2]            →  [item1, | item2]                   │
-- │ Perfect for: Function params, Erlang lists, JSON objects        │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', ',,', '<BS><BS>, ')

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Smart Assignment (==)                                           │
-- │ Complete variable assignments with proper spacing               │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ let myVariable|    →  let myVariable = |                        │
-- │ count|             →  count = |                                 │
-- │ result|            →  result = |                                │
-- │ Perfect for: Variable assignments in any language               │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', '==', '<BS><BS> = ')

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Smart Quotes ("")                                               │
-- │ Context-aware quote wrapping and creation                       │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ Inside word:  hello|world  →  "hello|world"                     │
-- │ At boundary:  name = |     →  name = "|"                        │
-- │ Empty space:  |            →  "|"                               │
-- │ Perfect for: String literals, wrapping existing text            │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', '""', function()
	local mode = vim.fn.mode()
	if mode == 'v' or mode == 'V' then
		-- Wrap selection in quotes
		return '<Esc>`<i"<Esc>`>la"<Esc>i'
	else
		-- Check if we're at word boundary or inside word
		local line = vim.api.nvim_get_current_line()
		local col = vim.api.nvim_win_get_cursor(0)[2]
		local char_before = col > 0 and line:sub(col, col) or ' '
		local char_after = col < #line and line:sub(col + 1, col + 1) or ' '
		
		if char_before:match('%w') and char_after:match('%w') then
			-- Inside word - wrap word in quotes
			return '<BS><BS><Esc>viw<Esc>`<i"<Esc>`>la"<Esc>i'
		else
			-- Create quote pair
			return '<BS><BS>""<Left>'
		end
	end
end)

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Type Annotations (::)                                           │
-- │ Add type annotations with proper spacing                        │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ let count|           →  let count: |                            │
-- │ function(param|)     →  function(param: |)                      │
-- │ -spec func(Args|)    →  -spec func(Args: |) [Erlang]            │
-- │ Perfect for: TypeScript, Rust, Erlang specs                     │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', '::', '<BS><BS>: ')

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Arrow Helper (->)                                               │
-- │ Add arrows/returns with proper spacing                          │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ fn get_name()|         →  fn get_name() -> |  [Rust]            │
-- │ case Value of Pattern| →  case Value of Pattern -> | [Erlang]   │
-- │ (x, y)|               →  (x, y) -> | [Arrow functions]          │
-- │ Perfect for: Rust returns, Erlang cases, arrow functions        │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', '->', '<BS><BS> -> ')

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Method Chaining (..)                                            │
-- │ Quick method chaining for fluent interfaces                     │
-- │                                                                 │
-- │ Examples:                                                       │
-- │ myObject|          →  myObject.|                                │
-- │ builder|           →  builder.|                                 │
-- │ stream|            →  stream.|                                  │
-- │ Perfect for: Builder patterns, fluent APIs, method chaining     │
-- └─────────────────────────────────────────────────────────────────┘
map_combo('i', '..', '<BS><BS>.')
-- ╔═══════════════════════╗
-- ║   MULTI-STEP KEYMAPS  ║
-- ╚═══════════════════════╝
-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Smart Insert Mode Keys                                          │
-- │ Context-aware keys that cascade through multiple behaviors      │
-- │                                                                 │
-- │ <Tab>     → expand → snippets → completion → tree → brackets    │
-- │ <S-Tab>   → snippets ← completion ← tree ← brackets ← indent    │
-- │ <CR>      → accept completion → handle pairs                    │
-- │ <BS>      → handle pairs → hungry whitespace deletion           │
-- │ Perfect for: Snippets + completion + smart navigation           │
-- └─────────────────────────────────────────────────────────────────┘
local map_multistep = minikeymap.map_multistep

-- Smart Tab that works with snippets, completion, jumping, and indentation
local tab_steps = {
	'minisnippets_expand',     -- Expand snippet at cursor (highest priority)
	'minisnippets_next',       -- Jump to next snippet tabstop if in snippet
	'blink_next',              -- Navigate blink.cmp menu if visible
	'jump_after_tsnode',       -- Jump after current tree-sitter node
	'jump_after_close',        -- Jump after closing brackets/quotes  
	'increase_indent',         -- Increase indent if cursor is on indentation
}
map_multistep('i', '<Tab>', tab_steps)

-- Smart Shift-Tab for reverse navigation
local shift_tab_steps = {
	'minisnippets_prev',       -- Jump to previous snippet tabstop if in snippet
	'blink_prev',              -- Navigate blink.cmp menu backwards if visible
	'jump_before_tsnode',      -- Jump before current tree-sitter node
	'jump_before_open',        -- Jump before opening brackets/quotes
	'decrease_indent',         -- Decrease indent if cursor is on indentation
}
map_multistep('i', '<S-Tab>', shift_tab_steps)

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Snippet Navigation in Insert + Select Mode                      │
-- │ Essential for navigating snippet tabstops with placeholder text │
-- │                                                                 │
-- │ Works in both Insert and Select modes for snippet placeholders  │
-- │ Select mode is activated when snippet has ${1:placeholder}      │
-- │ Perfect for: Tab-ing through function parameters, etc.          │
-- └─────────────────────────────────────────────────────────────────┘
map_multistep({ 'i', 's' }, '<Tab>', { 'minisnippets_next', 'blink_next' })
map_multistep({ 'i', 's' }, '<S-Tab>', { 'minisnippets_prev', 'blink_prev' })

-- Smart Enter that accepts completion and respects pairs
map_multistep('i', '<CR>', { 'blink_accept', 'minipairs_cr' })

-- Smart Backspace that respects pairs and does hungry deletion
map_multistep('i', '<BS>', { 'minipairs_bs', 'hungry_bs' })

-- ╔═══════════════════════╗
-- ║    ESCAPE COMBOS      ║
-- ╚═══════════════════════╝

-- ┌─────────────────────────────────────────────────────────────────┐
-- │ Better Escape (jk / kj)                                         │
-- │ Quick escape from any mode without reaching for Esc key         │
-- │                                                                 │
-- │ Works in modes: Insert, Command, Visual, Select                 │
-- │ jk  →  <Esc> (remove jk and escape)                             │
-- │ kj  →  <Esc> (remove kj and escape)                             │
-- │ Perfect for: Fast mode switching, ergonomic typing              │
-- └─────────────────────────────────────────────────────────────────┘
local escape_modes = { 'i', 'c', 'x', 's' }
map_combo(escape_modes, 'jk', '<BS><BS><Esc>')
map_combo(escape_modes, 'kj', '<BS><BS><Esc>')

-- ╔═══════════════════════╗
-- ║         Tmux          ║
-- ╚═══════════════════════╝
keymap("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
keymap("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Navigate down" })
keymap("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Navigate up" })
keymap("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Navigate right" })
keymap("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Navigate previous" })
-- stylua: ignore end
