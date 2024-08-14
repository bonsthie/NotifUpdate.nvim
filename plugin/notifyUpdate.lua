local Job = require('plenary.job')
local notify = require("notify")

local update_keymap = vim.g.nvim_config_update_keymap or '<leader>uc'

local function perform_update()
    Job:new({
        command = 'git',
        args = { 'pull' },
        cwd = vim.fn.stdpath('config'),
        on_exit = function(j)
            local update_log = table.concat(j:result(), '\n')
            notify("Configuration Updated: \n\n" .. update_log, "info", { title = "Neovim Config Status" })
            notify("Config is up to date !!", "info", { title = "Neovim Config Status" })
        end,
    }):start()
end

local function notify_update_available()
    Job:new({
        command = 'git',
        args = { 'log', '-1', '--pretty=%B' },
        cwd = vim.fn.stdpath('config'),
        on_exit = function(j)
            local commit_message = table.concat(j:result(), '\n')
            notify(
                "New Nvim config update available: \n\n" .. commit_message .. "\n\nPress " .. update_keymap .. " to update.",
                "warn",
                { title = "Neovim Config Status" }
            )
        end,
    }):start()
end

local function check_for_config_update()
    Job:new({
        command = 'git',
        args = { 'remote', 'update' },
        cwd = vim.fn.stdpath('config'),
        on_exit = function()
            Job:new({
                command = 'git',
                args = { 'status', '-uno' },
                cwd = vim.fn.stdpath('config'),
                on_exit = function(j)
                    local result = table.concat(j:result(), '\n')
                    if result:find('Your branch is behind') then
                        notify_update_available()
                    end
                end,
            }):start()
        end,
    }):start()
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        check_for_config_update()
    end
})

vim.keymap.set('n', update_keymap, perform_update, { silent = true })
