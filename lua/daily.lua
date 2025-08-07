local M = {}

function M.create_daily_note()
    local notedir = vim.env.ZK_NOTEBOOK_DIR
    if notedir == nil or notedir == "" then
        vim.notify("ZK_NOTEBOOK_DIR is not set.", vim.log.levels.ERROR)
        return
    end

    -- Get yesterday's date
    -- Get yesterday's date robustly
    local now = os.date("!*t")
    now.day = now.day - 1
    local yesterday = os.date("!%Y-%m-%d", os.time(now))
    local yesterday_note_path = notedir .. "/journal/daily/" .. yesterday .. ".md"

    local unfulfilled_tasks = {}
    local file = io.open(yesterday_note_path, "r")
    if file then
        for line in file:lines() do
            if line:match("^%s*-%s*%[ %]") then
                table.insert(unfulfilled_tasks, line)
            end
        end
        file:close()
    end

    local content = ""
    if #unfulfilled_tasks > 0 then
        content = "## Carried over from yesterday\n\n" .. table.concat(unfulfilled_tasks, "\n") .. "\n\n"
    end

    local zk = require("zk")
    zk.new({ dir = "journal/daily", date = "today", content = content })
end

return M
