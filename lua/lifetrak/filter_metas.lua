local M = {}

local utils = require('lifetrak.utils')
local u = require('hc.utils')


function M.choose_meta()
    local metas = utils.get_metas()
    if (metas == nil) then
        print('no metas defined for this journal')
        return
    end

    local metas_list = ''

    for k, v in pairs(metas) do
        metas_list = metas_list .. k .. ': ' .. v .. "\n"
    end

    local meta_prompt = "Choose a meta: \n" .. metas_list .. ': '
    vim.ui.input({ prompt = meta_prompt }, function(input)
        local chosen_meta = input

        vim.ui.input({ prompt = "What value? " }, function(val)
            local search_val = val
            M._filter_by_meta(metas[tonumber(chosen_meta)], search_val)
        end)
    end)
end


function M._filter_by_meta(meta, val)
    local search_string = '- ' .. meta ..': ' .. val
    local entries = {}

    for k, v in pairs(utils.get_whole_buffer()) do
        if (string.match(v, search_string)) then
            table.insert(entries, M._get_entry({k, v}))
        end
    end

    utils.output(entries)
end


function M._get_entry(entries)
    local entry = {}
    local meta_line_no = entries[1]
    local line_no_entry_top = 0

    -- Search upwards for the beginning of the entry.
    local top_found = false
    local line_no_temp = meta_line_no

    while top_found == false do
        local line = vim.api.nvim_buf_get_lines(0, line_no_temp, line_no_temp + 1, false)

        if (line[1] == '---') then
            -- Add 1 to the number found as it buf_get_lines a 0 based array
            line_no_entry_top = line_no_temp + 1
            top_found = true
        end

        line_no_temp = line_no_temp - 1
    end

    -- Go to the end of the entry and return the range.
    local next_entry_found = false
    local line_no_temp = line_no_entry_top

    while next_entry_found == false do
        local line = vim.api.nvim_buf_get_lines(0, line_no_temp, line_no_temp + 1, false)
        line_no_temp = line_no_temp + 1

        -- look for the second new entry dashes and stop there
        if (line[1] == '---') then
            next_entry_found = true
        else
            table.insert(entry, line)
        end

        -- dont' let the loop run off the end of the buffer
        if (line_no_temp == vim.api.nvim_buf_line_count(0)) then
            next_entry_found = true
        end
    end

    return entry
end


return M
