-- ⚡ NOTES VISUALIZATION MODULE ⚡
-- Main module providing task visualization capabilities for event-sourced notes
-- Configurable, modular, and integrated with your existing task tracking system

local plot = require('notes.plot')
local utils = require('notes.utils')

local M = {}

-- Default configuration
local default_config = {
	-- Database configuration
	database = {
		personal_path = nil,  -- Will use ZK_PERSO_TASK_DB_PATH or auto-detect
		work_path = nil,      -- Will use ZK_WORK_TASK_DB_PATH or auto-detect
	},
	
	-- Chart defaults
	charts = {
		histogram = {
			width = 50,
			height = 10,
			show_values = true
		},
		pie_chart = {
			radius = 8,
			style = "solid",  -- "solid", "pattern", "unicode"
			show_legend = true,
			show_percentages = true
		},
		line_plot = {
			width = 60,
			height = 15,
			show_axes = true
		},
		table = {
			show_borders = true,
			max_rows = 10
		}
	},
	
	-- Data processing
	data = {
		date_format = "short",  -- "short", "medium", "long", "relative"
		truncate_length = 30,
		productivity_weights = {
			created = 1,
			completed = 2,
			carried_over = -1
		}
	},
	
	-- Display options
	display = {
		use_emojis = true,
		show_debug = false
	}
}

-- Module configuration (will be set by setup())
local config = {}

-- Deep copy utility for compatibility
local function deep_copy(orig)
	local copy
	if type(orig) == 'table' then
		copy = {}
		for k, v in pairs(orig) do
			copy[k] = deep_copy(v)
		end
	else
		copy = orig
	end
	return copy
end

-- Deep merge utility for compatibility
local function deep_merge(base, override)
	if vim and vim.tbl_deep_extend then
		return vim.tbl_deep_extend("force", base, override)
	else
		local result = deep_copy(base)
		for k, v in pairs(override) do
			if type(v) == "table" and type(result[k]) == "table" then
				result[k] = deep_merge(result[k], v)
			else
				result[k] = v
			end
		end
		return result
	end
end

-- Initialize config with deep copy
config = deep_copy(default_config)

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 SETUP AND CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════

-- Setup the notes visualization module
-- @param user_config: optional configuration overrides
function M.setup(user_config)
	-- Merge user config with defaults
	if user_config then
		config = deep_merge(default_config, user_config)
	end
	
	if config.display.show_debug then
		-- Compatibility: use vim.inspect if available, otherwise simple print
		local inspect_func = (vim and vim.inspect) or tostring
		print("🔍 Notes module configured:", inspect_func(config))
	end
end

-- Get current configuration
function M.get_config()
	return config
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🗄️ DATABASE CONNECTION UTILITIES
-- ═══════════════════════════════════════════════════════════════════════

-- Get database connection (reuses your existing logic)
-- @param db_type: "personal" or "work"
-- @return: database connection or nil
local function get_database(db_type)
	local sqlite = require("sqlite")
	local db_path
	
	if db_type == "personal" or db_type == "perso" then
		db_path = config.database.personal_path or vim.env.ZK_PERSO_TASK_DB_PATH
		if not db_path or db_path == "" then
			local notedir = vim.env.ZK_NOTEBOOK_DIR
			if notedir and notedir ~= "" then
				db_path = notedir .. "/.perso-tasks.db"
			end
		end
	elseif db_type == "work" then
		db_path = config.database.work_path or vim.env.ZK_WORK_TASK_DB_PATH  
		if not db_path or db_path == "" then
			local notedir = vim.env.ZK_NOTEBOOK_DIR
			if notedir and notedir ~= "" then
				db_path = notedir .. "/.work-tasks.db"
			end
		end
	end
	
	if not db_path then
		if config.display.show_debug then
			print("🔍 No database path configured for:", db_type)
		end
		return nil
	end
	
	-- Expand environment variables and paths (compatibility layer)
	if vim and vim.fn and vim.fn.expand then
		db_path = vim.fn.expand(db_path)
	else
		-- Simple environment variable expansion for standalone usage
		db_path = db_path:gsub("$([%w_]+)", os.getenv)
		if db_path:match("^~") then
			db_path = db_path:gsub("^~", os.getenv("HOME") or "")
		end
	end
	
	-- Check if database file exists (compatibility layer)
	local file_exists = false
	if vim and vim.fn and vim.fn.filereadable then
		file_exists = vim.fn.filereadable(db_path) == 1
	else
		-- Fallback for standalone usage
		local f = io.open(db_path, "r")
		if f then
			f:close()
			file_exists = true
		end
	end
	
	if not file_exists then
		if config.display.show_debug then
			print("🔍 Database file not found:", db_path)
		end
		return nil
	end
	
	local db = sqlite.new(db_path)
	if db and db.open then
		db:open()
	end
	
	return db
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 HIGH-LEVEL VISUALIZATION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════

