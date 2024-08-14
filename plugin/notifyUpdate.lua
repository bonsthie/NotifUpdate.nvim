local Job = require('plenary.job')

-- Define a function to check for updates
local function check_for_config_update()
    -- Ensure nvim-notify is loaded
    vim.notify = require("notify")

    Job:new({
        command = 'git',
        args = {'remote', 'update'},
        cwd = vim.fn.stdpath('config'),
        on_exit = function()
            -- Check the status of the local branch
            Job:new({
                command = 'git',
                args = {'status', '-uno'},
                cwd = vim.fn.stdpath('config'),
                on_exit = function(j, return_val)
                    local result = table.concat(j:result(), '\n')
                    if result:find('Your branch is behind') then
						print ("Need update")
                        vim.notify("Need update", "warn", { title = "Neovim Config Status" })
                    else
						print ("Up to date")
                        vim.notify("Up to date", "info", { title = "Neovim Config Status" })
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
