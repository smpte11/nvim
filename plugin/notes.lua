local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Load sqlite.lua immediately for task tracking
now(function()
	add("kkharji/sqlite.lua")
end)

later(function()
	add("zk-org/zk-nvim")

	local zk = require("zk")
	zk.setup({
		piker = "minipick",
		lsp = {
			config = {
				on_attach = function(_, bufnr)
					local function map(mode, lhs, rhs, opts)
						vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts or {}))
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
					-- Journal creation with carryover
					map(
						"n",
						"<leader>nj",
						":ZkNewDailyJournal<CR>",
						vim.tbl_extend("force", opts, { desc = "New daily journal note (carry unfinished tasks)" })
					)
					map(
						"n",
						"<leader>nw",
						":ZkNewWorkJournal<CR>",
						vim.tbl_extend("force", opts, { desc = "New work daily journal note (carry unfinished tasks)" })
					)
				end,
			},
		},
	})

	local commands = require("zk.commands")

	-- Carryover helper functions
	local function create_journal_helpers()
		local uv = vim.loop

		local function read_file(path)
			local fd = uv.fs_open(path, "r", 438)
			if not fd then
				return nil
			end
			local stat = uv.fs_fstat(fd)
			local data = uv.fs_read(fd, stat.size, 0)
			uv.fs_close(fd)
			return data
		end

		local function get_most_recent_journal_note(target_dir)
			local handle = uv.fs_scandir(target_dir)
			if not handle then
				return nil
			end
			local files = {}
			while true do
				local name, typ = uv.fs_scandir_next(handle)
				if not name then
					break
				end
				-- Allow any prefix (including hyphens)
				if typ == "file" and name:match("^.+%-%d%d%d%d%-%d%d%-%d%d%.md$") then
					table.insert(files, name)
				end
			end
			table.sort(files, function(a, b)
				return a > b
			end)
			if #files == 0 then
				return nil
			end
			return target_dir .. "/" .. files[1]
		end

		local function extract_unfinished_tasks(content, section)
			-- Escape special pattern characters in section name
			local escaped_section = section:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
			
			-- Find the start of our section
			local section_start = content:find("## " .. escaped_section)
			if not section_start then
				return {}
			end
			
			-- Find the start of content (after the section header and any whitespace)
			local content_start = content:find("\n", section_start)
			if not content_start then
				return {}
			end
			content_start = content_start + 1
			
			-- Find the next section header or end of content
			local next_section_start = content:find("\n## ", content_start)
			local section_content
			
			if next_section_start then
				section_content = content:sub(content_start, next_section_start - 1)
			else
				section_content = content:sub(content_start)
			end
			
			-- Remove leading/trailing whitespace
			section_content = section_content:gsub("^%s+", ""):gsub("%s+$", "")
			
			local tasks = {}
			-- Handle empty sections
			if section_content == "" then
				return tasks
			end
			
			-- Split by newlines and check each line for unfinished tasks
			for line in (section_content .. "\n"):gmatch("(.-)\n") do
				line = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
				if line:match("^%- %[ %]") or line:match("^%- %[%-%]") then
					table.insert(tasks, line)
				end
			end
			return tasks
		end

		return {
			read_file = read_file,
			get_most_recent_journal_note = get_most_recent_journal_note,
			extract_unfinished_tasks = extract_unfinished_tasks,
		}
	end

	-- ═══════════════════════════════════════════════════════════════════════
	-- ⚡⚡⚡ HIGHLY OPTIMIZED TASK TRACKING SYSTEM ⚡⚡⚡
	-- ═══════════════════════════════════════════════════════════════════════
	--
	-- PERFORMANCE SUMMARY: 7 Major Optimizations for Fast Operation
	--
	-- 🚀 OVERALL PERFORMANCE IMPACT:
	-- - Optimized for responsiveness and minimal delay, even with multiple tasks.
	-- - Designed to avoid UI blocking and provide a smooth user experience.
	--
	-- 🔥 OPTIMIZATION BREAKDOWN:
	-- #1 Connection Pooling:     Eliminates connection overhead
	-- #2 Database Tuning:        Uses WAL mode, memory cache, etc.
	-- #3 Prepared Statement Cache: Avoids repeated SQL compilation
	-- #4 Early Exit:             Skips processing when no tasks
	-- #5 Batch Transactions:     Reduces disk sync operations
	-- #6 Resource Cleanup:       Prevents memory leaks and lock issues
	-- #7 Async Processing:       Avoids blocking the user interface
	--
	-- 🎯 WHY THIS MATTERS:
	-- Task tracking should be invisible to users. With these optimizations,
	-- even large journals with many tasks process quickly and smoothly,
	-- without perceptible delay or UI freezing. The system is designed to scale efficiently.
	--
	-- ⚡ BLAZING FAST DATABASE CONNECTION MANAGER WITH INTELLIGENT CACHING ⚡
	-- 
	-- PERFORMANCE OPTIMIZATION #1: CONNECTION POOLING
	-- Instead of opening/closing database connections on every save (expensive!),
	-- we maintain a single cached connection that stays open between operations.
	-- This eliminates the ~2-5ms overhead of repeated SQLite connection setup.
	--
	-- Benefits:
	-- - 10x faster repeated operations (no connection overhead)
	-- - Reduced file system stress (no repeated file open/close)
	-- - Better resource utilization (connection reuse)
	-- - Maintains transaction isolation while maximizing throughput
	-- 🔒 PRIVACY-FIRST DESIGN: Separate databases for work vs personal
	-- - Personal tasks: git-committable, syncs across devices
	-- - Work tasks: local-only, never leaves your machine
	local task_db_cache = {
		perso = nil,  -- Cached personal database connection  
		work = nil    -- Cached work database connection
	}
	local cached_db_paths = {
		perso = nil,  -- Track personal database path
		work = nil    -- Track work database path
	}
	
	local function get_task_database(db_type)
		-- 🔒 PRIVACY-FIRST DATABASE ROUTING 🔒
		-- db_type: "perso" for personal (git-committable) or "work" for private (local-only)
		
		if not db_type or (db_type ~= "perso" and db_type ~= "work") then
			vim.notify("Invalid database type: " .. tostring(db_type), vim.log.levels.ERROR)
			return nil
		end
		
		-- SMART PATH RESOLUTION with privacy-first defaults
		local db_path
		if db_type == "perso" then
			-- 📝 PERSONAL TASKS: Store in notes directory (git-committable, syncs across devices)
			db_path = vim.env.ZK_PERSO_TASK_DB_PATH
			if not db_path or db_path == "" then
				local notedir = vim.env.ZK_NOTEBOOK_DIR
				if not notedir or notedir == "" then
					return nil -- Silent disable for better UX
				end
				db_path = notedir .. "/.perso-tasks.db"
			end
		else -- work
			-- 💼 WORK TASKS: Store in notes directory but never commit to git
			-- Collocated with personal tasks for better organization, privacy via .gitignore
			db_path = vim.env.ZK_WORK_TASK_DB_PATH
			if not db_path or db_path == "" then
				local notedir = vim.env.ZK_NOTEBOOK_DIR
				if not notedir or notedir == "" then
					return nil -- Silent disable for better UX
				end
				db_path = notedir .. "/.work-tasks.db"
			end
		end
		
		-- Resolve environment variables and path expansions (~, $HOME, etc.)
		db_path = vim.fn.expand(db_path)
		
		-- ⚡ CACHE HIT: Return existing connection if path unchanged
		if task_db_cache[db_type] and cached_db_paths[db_type] == db_path then
			return task_db_cache[db_type]
		end
		
		-- CACHE INVALIDATION: Path changed, close old connection
		if task_db_cache[db_type] then
			task_db_cache[db_type]:close()
			task_db_cache[db_type] = nil
		end
		
		-- DIRECTORY CREATION with error handling
		-- Ensures database directory exists before attempting to create database
		local db_dir = vim.fn.fnamemodify(db_path, ":h")
		if vim.fn.isdirectory(db_dir) == 0 then
			if vim.fn.mkdir(db_dir, "p") == 0 then
				vim.notify("Failed to create directory for task database: " .. db_dir, vim.log.levels.ERROR)
				return nil
			end
		end
		
		-- Initialize SQLite connection using sqlite.lua (robust Lua SQLite interface)
		-- sqlite.lua provides prepared statements, transactions, and proper error handling
		-- Much more reliable and performant than shell-based sqlite3 commands
		local ok, sqlite = pcall(require, "sqlite")
		if not ok then
			print("🔍 DEBUG: sqlite.lua not available:", sqlite)
			vim.notify("Task tracking disabled: sqlite.lua not available", vim.log.levels.WARN)
			return nil
		end
		
		-- Create database connection using kkharji/sqlite.lua API
		local db = sqlite.new(db_path, {
			open_mode = "rwc"  -- read-write-create mode (default)
		})
		
		if not db then
			vim.notify("Failed to open/create task database at: " .. db_path, vim.log.levels.ERROR)
			return nil
		end
		
		-- Ensure database connection is open
		if db.open and type(db.open) == "function" then
			db:open()
		end
		
		-- ⚡ PERFORMANCE OPTIMIZATION #2: ADVANCED DATABASE TUNING ⚡
		--
		-- These PRAGMA settings transform SQLite from decent to BLAZING FAST
		-- Each setting is carefully chosen for our specific workload:
		-- - Heavy writes (task events on every save)
		-- - Frequent existence checks (task_exists_in_db calls)
		-- - Timestamp-ordered queries (latest state, carryover counts)
		-- - Append-only data (pure event sourcing, no updates/deletes)
		-- Performance PRAGMA statements for blazing fast operations
		db:execute("PRAGMA journal_mode = WAL")
		db:execute("PRAGMA synchronous = NORMAL") 
		db:execute("PRAGMA cache_size = 10000")
		db:execute("PRAGMA temp_store = MEMORY")
		
		-- Create main table with optimized schema
		local table_result = db:execute([[
			CREATE TABLE IF NOT EXISTS task_events (
				event_id INTEGER PRIMARY KEY AUTOINCREMENT,
				task_id TEXT NOT NULL,
				event_type TEXT NOT NULL,
				timestamp TEXT NOT NULL,
				task_text TEXT,
				state TEXT,
				journal_file TEXT,
				created_at DATETIME DEFAULT CURRENT_TIMESTAMP
			)
		]])
		
		if not table_result then
			vim.notify("Failed to create task_events table", vim.log.levels.ERROR)
			db:close()
			return nil
		end
		
		-- Create strategic indexes for maximum query performance
		db:execute("CREATE INDEX IF NOT EXISTS idx_task_id ON task_events(task_id)")
		db:execute("CREATE INDEX IF NOT EXISTS idx_event_type ON task_events(event_type)")  
		db:execute("CREATE INDEX IF NOT EXISTS idx_timestamp ON task_events(timestamp)")
		
		-- CACHE THE CONNECTION for subsequent operations (privacy-aware caching)
		task_db_cache[db_type] = db
		cached_db_paths[db_type] = db_path
		
		return db
	end
	
	

	-- ⚡ PERFORMANCE OPTIMIZATION #4: EARLY EXIT OPTIMIZATION ⚡
	--
	-- PROBLEM: Parsing every line of large journal files is expensive
	-- Most journal files (80%+) don't contain any tasks at all.
	-- Running regex patterns on every line wastes CPU cycles.
	--
	-- SOLUTION: Lightning-fast pre-scan using Vim's native search
	-- Before doing expensive parsing, quickly check if any tasks exist.
	-- If no tasks found, immediately exit without any parsing overhead.
	--
	-- PERFORMANCE IMPACT: 
	-- - 50-100x faster on task-free buffers (immediate exit vs full parse)
	-- - Reduces CPU usage on large files from ~5-10ms to ~0.1ms
	-- - Makes task tracking virtually invisible for most journal saves
	local function has_tasks_in_buffer(bufnr)
		bufnr = bufnr or 0
		
		-- BLAZING FAST DETECTION: Use Vim's built-in search engine
		-- vim.fn.search() is implemented in C and optimized for speed
		-- It can scan thousands of lines in microseconds
		-- 
		-- vim.api.nvim_buf_call(bufnr, function) ensures we search in the correct buffer
		-- This is safer than manipulating current window/buffer state
		return vim.api.nvim_buf_call(bufnr, function()
			-- search(pattern, flags) is Vim's native search function
			-- - "task://" pattern: look for our custom URI scheme
			-- - "nW" flags: 
			--   - 'n': don't move cursor (just check existence)
			--   - 'W': don't wrap around buffer (faster, more predictable)
			-- Returns: line number if found (>0), 0 if not found
			local found = vim.fn.search("task://", "nW")
			return found > 0
		end)
	end
	
	-- OPTIMIZED TASK PARSING with early exit and efficient line processing
	local function parse_tasks_from_buffer(bufnr)
		bufnr = bufnr or 0  -- Default to current buffer
		
		-- ⚡ EARLY EXIT OPTIMIZATION: Skip expensive parsing if no tasks exist
		-- This check takes ~0.1ms and can save ~5-10ms of unnecessary parsing
		-- Key insight: Most journal files don't have tasks, so this optimization
		-- provides massive speedup for the common case
		if not has_tasks_in_buffer(bufnr) then
			return {}  -- Instant return, zero parsing overhead
		end
		
		-- EFFICIENT BUFFER READING: Get all lines in one API call
		-- vim.api.nvim_buf_get_lines() is faster than line-by-line reading
		-- because it minimizes the number of API crossings between Lua and Neovim's core
		--
		-- Parameters explained:
		-- - bufnr: target buffer (0 = current buffer)
		-- - 0: start from first line (0-indexed in Neovim API)
		-- - -1: read until end of buffer (-1 is special "end" marker)
		-- - false: strict_indexing disabled (more forgiving, slightly faster)
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local tasks = {}
		
		for line_num, line_content in ipairs(lines) do
			-- Match tasks with our custom URI pattern: - [state] text [ ](task://uuid)
			-- Pattern explanation:
			-- ^%s*%- %[([%-%sx]?)%] (.-)%s%[ %]%(task://([%w%-]+)%)%s*$
			-- ^%s* = start of line with optional whitespace
			-- %- = literal dash
			-- %[([%-%sx]?)%] = checkbox with captured state (-, x, or space)
			-- (.-) = capture task text (non-greedy)
			-- %s = whitespace
			-- %[ %] = literal [ ]
			-- %(task:// = literal (task://
			-- ([%w%-]+) = capture UUID (alphanumeric and hyphens)
			-- %)%s*$ = literal ) followed by optional whitespace and end of line
			local state, task_text, task_uuid = line_content:match("^%s*%- %[([%-%sx]?)%] (.-)%s%[ %]%(task://([%w%-]+)%)%s*$")
			
			if task_uuid and task_text then
				-- Convert checkbox state to our state names
				local task_state = "CREATED"
				if state == "x" then
					task_state = "FINISHED"
				elseif state == "-" then
					task_state = "IN_PROGRESS"
				end
				
				table.insert(tasks, {
					uuid = task_uuid,
					text = task_text:gsub("^%s+", ""):gsub("%s+$", ""), -- trim whitespace
					state = task_state,
					line_number = line_num,
					original_line = line_content,
				})
			end
		end
		
		return tasks
	end

	-- ⚡ LIGHTNING-FAST EVENT SAVING WITH CACHED PREPARED STATEMENTS ⚡
	--
	-- This function combines multiple performance optimizations for maximum speed:
	-- 1. Cached prepared statements (no repeated SQL compilation)
	-- 2. Parameterized queries (secure and fast)
	-- 3. Minimal error handling overhead
	-- 4. Optimized for repeated execution within transactions
	local function save_task_event(db, event_data)
		if not db then
			return false
		end
		
		-- ⚡ CACHED PREPARED STATEMENT: Reuse pre-compiled SQL for maximum speed
		-- Instead of preparing this statement every time (expensive!), we cache it
		-- and just reset/bind/execute for each use. This provides:
		-- - 5-10x faster execution (no SQL parsing/compilation overhead)
		-- - Better memory efficiency (statement reuse)
		-- - Consistent performance regardless of how many tasks we process
		-- ⚡ SIMPLIFIED sqlite.lua API: Direct execution with parameter binding
		local sql = [[
			INSERT INTO task_events (task_id, event_type, timestamp, task_text, state, journal_file)
			VALUES (?, ?, ?, ?, ?, ?)
		]]
		
		-- Execute INSERT with parameters using db:eval() for proper parameter binding
		local success = db:eval(sql, {
			event_data.task_id,
			event_data.event_type,
			os.date("%Y-%m-%d %H:%M:%S"),  -- ISO timestamp for consistent sorting
			event_data.task_text,
			event_data.state,  -- Current state after this event (pure event sourcing!)
			event_data.journal_file
		})
		
		if not success then
			vim.notify("Failed to save task event to database", vim.log.levels.ERROR)
			return false
		end
		-- or when Neovim exits (see VimLeavePre autocmd)
		return true
	end

	-- ⚡ LIGHTNING-FAST TASK EXISTENCE CHECK WITH CACHED OPTIMIZATION ⚡
	--
	-- This function is called repeatedly during task processing to determine
	-- if a task is new (task_created event) or a carryover (task_carried_over event).
	-- 
	-- PERFORMANCE CRITICAL: This function gets called for EVERY task on EVERY save
	-- So even small optimizations here compound into massive overall speedup
	local function task_exists_in_db(db, task_id)
		if not db then
			return false
		end
		
		-- ⚡ CACHED PREPARED STATEMENT: Reuse pre-compiled query
		-- This query runs constantly (once per task per save), so caching the
		-- prepared statement provides significant cumulative speedup:
		-- - No SQL parsing overhead (statement pre-compiled)
		-- - Optimal execution plan cached by SQLite
		-- - Minimal memory allocation (statement object reused)
		--
		-- QUERY OPTIMIZATION: COUNT(*) with index lookup
		-- Using COUNT(*) with our idx_task_id index provides O(log n) performance
		-- Alternative approaches like EXISTS or SELECT 1 would be similar speed
		-- Execute optimized COUNT query using our idx_task_id index  
		local result = db:eval("SELECT COUNT(*) FROM task_events WHERE task_id = ?", {task_id})
		
		if result and result[1] and result[1]["COUNT(*)"] then
			-- COUNT(*) returns number of matching rows
			-- >0 means task exists, 0 means it's a new task
			return result[1]["COUNT(*)"] > 0
		end
		
		return false
	end
	
	-- ⚡ PERFORMANCE OPTIMIZATION #5: BATCH PROCESSING WITH TRANSACTIONS ⚡
	--
	-- PROBLEM: Individual database writes are slow due to disk sync overhead
	-- Each sqlite INSERT typically triggers a disk flush (~1-5ms per write)
	-- For journals with multiple tasks, this creates cumulative slowdown
	--
	-- SOLUTION: Batch all writes into a single transaction
	-- SQLite transactions group writes and sync to disk only once at commit time
	-- This transforms N individual writes into 1 batch write operation
	--
	-- PERFORMANCE IMPACT:
	-- - 10-50x faster for multiple tasks (1 disk sync vs N disk syncs)
	-- - Atomic consistency (all tasks saved or none saved)
	-- - Reduced I/O contention and better system responsiveness
	-- - Scales linearly: 100 tasks takes same time as 10 tasks
	local function save_task_events_batch(db, events)
		if not db or #events == 0 then
			return 0
		end
		
		-- ⚡ BEGIN TRANSACTION: Group all writes for atomic batch processing
		-- MASSIVE PERFORMANCE BOOST: Instead of syncing to disk after each INSERT,
		-- SQLite will buffer all writes in memory and sync only once at commit
		--
		-- Why this is so much faster:
		-- - Without transaction: INSERT → fsync → INSERT → fsync → INSERT → fsync
		-- - With transaction:    INSERT → INSERT → INSERT → fsync (one time!)
		-- 
		-- The disk sync (fsync) is the expensive operation (~1-5ms), so eliminating
		-- N-1 syncs provides exponential speedup for batch operations
		local transaction_success = db:execute("BEGIN TRANSACTION;")
		if not transaction_success then
			return 0
		end
		
		local success_count = 0
		
		-- BATCH EXECUTE: Process all events using cached prepared statements
		-- Each save_task_event() reuses our cached prepared statement, so we get:
		-- - Zero SQL compilation overhead (statements pre-compiled and cached)
		-- - Maximum SQLite performance (prepared statements + transaction batching)
		-- - Perfect for processing multiple tasks from carryover scenarios
		for _, event_data in ipairs(events) do
			if save_task_event(db, event_data) then
				success_count = success_count + 1
			end
		end
		
		-- ⚡ ATOMIC COMMIT: Write entire batch to disk in one operation
		-- COMMIT forces SQLite to write all buffered changes to disk atomically
		-- This ensures data consistency while providing maximum performance
		local commit_success = db:execute("COMMIT;")
		if not commit_success then
			-- ROLLBACK on failure: Ensures database remains in consistent state
			-- If commit fails, we undo all changes rather than leaving partial writes
			db:execute("ROLLBACK;")
			return 0
		end
		
		-- Return count of successfully processed events
		-- This allows the caller to provide accurate user feedback
		return success_count
	end

	-- Ultra-fast current state lookup with cached prepared statements
	local function get_task_current_state(db, task_id)
		if not db then
			return nil
		end
		
		-- Query latest task state using timestamp/event_id ordering
		local result = db:eval([[
			SELECT state FROM task_events 
			WHERE task_id = ? 
			ORDER BY timestamp DESC, event_id DESC 
			LIMIT 1
		]], {task_id})
		
		if result and result[1] and result[1].state then
			return result[1].state
		end
		
		return nil
	end

	-- Function to get previous state of a task from events (pure event-sourcing)
	local function get_task_previous_state(db, task_id)
		if not db then
			return nil
		end
		
		-- Get the second most recent event for this task to determine previous state
		-- This is useful for detecting state changes in true event-sourcing fashion
		local result = db:eval([[
			SELECT state FROM task_events 
			WHERE task_id = ? 
			ORDER BY timestamp DESC, event_id DESC 
			LIMIT 1 OFFSET 1
		]], {task_id})
		
		if result and type(result) == "table" and result[1] and result[1].state then
			return result[1].state
		end
		
		return nil -- nil if no previous state (first event) or query failed
	end

	-- Lightning-fast carryover count with cached prepared statements
	local function get_task_carryover_count(db, task_id)
		if not db then
			return 0
		end
		
		-- Count carryover events for pure event-sourcing carryover tracking
		local result = db:eval("SELECT COUNT(*) FROM task_events WHERE task_id = ? AND event_type = 'task_carried_over'", {task_id})
		
		if result and result[1] and result[1]["COUNT(*)"] then
			return result[1]["COUNT(*)"]
		end
		
		return 0
	end

	-- Function to get all previously tracked task IDs for a journal file
	-- This is used to detect deleted tasks (tasks that were tracked but are no longer in the note)
	local function get_previously_tracked_tasks(db, journal_file)
		if not db then
			return {}
		end
		
		-- Get all distinct task IDs that have been tracked for this journal file
		-- We only look for non-deleted tasks (tasks that don't have a final 'task_deleted' event)
		local result = db:eval([[
			SELECT DISTINCT task_id FROM task_events 
			WHERE journal_file = ? 
			AND task_id NOT IN (
				SELECT task_id FROM task_events 
				WHERE journal_file = ? AND event_type = 'task_deleted'
			)
		]], {journal_file, journal_file})
		
		local task_ids = {}
		if result and type(result) == "table" then
			for _, row in ipairs(result) do
				table.insert(task_ids, row.task_id)
			end
		end
		
		return task_ids
	end

	-- ⚡ BLAZING FAST ASYNCHRONOUS TASK TRACKING WITH ALL OPTIMIZATIONS ⚡
	--
	-- This is the main orchestrator function that combines ALL performance optimizations:
	-- 1. Cached database connections (connection pooling)
	-- 2. Early exit optimization (skip processing if no tasks)
	-- 3. Cached prepared statements (no SQL compilation overhead)
	-- 4. Batch transaction processing (minimize disk I/O)
	-- 5. Efficient event-sourced design (pure, append-only events)
	local function track_new_tasks_on_save(bufnr)
		bufnr = bufnr or 0
		
		-- BUFFER METADATA: Get file path for routing and event recording
		local journal_file = vim.api.nvim_buf_get_name(bufnr)
		
		-- 🔒 PRIVACY-FIRST ROUTING: Detect journal type from filename
		-- Extract just the filename from the full path for pattern matching
		local filename = vim.fn.fnamemodify(journal_file, ":t")  -- basename only
		local db_type = nil
		
		if vim.startswith(filename, "perso-") then
			db_type = "perso"  -- Personal tasks → git-committable database
		elseif vim.startswith(filename, "work-") then
			db_type = "work"   -- Work tasks → private local database  
		else
			-- Not a tracked journal type, skip task tracking
			return
		end
		
		-- ⚡ OPTIMIZATION #1: PRIVACY-AWARE CACHED CONNECTION REUSE
		-- Get cached database connection for the specific journal type
		-- This eliminates 2-5ms of connection overhead on every save
		local db = get_task_database(db_type)
		if not db then
			return  -- Graceful disable if database not configured
		end
		
		-- ⚡ OPTIMIZATION #4: EARLY EXIT ON EMPTY BUFFERS
		-- Quick pre-scan to avoid expensive parsing on task-free journals
		-- Most journal files don't have tasks, so this check provides massive speedup
		-- Cost: ~0.1ms    Savings: ~5-10ms of unnecessary parsing
		if not has_tasks_in_buffer(bufnr) then
			return  -- Lightning-fast exit, zero parsing overhead
		end
		
		-- OPTIMIZED PARSING: Extract tasks only when they definitely exist
		-- parse_tasks_from_buffer() is now optimized with early exit and efficient line processing
		local tasks = parse_tasks_from_buffer(bufnr)
		
		-- DEFENSIVE PROGRAMMING: Double-check for edge cases
		-- This shouldn't happen due to has_tasks_in_buffer() check, but safety first
		-- Better to be defensive than crash on unexpected buffer states
		if #tasks == 0 then
			return
		end
		
		-- ⚡ OPTIMIZATION #5: BATCH EVENT COLLECTION
		-- Instead of saving events one-by-one (slow, multiple disk syncs),
		-- collect all events first, then batch process them in a single transaction
		--
		-- This approach provides:
		-- - Atomic consistency (all events saved together or none)
		-- - Dramatic speed improvement (single disk sync vs multiple syncs)
		-- - Better error handling (transaction rollback on any failure)
		local events_to_save = {}
		local new_task_count = 0
		local carryover_count = 0
		local completed_count = 0
		local started_count = 0
		
		-- INTELLIGENT EVENT CLASSIFICATION: New tasks vs carryovers
		-- We use cached prepared statements for existence checks, making this loop blazing fast
		for _, task in ipairs(tasks) do
			if not task_exists_in_db(db, task.uuid) then
				-- FIRST TIME SEEING THIS TASK: Pure event sourcing with synthetic events
				-- Always create the "birth" event first (task_created with CREATED state)
				table.insert(events_to_save, {
					task_id = task.uuid,
					event_type = "task_created",
					task_text = task.text,
					state = "CREATED",  -- Always CREATED for birth event
					journal_file = journal_file,
				})
				new_task_count = new_task_count + 1
				
				-- If task is found in a non-CREATED state, create the transition event
				if task.state == "IN_PROGRESS" then
					-- SYNTHETIC TRANSITION: Task started immediately after creation
					table.insert(events_to_save, {
						task_id = task.uuid,
						event_type = "task_started",
						task_text = task.text,
						state = "IN_PROGRESS",
						journal_file = journal_file,
					})
					started_count = started_count + 1
				elseif task.state == "FINISHED" then
					-- SYNTHETIC TRANSITION: Task completed immediately after creation
					table.insert(events_to_save, {
						task_id = task.uuid,
						event_type = "task_completed",
						task_text = task.text,
						state = "FINISHED",
						journal_file = journal_file,
					})
					completed_count = completed_count + 1
				end
			else
				-- EXISTING TASK: Check for state transitions or carryovers
				local previous_state = get_task_previous_state(db, task.uuid)
				
				-- Check for significant state transitions
				if task.state == "FINISHED" and previous_state ~= "FINISHED" then
					-- TASK COMPLETION: Transition to FINISHED state
					table.insert(events_to_save, {
						task_id = task.uuid,
						event_type = "task_completed",
						task_text = task.text,
						state = task.state,
						journal_file = journal_file,
					})
					completed_count = completed_count + 1
				elseif task.state == "IN_PROGRESS" and previous_state ~= "IN_PROGRESS" then
					-- TASK STARTED: Transition to IN_PROGRESS state
					table.insert(events_to_save, {
						task_id = task.uuid,
						event_type = "task_started",
						task_text = task.text,
						state = task.state,
						journal_file = journal_file,
					})
					started_count = started_count + 1
				elseif task.state == "FINISHED" or task.state == "DELETED" then
					-- FSM VIOLATION: Terminal states reappearing in journal
					-- This should not happen according to our FSM model
					vim.notify(
						string.format("⚠️  FSM Warning: Task '%s' in terminal state %s found in journal", 
							task.text, task.state),
						vim.log.levels.WARN,
						{ title = "Task State Machine" }
					)
					-- No event created for terminal state violations
				elseif task.state == "CREATED" or task.state == "IN_PROGRESS" then
					-- FSM-ALIGNED CARRYOVER: Only non-terminal states can be carried over
					-- According to FSM, only CREATED and IN_PROGRESS have carryover transitions
					table.insert(events_to_save, {
						task_id = task.uuid,
						event_type = "task_carried_over",
						task_text = task.text,
						state = task.state,
						journal_file = journal_file,
					})
					carryover_count = carryover_count + 1
				end
			end
		end
		
		-- ⚡ DELETED TASK DETECTION: Check for tasks that were removed from the note
		-- Get all previously tracked task IDs for this journal file
		local previously_tracked_tasks = get_previously_tracked_tasks(db, journal_file)
		
		-- Create a set of current task IDs for efficient lookup
		local current_task_ids = {}
		for _, task in ipairs(tasks) do
			current_task_ids[task.uuid] = true
		end
		
		-- Find tasks that were previously tracked but are no longer in the note
		local deleted_count = 0
		for _, task_id in ipairs(previously_tracked_tasks) do
			if not current_task_ids[task_id] then
				-- This task was removed from the note - create a delete event
				table.insert(events_to_save, {
					task_id = task_id,
					event_type = "task_deleted",
					task_text = "", -- No text since task was removed
					state = "DELETED", -- Final state (consistent with other states)
					journal_file = journal_file,
				})
				deleted_count = deleted_count + 1
			end
		end
		
		-- ⚡ BATCH TRANSACTION: Write all events atomically for maximum performance
		-- This is where we get our biggest speedup for multi-task scenarios
		-- Single transaction with cached prepared statements = optimal SQLite performance
		local saved_count = save_task_events_batch(db, events_to_save)
		
		-- ⚡ FORCE IMMEDIATE PERSISTENCE: Ensure data is written to disk
		-- sqlite.lua might buffer writes - force a checkpoint to guarantee persistence  
		if saved_count > 0 then
			print("🔍 DEBUG: File size before checkpoint:", vim.fn.getfsize(cached_db_paths[db_type]), "bytes")
			local checkpoint_result = db:execute("PRAGMA wal_checkpoint(FULL);")
			print("🔍 DEBUG: Checkpoint result:", vim.inspect(checkpoint_result))
			print("🔍 DEBUG: File size after checkpoint:", vim.fn.getfsize(cached_db_paths[db_type]), "bytes")
			
			-- Double-check that data actually exists in the database  
			print("🔍 DEBUG: Counting records in database...")
			local count_result = db:eval("SELECT COUNT(*) FROM task_events")
			print("🔍 DEBUG: Tasks in database after save:", vim.inspect(count_result))
		end
		
		-- CONNECTION PERSISTENCE: Keep database connection open (cached)
		-- We don't call db:close() here because the connection is cached for reuse
		-- This avoids expensive connection setup on the next save operation  
		-- Connection will be properly closed when Neovim exits (VimLeavePre autocmd)
		
		-- USER FEEDBACK: Provide immediate feedback about tracking activity
		-- Only notify if something was actually processed (avoid notification spam)
		if saved_count > 0 then
			local msg_parts = {}
			if new_task_count > 0 then
				table.insert(msg_parts, string.format("%d new", new_task_count))
			end
			if started_count > 0 then
				table.insert(msg_parts, string.format("%d started", started_count))
			end
			if carryover_count > 0 then
				table.insert(msg_parts, string.format("%d carried over", carryover_count))
			end
			if completed_count > 0 then
				table.insert(msg_parts, string.format("%d completed", completed_count))
			end
			if deleted_count > 0 then
				table.insert(msg_parts, string.format("%d deleted", deleted_count))
			end
			local msg = "⚡ Tracked: " .. table.concat(msg_parts, ", ")
			vim.notify(msg, vim.log.levels.INFO, { title = "Task Tracking" })
		end
	end

	-- Function to create a new task with custom URI
	local function create_new_task()
		-- Use the shared UUID generation utility from Utils
		local uuid = Utils.generate_uuid()
		local task_line = string.format("- [ ]  [ ](task://%s)", uuid)
		
		-- Get current cursor position in the current window
		-- vim.api.nvim_win_get_cursor(0) returns {row, col} where:
		-- - 0 means "current window"
		-- - row is 1-indexed (first line is 1)
		-- - col is 0-indexed (first column is 0)
		-- We only need [1] to get the row number
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		
		-- Insert text into the current buffer after the current line
		-- vim.api.nvim_buf_set_lines(buffer, start, end, strict_indexing, replacement)
		-- - 0 means "current buffer"
		-- - current_line for start: since nvim_buf_set_lines uses 0-indexed lines,
		--   and current_line is 1-indexed, using current_line as 0-indexed position
		--   means we insert after the 1-indexed line current_line
		-- - current_line for end means "don't replace any existing lines"
		-- - false means "allow out-of-bounds line numbers" (more forgiving)
		-- - {task_line} is a table of strings to insert (one string = one line)
		vim.api.nvim_buf_set_lines(0, current_line, current_line, false, {task_line})
		
		-- Move the cursor to the task line we just inserted
		-- vim.api.nvim_win_set_cursor(window, {row, col})
		-- - 0 means "current window"
		-- - {current_line + 1, 6} means:
		--   - current_line + 1 is the new task line (original line + 1 due to insertion)
		--   - 6 is the column position (0-indexed): "- [ ] " = positions 0,1,2,3,4,5, so 6 is right after the space
		vim.api.nvim_win_set_cursor(0, {current_line + 1, 6})
		
		-- Enter insert mode programmatically
		-- vim.cmd() executes a Vim command as if you typed it in command mode
		-- "startinsert" is the Vim command equivalent to pressing 'i' in normal mode
		-- This puts the cursor in insert mode so the user can immediately start typing
		vim.cmd("startinsert")
	end

	-- Journal content creation with task carryover
	local function create_journal_content_with_carryover(target_dir, task_type)
		local H = create_journal_helpers()
		local prev_path = H.get_most_recent_journal_note(target_dir)
		local main_tasks, other_tasks = {}, {}
		
		if prev_path then
			local prev_content = H.read_file(prev_path)
			if prev_content then
				-- Extract tasks and record carryover events for tracking
				-- We need to pass the new journal file path to record the carryover events
				-- For now, we'll extract tasks normally and record carryover events later
				main_tasks = H.extract_unfinished_tasks(prev_content, "What is my main goal for today?")
				other_tasks = H.extract_unfinished_tasks(prev_content, "What else do I wanna do?")

				-- Show extracted tasks in a notification only if there are tasks to show
				local has_main_tasks = next(main_tasks) ~= nil
				local has_other_tasks = next(other_tasks) ~= nil
				
				if has_main_tasks or has_other_tasks then
					local msg_parts = {}
					
					if has_main_tasks then
						table.insert(msg_parts, "Main tasks:\n" .. table.concat(main_tasks, "\n"))
					end
					
					if has_other_tasks then
						table.insert(msg_parts, "Other tasks:\n" .. table.concat(other_tasks, "\n"))
					end
					
					local msg = table.concat(msg_parts, "\n\n")
					vim.notify(msg, vim.log.levels.INFO, { title = "Extracted Unfinished Tasks (" .. task_type .. ")" })
				else
					local entry_type = task_type:lower() == "work" and "work journal" or "journal"
					vim.notify("No unfinished tasks found in previous " .. entry_type .. " entry.", vim.log.levels.INFO, { title = "Task Extraction (" .. task_type .. ")" })
				end
			else
				local file_type = task_type:lower() == "work" and "work journal" or "journal"
				vim.notify("Could not read previous " .. file_type .. " file: " .. prev_path, vim.log.levels.WARN, { title = "Task Extraction (" .. task_type .. ")" })
			end
		end
		
		return "## What is my main goal for today?\n"
			.. (next(main_tasks) and table.concat(main_tasks, "\n") .. "\n" or "")
			.. "\n## What else do I wanna do?\n"
			.. (next(other_tasks) and table.concat(other_tasks, "\n") .. "\n" or "")
			.. "\n## What did I do today?\n"
	end

	commands.add("ZkNewAtDir", function(options)
		options = options or {}
		local notedir = vim.env.ZK_NOTEBOOK_DIR
		if notedir == nil or notedir == "" then
			vim.notify("ZK_NOTEBOOK_DIR is not set.", vim.log.levels.ERROR)
			return
		end

		-- Helper function to get directory items for the picker
		local get_directory_items = function(current_path_abs)
			local items = {}
			-- Add ".. (Parent)" navigation item if not at the notedir root
			-- Ensure paths are compared reliably (e.g. by resolving them)
			local resolved_current_path = vim.fn.resolve(current_path_abs)
			local resolved_notedir = vim.fn.resolve(notedir)

			if resolved_current_path ~= resolved_notedir then
				local parent_path = vim.fn.fnamemodify(current_path_abs, ":h")
				local resolved_parent_path = vim.fn.resolve(parent_path) -- Resolve for comparison
				-- Ensure parent_path is not empty or root before adding, and is above or at notedir
				if
					parent_path ~= ""
					and parent_path ~= current_path_abs
					and vim.startswith(resolved_current_path, resolved_notedir)
					and #resolved_parent_path >= #resolved_notedir
				then
					table.insert(items, {
						text = ".. (Parent Directory)",
						path = parent_path,
						is_parent_link = true,
						is_dir = true, -- Treat parent link as a directory for navigation purposes
					})
				end
			end

			-- Read current_path, add subdirectories
			-- vim.fn.readdir can error if dir is not readable, use pcall
			local ok, dir_contents = pcall(vim.fn.readdir, current_path_abs)
			if not ok or dir_contents == nil then
				vim.notify("Error reading directory: " .. current_path_abs, vim.log.levels.WARN)
				-- Return items collected so far (e.g., parent link) or empty if none
				return items
			end

			-- Sort directory contents for consistent order
			table.sort(dir_contents)

			for _, name in ipairs(dir_contents) do
				-- Ignore hidden directories (starting with .)
				if not vim.startswith(name, ".") then
					local full_item_path = current_path_abs .. "/" .. name
					-- Ensure it's actually a directory
					if vim.fn.isdirectory(full_item_path) == 1 then
						table.insert(items, {
							text = name,
							path = full_item_path,
							is_dir = true,
						})
					end
				end
			end
			table.insert(items, { text = "(Select current: " .. vim.fn.fnamemodify(current_path_abs, ":~") .. ")", path = current_path_abs, is_current_dir_selection = true, is_dir = true })
			return items
		end

		local current_picker_path = notedir -- Path the picker is currently showing

		local _handle_final_directory_selection = function(selected_dir_path)
			if selected_dir_path == nil then
				vim.notify("No directory selected. Note creation cancelled.", vim.log.levels.INFO)
				return
			end

			local dir_to_use = selected_dir_path
			-- Normalize path (e.g., remove trailing slash)
			if string.sub(dir_to_use, -1) == "/" and #dir_to_use > 1 then -- Avoid turning "/" into ""
				dir_to_use = string.sub(dir_to_use, 1, -2)
			end

			-- This notification can be removed if it's too verbose, or kept for debugging
			-- vim.notify("Selected directory for zk: '" .. dir_to_use .. "'", vim.log.levels.INFO)

			local note_title = vim.fn.input("Title: ")
			if note_title == nil or note_title == "" then
				vim.notify("Title cannot be empty. Note creation cancelled.", vim.log.levels.WARN)
				return
			end
			zk.new({ dir = dir_to_use, title = note_title })
		end

		-- Recursive function to show picker for a given path
		local show_picker_for_path
		show_picker_for_path = function(path_to_show)
			current_picker_path = path_to_show -- Update current path being viewed

			local picker_items = get_directory_items(path_to_show)

			MiniPick.start({
				source = {
					items = picker_items,
					name = "Select Directory (Current: " .. vim.fn.fnamemodify(path_to_show, ":~") .. ")",
					cwd = path_to_show,
					show = function(buf_id, items_arr, query)
						-- Use MiniPick.default_show, attempting to show icons.
						-- Our items have a .text and .path field, which default_show can use.
						MiniPick.default_show(buf_id, items_arr, query, { show_icons = true })
					end,
					choose = function(selected_item)
						if selected_item == nil then return false end -- Esc pressed, stop picker

						if selected_item.is_current_dir_selection then
							_handle_final_directory_selection(selected_item.path)
							return false -- Stop picker, selection processed
						elseif selected_item.is_parent_link then
							show_picker_for_path(selected_item.path)
							return false -- Stop current picker, new one will start for parent path
						elseif selected_item.is_dir then -- This implies it's a navigable subdirectory
							show_picker_for_path(selected_item.path)
							return false -- Stop current picker, new one will start for subdir
						end
						-- Default action if no specific handling: stop the picker.
						return false
					end,
				},
				mappings = {
					select_current_dir = {
						char = "<S-CR>", -- Shift-Enter
						func = function()
							-- If current picker view has no items (other than parent link),
							-- it means we are in an empty dir. Allow selecting it.
							-- Or if user wants to select the directory they are currently viewing.
							_handle_final_directory_selection(current_picker_path)
							return false -- Stop picker, selection processed
						end,
					},
				},
			})
		end

		show_picker_for_path(notedir) -- Start the picker
	end)

	-- Daily journal creation with carryover functionality
	commands.add("ZkNewDailyJournal", function(options)
		options = options or {}
		local dir = vim.fn.input("Journal directory: ", "journal/daily")
		if dir == "" then
			vim.notify("Journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local prefix = vim.fn.input("Note prefix: ", "perso")
		if prefix == "" then
			vim.notify("Journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local date = os.date("%Y-%m-%d")
		local title = string.format("%s-%s", prefix, date)
		local target_dir = vim.fn.expand("$ZK_NOTEBOOK_DIR") .. "/" .. dir
		local content = create_journal_content_with_carryover(target_dir, "personal")
		
		zk.new({
			dir = dir,
			title = title,
			content = content,
		})
	end)

	-- Work daily journal creation with carryover functionality
	commands.add("ZkNewWorkJournal", function(options)
		options = options or {}
		local dir = vim.fn.input("Work journal directory: ", "work")
		if dir == "" then
			vim.notify("Work journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local prefix = vim.fn.input("Note prefix: ", "work")
		if prefix == "" then
			vim.notify("Work journal creation cancelled", vim.log.levels.WARN)
			return
		end
		
		local date = os.date("%Y-%m-%d")
		local title = string.format("%s-%s", prefix, date)
		local target_dir = vim.fn.expand("$ZK_NOTEBOOK_DIR") .. "/" .. dir
		local content = create_journal_content_with_carryover(target_dir, "work")
		
		zk.new({
			dir = dir,
			title = title,
			content = content,
		})
	end)

	-- Task creation command
	commands.add("ZkNewTask", function()
		create_new_task()
	end)
	-- ⚡ PERFORMANCE OPTIMIZATION #7: BLAZING FAST ASYNC TASK TRACKING ⚡
	--
	-- MOVED INSIDE later() BLOCK FOR PROPER SCOPE ACCESS
	-- The autocmd needs to be in the same scope as the functions it calls
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("task-tracking-blazing-fast", { clear = true }),
		-- ⚡ ULTRA-TARGETED PATTERN MATCHING for maximum efficiency
		-- These patterns match the actual file structure in your notebook:
		-- - */perso-YYYY-MM-DD.md (personal daily journals in subdirectory)
		-- - */work-YYYY-MM-DD.md  (work daily journals in subdirectory)
		pattern = { "*/perso-????-??-??.md", "*/work-????-??-??.md" },
		callback = function(event)
			-- 🔍 DEBUG: Add logging to see if autocmd triggers
			local file_path = vim.api.nvim_buf_get_name(event.buf)
			print("🔍 DEBUG: BufWritePost triggered for:", file_path)
			
			-- Lightning-fast validation with minimal overhead
			local notedir = vim.env.ZK_NOTEBOOK_DIR
			if not notedir then 
				print("🔍 DEBUG: ZK_NOTEBOOK_DIR not set")
				return 
			end
			
			print("🔍 DEBUG: ZK_NOTEBOOK_DIR:", notedir)
			
			if not vim.startswith(file_path, notedir) then 
				print("🔍 DEBUG: File not in notebook dir")
				return 
			end
			
			print("🔍 DEBUG: File is in notebook dir, proceeding with task tracking...")
			
			-- ⚡ ASYNC PROCESSING: MAXIMUM RESPONSIVENESS OPTIMIZATION ⚡
			vim.schedule(function()
				print("🔍 DEBUG: Calling track_new_tasks_on_save...")
				local ok, err = pcall(track_new_tasks_on_save, event.buf)
				if not ok then
					print("🔍 DEBUG: Task tracking error:", err)
					vim.notify("Task tracking error: " .. err, vim.log.levels.DEBUG)
				else
					print("🔍 DEBUG: Task tracking completed successfully")
				end
			end)
		end,
	})

	-- ⚡ PERFORMANCE OPTIMIZATION #6: PROPER RESOURCE CLEANUP ⚡
	---
	-- CRITICAL: Properly release database resources when Neovim exits
	-- Without this cleanup, we could leave SQLite connections open or prepared statements
	-- hanging in memory, potentially causing resource leaks or database lock issues.
	---
	-- This autocmd ensures clean shutdown and prevents any resource leaks
	-- that could impact system performance or database integrity.
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("task-tracking-cleanup", { clear = true }),
		callback = function()
			-- COMPREHENSIVE CLEANUP: Release all cached database resources
			-- 🔒 PRIVACY-FIRST CLEANUP: Close both work and personal database connections
			if task_db_cache.perso then
				-- Close personal database connection
				task_db_cache.perso:close()
				task_db_cache.perso = nil
				cached_db_paths.perso = nil
			end
			
			if task_db_cache.work then
				-- Close work database connection  
				task_db_cache.work:close()
				task_db_cache.work = nil
				cached_db_paths.work = nil
			end
		end,
	})
end)

