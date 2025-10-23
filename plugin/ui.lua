-- Uses global: spec (from 00-bootstrap.lua)
-- Create dot-repeatable zen width adjustment functions using operatorfunc
-- (Defined globally so they're available before plugin loads)
function _G.__zen_width_increase(motion)
    if motion == nil then
        vim.o.operatorfunc = "v:lua.__zen_width_increase"
        return "g@l" -- Use minimal motion to execute immediately
    end
    -- Execute the actual width increase (called after motion)
    -- vim.v.count1 starts from 1 (unlike vim.v.count which starts from 0)
    local count = vim.v.count1
    for i = 1, count do
        vim.cmd("NoNeckPainWidthUp")
    end
end

function _G.__zen_width_decrease(motion)
    if motion == nil then
        vim.o.operatorfunc = "v:lua.__zen_width_decrease"
        return "g@l" -- Use minimal motion to execute immediately
    end
    -- Execute the actual width decrease (called after motion)
    local count = vim.v.count1
    for i = 1, count do
        vim.cmd("NoNeckPainWidthDown")
    end
end

spec({
    source = "shortcuts/no-neck-pain.nvim",
    config = function()
        require("no-neck-pain").setup({
            mappings = {
                enabled = false
            }
        })
    end,
    -- stylua: ignore start
    keys = {
        { "<leader>uzt", "<cmd>NoNeckPain<cr>", desc = "Toggle" },
        { "<leader>uzl", "<cmd>NoNeckPainToggleLeftSide<cr>", desc = "Toggle Left Side" },
        { "<leader>uzr", "<cmd>NoNeckPainToggleRightSide<cr>", desc = "Toggle Right Side" },
        { "<leader>uz=", _G.__zen_width_increase, expr = true, desc = "Increase Width (dot-repeatable)" },
        { "<leader>uz-", _G.__zen_width_decrease, expr = true, desc = "Decrease Width (dot-repeatable)" },
        { "<leader>uzs", "<cmd>NoNeckPainScratchPad<cr>", desc = "Toggle ScratchPad" },
    }
    -- stylua: ignore end
})

spec({
    source = "HakonHarnes/img-clip.nvim",
    -- rocks = { "magick" }, -- Example of rock
    config = function()
        require("img-clip").setup({
            -- add options here
            -- or leave it empty to use the default settings
        })
    end
})
