pick_chezmoi = function()
    local pick = MiniPick

    -- Define the source items
    local source_items = require("chezmoi.commands").list()

    -- Start the picker
    pick.start({
        source = {
            items = source_items,
            choose = function(selected)
                require("chezmoi.commands").edit({
                    targets = { "~/" .. selected[1] },
                    args = { "--watch" }
                })
            end,
        },
    })
end

vim.api.nvim_command('command! ChezmoiPick lua pick_chezmoi()')
