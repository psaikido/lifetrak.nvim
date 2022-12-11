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

    table.insert(header, '---')

    -- create a formatted 'today'
    local today = vim.fn.strftime('%Y-%m-%d %a')
    table.insert(header, '# ' .. today)
    
    -- make an incremented journal id
    -- get the 3rd line which should have the last id
    local id_line = vim.api.nvim_buf_get_lines(0, 2, 3, false)
    local id = string.match(id_line[1], '%d+')
    local next_id = id + 1
    local header_id = '# id: ' .. next_id 
    table.insert(header, header_id)

    -- add the 'meta' categories or 'tags'
    for _, v in pairs(M._get_metas()) do
        table.insert(header, v)
    end

    -- add the final 'tag'
    table.insert(header, '- tags: ')
    
    return header
end


M._get_metas = function()
    local formatted_metas = {}

    for _, v in pairs(vim.g.lifetrak_metas) do
        local formatted_meta = '- ' .. v .. ': '
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
    local tags = M.get_tags()
    local tag_prompts = 'Choose a tag: ' .. vim.inspect(tags) .. ': '
    vim.ui.input({ prompt = tag_prompts }, function(input)
        M._filter_by_tag(input)
    end)
end


M._filter_by_tag = function(tag)
    local chosen_tags = {}

    for k, v in pairs(M._get_whole_buffer()) do
        if (string.match(v, '- tags:') and string.match(v, tag)) then
            table.insert(chosen_tags, {k, v})
        end
    end

    local output = M._build_output(chosen_tags)
end


M._build_output = function(tags)
    local entries = {}

    for k, v in pairs(tags) do
        local entry = M._get_entry(v[1])
        table.insert(entries, entry)
    end

    M._output(entries)
end


M._get_entry = function(entry_line_no)
    local entry = {}
    -- we have a line number of the tag being searched
    -- it's 7 below the starting '---'
    -- we go up 8 because we want to 1 above when we start
    local line_no_top = entry_line_no - 8

    -- go through each line looking for the next entry start ie. '---'
    -- which signals the start of the next entry
    local next_entry_found = false 
    
    while next_entry_found == false do
        local line = vim.api.nvim_buf_get_lines(0, line_no_top, line_no_top + 1, false)
        line_no_top = line_no_top + 1

        -- look for the second new entry dashes and stop there
        if ((line[1] == '---') and (line_no_top > entry_line_no + 2)) then
            next_entry_found = true
        else
            table.insert(entry, line)
        end
    end

    return entry
end


M._output = function(entries)
    vim.api.nvim_command('tabnew')
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, 'Journal filter #' .. buf)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'lft')

    local count = 0
    for _, v in pairs(entries) do
        for _, y in pairs(v) do
            vim.api.nvim_buf_set_lines(buf, count, count, false, y)
            count = count + 1
        end
    end
end


M.get_tags = function()
    local all_tags = {}

    for k, v in pairs(M._get_whole_buffer()) do
        if (string.match(v, '- tags:') and string.len(v) > 8) then
            -- remove the '- tags: ' prefix
            local tag = string.sub(v, 9)

            -- add to the result
            -- split up multiple tags if there are any
            if (string.find(tag, ',') ~= nil) then
                for y in string.gmatch(tag, "%a+") do
                    M._add_unique(all_tags, y)
                end
            else
                M._add_unique(all_tags, tag)
            end
        end
    end

    return all_tags
end


M._get_whole_buffer = function()
    return vim.api.nvim_buf_get_lines(0, 0, -1, {})
end


M._add_unique = function(things, thing)
    if (M._is_unique(things, thing)) then
        table.insert(things, vim.trim(thing))
    end
end

M._is_unique = function(things, thing)
    for _, v in pairs(things) do
        if (v == thing) then
            return false
        end
    end

    return true
end

journal_text = M._get_whole_buffer()

return M