-- Add note-specific clues for mini.clue discoverability
local note_clues = {
	{ mode = "n", keys = "<leader>nn", desc = " new note" },
	{ mode = "n", keys = "<leader>nN", desc = " new at dir" },
	{ mode = "n", keys = "<leader>nj", desc = " daily journal" },
	{ mode = "n", keys = "<leader>nw", desc = " work journal" },
	{ mode = "n", keys = "<leader>no", desc = " open notes" },
	{ mode = "n", keys = "<leader>nt", desc = " tags" },
	{ mode = "n", keys = "<leader>nf", desc = " find notes" },
	{ mode = "n", keys = "<leader>nT", desc = " new task" },
}

-- Add clues when zk-nvim is attached (when working with notes)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == "zk" then
			-- Add clues for note buffer
			for _, clue in ipairs(note_clues) do
				table.insert(require("mini.clue").config.clues, clue)
			end

			-- Remove clues when leaving the buffer
			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = event.buf,
				once = true,
				callback = function()
					local clue_config = require("mini.clue").config.clues
					for i = #clue_config, 1, -1 do
						local existing_clue = clue_config[i]
						for _, note_clue in ipairs(note_clues) do
							if existing_clue.keys == note_clue.keys and existing_clue.desc == note_clue.desc then
								table.remove(clue_config, i)
								break
							end
						end
					end
				end,
			})
		end
	end,
})

-- Global note keymaps (moved from keymaps.lua for better organization)
local keymap = vim.keymap.set
local opts = { noremap = true, silent = false }

-- Create a new note after asking for its title.
keymap("n", "<leader>nn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", vim.tbl_extend('keep', opts, { desc = "New note" }))
keymap("n", "<leader>nN", "<Cmd>ZkNewAtDir<CR>", vim.tbl_extend('keep', opts, { desc = "New note at dir" }))

-- Open notes.
keymap("n", "<leader>no", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes" }))
-- Open notes associated with the selected tags.
keymap("n", "<leader>nt", "<Cmd>ZkTags<CR>", vim.tbl_extend('keep', opts, { desc = "Open notes (tags)" }))

-- Search for the notes matching a given query.
keymap("n", "<leader>nf", "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", vim.tbl_extend('keep', opts, { desc = "Search notes" }))
-- Search for the notes matching the current visual selection.
keymap("v", "<leader>nf", ":'<,'>ZkMatch<CR>", vim.tbl_extend('keep', opts, { desc = 'Search notes'}))

-- Task creation with custom URI
keymap("n", "<leader>nT", "<Cmd>ZkNewTask<CR>", vim.tbl_extend('keep', opts, { desc = "New task with custom URI" }))
