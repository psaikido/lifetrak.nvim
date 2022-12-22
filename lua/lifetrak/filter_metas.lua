local M = {}

local utils = require('lifetrak.utils')


function M.choose_meta()
    local metas = utils.get_metas()
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
    local entry = {}

    for _, v in pairs(utils.get_whole_buffer()) do
        if (string.match(v, search_string)) then
            table.insert(entry, M._get_entry())
        end
    end

    -- M._build_output(chosen_tags)
end


function M._get_entry(entry_line_no)
end


return M
