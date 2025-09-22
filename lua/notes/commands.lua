-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 CUSTOM NOTES COMMANDS WITH UUID SUPPORT
-- ═══════════════════════════════════════════════════════════════════════

local M = {}

-- Import dependencies once at top of file
local utils = require("notes.utils")

-- Note: Task creation with UUID is handled by the original ZkNewTask command
-- which now uses UUID v7 via the updated M._generate_uuid() function

-- Generate a new note with UUID in front matter
function M.new_note_with_uuid()
	local note_uuid = utils.generate_uuid_v7()
	local title = vim.fn.input("Note title: ")
	
	if title ~= "" then
		local content = string.format([[---
id: %s
title: %s
created: %s
tags: []
---

# %s

]], note_uuid, title, os.date("%Y-%m-%d %H:%M:%S"), title)
		
		-- Create new buffer with content
		vim.cmd("enew")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
		vim.notify("📝 Created note with UUID: " .. note_uuid:sub(1, 8), vim.log.levels.INFO)
	end
end

-- Add UUID to current note (if it doesn't have one)
function M.add_uuid_to_current_note()
	local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
	
	-- Check if note already has UUID
	local has_uuid = false
	for _, line in ipairs(lines) do
		if line:match("id:%s*%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
			has_uuid = true
			break
		end
	end
	
	if has_uuid then
		vim.notify("📋 Note already has a UUID", vim.log.levels.WARN)
		return
	end
	
	local note_uuid = utils.generate_uuid_v7()
	local uuid_comment = "<!-- Note ID: " .. note_uuid .. " -->"
	
	-- Add UUID at the top
	vim.fn.append(0, uuid_comment)
	vim.notify("🆔 Added UUID: " .. note_uuid:sub(1, 8), vim.log.levels.INFO)
end

return M
