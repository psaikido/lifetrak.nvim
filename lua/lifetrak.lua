M = {}

local utils = require('utils')
local config = {}
vim.api.nvim_create_user_command("LifetrakOpen", ":lua require('lifetrak').set_journal_file()", {})
vim.api.nvim_create_user_command("LifetrakEntry", ":lua require('lifetrak').journal_entry()", {})
vim.api.nvim_create_user_command("LifetrakFilter", ":lua require('lifetrak').choose_tag()", {})


function M.init(opts)
    config = opts
end


function M._make_new_journal()
    vim.ui.input({ prompt = 'Do you want to initialise a journal? (y/n)' }, function(input)
        if (input == 'y') then
            local file = io.open(vim.fn.expand(config['journal']), 'w')
            if (file ~= nil) then
                local header = M._make_header()
                local header_text = ''

                for _, v in pairs(M._make_header()) do
                    header_text = header_text .. v .. "\n"
                end

                file:write(header_text)
                file:close()
                M._open_journal()
            else
                utils.p(file)
            end
        end
    end)
end


function M.set_journal_file()
    local journal_file_exists = vim.fn.filereadable(vim.fn.expand(config['journal']))

    if (journal_file_exists == 0) then
        M._make_new_journal()
    else
        M._open_journal()
    end
end


function M._open_journal()
    local cmd = ':e ' .. config['journal']
    vim.cmd(cmd)
end


function M.journal_entry()
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


function M._make_header()
    local header = {}

    table.insert(header, '---')

    -- create a formatted 'today'
    local today = vim.fn.strftime('%Y-%m-%d %a')
    table.insert(header, '# ' .. today)
    
    -- make an incremented journal id
    -- get the 3rd line which should have the last id
    local id_line = vim.api.nvim_buf_get_lines(0, 2, 3, false)
    local id = string.match(id_line[1], '%d+')
    if (id == nil) then id = 0 end
    local next_id = id + 1
    local header_id = '# id: ' .. next_id 
    table.insert(header, header_id)

    -- add the 'tag'
    table.insert(header, '- tags: ')

    -- add the 'meta' categories or 'tags'
    for _, v in pairs(M._get_metas()) do
        table.insert(header, v)
    end
    
    return header
end


function M._get_metas()
    local formatted_metas = {}

    for _, v in pairs(config['metas']) do
        local formatted_meta = '- ' .. v .. ': '
        table.insert(formatted_metas, formatted_meta)
    end

    return formatted_metas
end


function M.view_down()
    vim.cmd('execute "normal! /^---$\rzt:nohlsearch\r"')
end


function M.view_up()
    vim.cmd('execute "normal! ?^---$\rzt:nohlsearch\r"')
end


function M.choose_tag()
    local tags = M.get_tags()
    local tag_prompts = 'Choose a tag: ' .. vim.inspect(tags) .. ': '
    vim.ui.input({ prompt = tag_prompts }, function(input)
        M._filter_by_tag(input)
    end)
end


function M._filter_by_tag(tag)
    local chosen_tags = {}

    for k, v in pairs(M._get_whole_buffer()) do
        if (string.match(v, '- tags:') and string.match(v, tag)) then
            table.insert(chosen_tags, {k, v})
        end
    end

    local output = M._build_output(chosen_tags)
end


function M._build_output(tags)
    local entries = {}

    for k, v in pairs(tags) do
        local entry = M._get_entry(v[1])
        table.insert(entries, entry)
    end

    M._output(entries)
end


function M._get_entry(entry_line_no)
    local entry = {}
    -- we have a line number of the tag being searched
    -- it's 3 below the starting '---'
    -- we go up 4 because we want to 1 above when we start
    local line_no_top = entry_line_no - 4

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
        
        -- dont' let the loop run off the end of the buffer
        if (line_no_top == vim.api.nvim_buf_line_count(0)) then
            next_entry_found = true
        end
    end

    return entry
end


function M._output(entries)
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


function M.get_tags()
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


function M._get_whole_buffer()
    return vim.api.nvim_buf_get_lines(0, 0, -1, {})
end


function M._add_unique(things, thing)
    if (M._is_unique(things, thing)) then
        table.insert(things, vim.trim(thing))
    end
end


function M._is_unique(things, thing)
    for _, v in pairs(things) do
        if (v == thing) then
            return false
        end
    end

    return true
end

journal_text = M._get_whole_buffer()

return M
