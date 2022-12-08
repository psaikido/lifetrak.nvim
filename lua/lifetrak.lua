M = {}

local utils = require('utils')

M.journal_entry = function()
    local header = M._make_header()

    -- add 4 blank lines at the top
    local num = 1
    while num <= 4 do
        vim.api.nvim_buf_set_lines(0, 0, 0, false, {""})
        num = num + 1
    end

    -- write all the header rows to the top of the document
    for k, v in pairs(header) do
        k = k - 1 -- buffer index is 0 based, lua is 1 based
        vim.api.nvim_buf_set_lines(0, k, k, false, {v})
    end

    -- put cursor at line 10
    vim.api.nvim_buf_set_mark(0, 'a', 10, 0, {})
    vim.cmd("'a")
end


M._make_header = function()
    local header = {}

    table.insert(header, "---")

    -- create a formatted 'today'
    local today = vim.fn.strftime('%Y-%m-%d %a')
    table.insert(header, "# " .. today)
    
    -- make an incremented journal id
    -- get the 3rd line which should have the last id
    local id_line = vim.api.nvim_buf_get_lines(0, 2, 3, false)
    local id = string.match(id_line[1], '%d+')
    local next_id = id + 1
    local header_id = "# id: " .. next_id 
    table.insert(header, header_id)

    -- add the 'meta' categories or 'tags'
    for _, v in pairs(M._get_metas()) do
        table.insert(header, v)
    end

    -- add the final 'tag'
    table.insert(header, "- tag: ")
    
    return header
end


M._get_metas = function()
    local formatted_metas = {}

    for _, v in pairs(vim.g.lifetrak_metas) do
        local formatted_meta = "- " .. v .. ": "
        table.insert(formatted_metas, formatted_meta)
    end

    return formatted_metas
end


M.view_down = function()
    vim.cmd('execute "normal! /^---$\rzt:nohlsearch\r"')
end


M.view_up = function()
    vim.cmd('execute "normal! ?^---$\rzt:nohlsearch\r"')
end


M.choose_tag = function()
end


return M