-- Show daily completion histogram
-- @param db_type: "personal" or "work"
-- @param days: number of days to analyze (default 7)
-- @param opts: chart options override
function M.daily_completions(db_type, days, opts)
	db_type = db_type or "personal"
	days = tonumber(days) or 7
	
	local db = get_database(db_type)
	if not db then
		print("❌ Database not available for " .. db_type .. " tasks")
		return
	end
	
	local sql = string.format([[
		SELECT 
			date(timestamp) as day,
			COUNT(*) as count
		FROM task_events 
		WHERE event_type = 'task_completed' 
			AND date(timestamp) >= date('now', '-%d days')
		GROUP BY date(timestamp)
		ORDER BY day
	]], days)
	
	local results = db:eval(sql)
	db:close()
	
	if not results or #results == 0 then
		print("📊 No completion data found for the last " .. days .. " days")
		return
	end
	
	-- Convert to chart data
	local chart_data = utils.sql_to_chart_data(results, "day", "count")
	
	-- Format dates if requested
	if config.data.date_format ~= "raw" then
		for _, item in ipairs(chart_data) do
			item.label = utils.format_date(item.label, config.data.date_format)
		end
	end
	
	-- Create chart
	local chart_opts = deep_merge(config.charts.histogram, opts or {})
	chart_opts.title = string.format("📊 Daily Completions - %s (%d days)", 
		string.upper(db_type), days)
	
	local chart = plot.histogram(chart_data, chart_opts)
	
	-- Display
	for _, line in ipairs(chart) do
		print(line)
	end
end

-- Show task state distribution pie chart  
-- @param db_type: "personal" or "work"
-- @param opts: chart options override
function M.task_states(db_type, opts)
	db_type = db_type or "personal"
	
	local db = get_database(db_type)
	if not db then
		print("❌ Database not available for " .. db_type .. " tasks")
		return
	end
	
	local sql = [[
		WITH latest_states AS (
			SELECT 
				task_id,
				state,
				ROW_NUMBER() OVER (PARTITION BY task_id ORDER BY timestamp DESC, event_id DESC) as rn
			FROM task_events
		)
		SELECT 
			state,
			COUNT(*) as count
		FROM latest_states 
		WHERE rn = 1 AND state != 'DELETED'
		GROUP BY state
		ORDER BY count DESC
	]]
	
	local results = db:eval(sql)
	db:close()
	
	if not results or #results == 0 then
		print("🥧 No task state data found")
		return
	end
	
	-- Convert to chart data with emojis
	local chart_data = {}
	for _, row in ipairs(results) do
		local label = config.display.use_emojis and 
			utils.add_state_emoji(row.state) or 
			tostring(row.state)
		
		table.insert(chart_data, {
			label = label,
			value = tonumber(row.count)
		})
	end
	
	-- Create chart
	local chart_opts = deep_merge(config.charts.pie_chart, opts or {})
	chart_opts.title = string.format("🥧 Task States - %s", string.upper(db_type))
	
	local chart = plot.pie_chart(chart_data, chart_opts)
	
	-- Display
	for _, line in ipairs(chart) do
		print(line)
	end
end

-- Show recent task activity table
-- @param db_type: "personal" or "work"  
-- @param limit: number of recent events to show
-- @param opts: chart options override
function M.recent_activity(db_type, limit, opts)
	db_type = db_type or "personal"
	limit = tonumber(limit) or config.charts.table.max_rows
	
	local db = get_database(db_type)
	if not db then
		print("❌ Database not available for " .. db_type .. " tasks")
		return
	end
	
	local sql = string.format([[
		SELECT 
			task_text,
			event_type,
			state,
			date(timestamp) as event_date,
			substr(timestamp, 12, 5) as event_time
		FROM task_events 
		WHERE task_text IS NOT NULL AND task_text != ''
		ORDER BY timestamp DESC 
		LIMIT %d
	]], limit)
	
	local results = db:eval(sql)
	db:close()
	
	if not results or #results == 0 then
		print("📋 No recent activity found")
		return
	end
	
	-- Convert to table data  
	local table_data = {}
	for _, row in ipairs(results) do
		local task_text = utils.clean_task_text(row.task_text)
		task_text = utils.truncate_text(task_text, config.data.truncate_length)
		
		local event_text = config.display.use_emojis and 
			utils.add_event_emoji(row.event_type) or
			tostring(row.event_type)
		
		local state_text = config.display.use_emojis and 
			utils.add_state_emoji(row.state) or
			tostring(row.state)
		
		local date_text = utils.format_date(row.event_date, config.data.date_format)
		
		table.insert(table_data, {
			task_text,
			event_text, 
			state_text,
			date_text,
			row.event_time
		})
	end
	
	-- Create table
	local table_opts = deep_merge(config.charts.table, opts or {})
	table_opts.title = string.format("📋 Recent Activity - %s (Last %d events)", 
		string.upper(db_type), limit)
	table_opts.headers = {"Task", "Event", "State", "Date", "Time"}
	
	local chart = plot.table(table_data, table_opts)
	
	-- Display
	for _, line in ipairs(chart) do
		print(line)
	end
