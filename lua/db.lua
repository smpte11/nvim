local M = {}

local sqlite3 = require("lsqlite3")
local cjson = require("cjson")

local db_path = vim.fn.stdpath("data") .. "/stats.db"

local function get_db()
	return sqlite3.open(db_path)
end

function M.setup()
	local db = get_db()
	if not db then
		vim.notify("Failed to open database", vim.log.levels.ERROR)
		return
	end

	local schema_sql = [[
        CREATE TABLE IF NOT EXISTS events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id TEXT,
            event_type TEXT NOT NULL,
            payload TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_events_task_id ON events (task_id);
    ]]
	local result = db:exec(schema_sql)
	if result ~= sqlite3.OK then
		vim.notify("Failed to apply schema: " .. db:errmsg(), vim.log.levels.ERROR)
	end
	db:close()
end

function M.log_event(event_type, task_id, payload)
	local db = get_db()
	if not db then
		vim.notify("Failed to open database", vim.log.levels.ERROR)
		return
	end

	local insert_sql = [[
        INSERT INTO events (event_type, task_id, payload)
        VALUES (?, ?, ?);
    ]]
	local stmt, err = db:prepare(insert_sql)
	if not stmt then
		vim.notify("Failed to prepare insert statement: " .. err, vim.log.levels.ERROR)
		db:close()
		return
	end

	local payload_json = cjson.encode(payload)

	stmt:bind_values(event_type, task_id, payload_json)
	local result = stmt:step()
	if result ~= sqlite3.DONE then
		vim.notify("Failed to insert event: " .. db:errmsg(), vim.log.levels.ERROR)
	end

	stmt:finalize()
	db:close()
end

function M.get_carried_over_tasks_count()
	local db = get_db()
	if not db then
		vim.notify("Failed to open database", vim.log.levels.ERROR)
		return 0
	end

	local count_sql = [[
        SELECT COUNT(*) FROM events WHERE event_type = 'task_carried_over';
    ]]
	for count in db:urows(count_sql) do
		db:close()
		return count
	end
	db:close()
	return 0
end

function M.get_last_event_for_task(task_id)
	local db = get_db()
	if not db then
		vim.notify("Failed to open database", vim.log.levels.ERROR)
		return nil
	end

	local query_sql = [[
        SELECT event_type, payload FROM events
        WHERE task_id = ?
        ORDER BY timestamp DESC
        LIMIT 1;
    ]]
	local stmt, err = db:prepare(query_sql)
	if not stmt then
		vim.notify("Failed to prepare select statement: " .. err, vim.log.levels.ERROR)
		db:close()
		return nil
	end

	stmt:bind_values(task_id)

	local event = nil
	if stmt:step() == sqlite3.ROW then
		event = stmt:get_named_values()
	end

	stmt:finalize()
	db:close()
	return event
end

return M
