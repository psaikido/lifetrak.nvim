local M = {}

local utils = require('lifetrak.utils')


function M.choose_tag()
    local tags = M._get_tags()
    local tags_list = ''

    for k, v in ipairs(tags) do
        tags_list = tags_list .. k .. ': ' .. v .. "\n"
    end

    local tag_prompts = "Choose a tag: \n" .. tags_list .. ': '
    vim.ui.input({ prompt = tag_prompts }, function(input)
        M._filter_by_tag(tags[tonumber(input)])
    end)
end


function M._filter_by_tag(tag)
    local chosen_tags = {}

    for k, v in pairs(utils.get_whole_buffer()) do
        if (string.match(v, '- tags:') and string.match(v, tag)) then
            table.insert(chosen_tags, {k, v})
        end
    end

    M._build_output(chosen_tags)
end


function M._build_output(tags)
    local entries = {}

    for _, v in pairs(tags) do
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


function M._get_tags()
    local all_tags = {}

    for _, v in pairs(utils.get_whole_buffer()) do
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

    table.sort(all_tags)
    return all_tags
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

return M
