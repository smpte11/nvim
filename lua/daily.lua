local M = {}

function M.create_daily_note()
    local notedir = vim.env.ZK_NOTEBOOK_DIR
    if notedir == nil or notedir == "" then
        vim.notify("ZK_NOTEBOOK_DIR is not set.", vim.log.levels.ERROR)
        return
    end

    -- Get yesterday's date
    local yesterday = os.date("!%Y-%m-%d", os.time() - 24 * 60 * 60)
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
        content = table.concat(unfulfilled_tasks, "\n")
    end

    local zk = require("zk")
    zk.new({ dir = "journal/daily", date = "today", content = content })
end

return M
