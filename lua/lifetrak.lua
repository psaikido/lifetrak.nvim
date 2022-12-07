M = {}

M.view_down = function()
    vim.cmd('execute "normal! /^---$\rzt:nohlsearch\r"')
end

M.view_up = function()
    vim.cmd('execute "normal! ?^---$\rzt:nohlsearch\r"')
end

return M