end

-- Show productivity trend line plot
-- @param db_type: "personal" or "work"
-- @param days: number of days to analyze (default 14)
-- @param opts: chart options override
function M.productivity_trend(db_type, days, opts)
	db_type = db_type or "personal"
	days = tonumber(days) or 14
	
	local db = get_database(db_type)
	if not db then
		print("❌ Database not available for " .. db_type .. " tasks")
		return
	end
	
	local sql = string.format([[
		WITH daily_metrics AS (
			SELECT 
				date(timestamp) as day,
				SUM(CASE WHEN event_type = 'task_created' THEN 1 ELSE 0 END) as created,
				SUM(CASE WHEN event_type = 'task_completed' THEN 1 ELSE 0 END) as completed,
				SUM(CASE WHEN event_type = 'task_carried_over' THEN 1 ELSE 0 END) as carried_over
			FROM task_events 
			WHERE date(timestamp) >= date('now', '-%d days')
			GROUP BY date(timestamp)
		)
		SELECT 
			day,
			created,
			completed, 
			carried_over
		FROM daily_metrics
		ORDER BY day
	]], days)
	
	local results = db:eval(sql)
	db:close()
	
	if not results or #results == 0 then
		print("📈 No productivity data found for the last " .. days .. " days")
		return
	end
	
	-- Calculate productivity scores
	local chart_data = {}
	for _, row in ipairs(results) do
		local score = utils.calculate_productivity_score(
			row.created, 
			row.completed, 
			row.carried_over,
			config.data.productivity_weights
		)
		
		local label = utils.format_date(row.day, config.data.date_format)
		
		table.insert(chart_data, {
			label = label,
			value = score
		})
	end
	
	-- Create chart
	local chart_opts = deep_merge(config.charts.line_plot, opts or {})
	chart_opts.title = string.format("📈 Productivity Trend - %s (%d days)", 
		string.upper(db_type), days)
	
	local chart = plot.line_plot(chart_data, chart_opts)
	
	-- Display
	for _, line in ipairs(chart) do
		print(line)
	end
	
	-- Show formula explanation
	local w = config.data.productivity_weights
	print(string.format("Formula: Created×%d + Completed×%d + CarriedOver×%d", 
		w.created, w.completed, w.carried_over))
end

-- Show comprehensive dashboard
-- @param db_type: "personal" or "work"
-- @param opts: options {days = 7, compact = false}
function M.dashboard(db_type, opts)
	db_type = db_type or "personal"
	opts = opts or {}
	local days = opts.days or 7
	local compact = opts.compact or false
	
	print(string.format("\n🎯 TASK ANALYTICS DASHBOARD - %s", string.upper(db_type)))
	print("═" .. string.rep("═", 60))
	
	-- Task states overview
	M.task_states(db_type, compact and {radius = 6, show_legend = false} or nil)
	print()
	
	-- Daily completions
	M.daily_completions(db_type, days, compact and {width = 30} or nil)
	print()
	
	-- Productivity trend
	M.productivity_trend(db_type, days * 2, compact and {width = 40, height = 8} or nil)
	print()
	
	-- Recent activity
	M.recent_activity(db_type, compact and 3 or 5)
	print()
	
	print("📊 Dashboard generated at " .. os.date("%Y-%m-%d %H:%M:%S"))
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🚀 CONVENIENCE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════

-- Quick personal dashboard
function M.personal()
	M.dashboard("personal")
end

-- Quick work dashboard  
function M.work()
	M.dashboard("work")
end

-- Quick completions for personal tasks
function M.completions(days)
	M.daily_completions("personal", days)
end

-- Quick states for personal tasks
function M.states()
	M.task_states("personal")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 DIRECT ACCESS TO SUBMODULES
-- ═══════════════════════════════════════════════════════════════════════

-- Expose plotting functions for advanced usage
M.plot = plot

-- Expose utilities for advanced data processing
M.utils = utils

return M
