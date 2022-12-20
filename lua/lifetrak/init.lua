local M = {}

local u = require('hc.utils')
local Path = require('plenary.path')
local config = {}


function M.init(opts)
    config = opts
    M._refresh()
end


function M._refresh()
    local cache_config = M._get_json_file_name()
    Path:new(cache_config):write(vim.fn.json_encode(config), "w")
end


function M.open_current()
    local disk_config = M._get_disk_config()
    local chosen_index = disk_config['default_journal_index']
    local file = disk_config['journals'][chosen_index].file
    M._open_journal(file, chosen_index)
end


function M.change_current()
    local disk_config = M._get_disk_config()
    local question = ''

    for k, v in pairs(disk_config['journals']) do
        question = question .. k .. ': ' .. v['file'] .. "\n"
    end

    vim.ui.input({ prompt = question .. "\nChoose a journal's number: " }, function(input)
        M._set_journal_file(tonumber(input), disk_config)
    end)
end

function M._get_disk_config()
    local cache_config = M._get_json_file_name()
    local disk_config = vim.json.decode(Path:new(cache_config):read())
    return disk_config
end


function M._get_json_file_name()
    local data_path = vim.fn.stdpath("data")
    return string.format('%s/lifetrak.json', data_path)
end


function M._make_new_journal(file)
    vim.ui.input({ prompt = 'Do you want to initialise a journal? (y/n)' }, function(input)
        if (input == 'y') then
            local file = io.open(vim.fn.expand(file), 'w')
            if (file ~= nil) then
                local header_text = ''

                for _, v in pairs(M._make_header()) do
                    header_text = header_text .. v .. "\n"
                end

                file:write(header_text)
                file:close()
                M._open_journal(file)
            end
        end
    end)
end


function M._set_journal_file(chosen_index, disk_config)
    local file = disk_config['journals'][chosen_index].file
    local journal_file_exists = vim.fn.filereadable(vim.fn.expand(file))

    if (journal_file_exists == 0) then
        M._make_new_journal(file)
    else
        M._open_journal(file, chosen_index)
    end
end


function M._open_journal(file, chosen_index)
    -- update current_journal in the cache_config
    config['current_journal'] = chosen_index
    M._refresh()
    vim.cmd(':e ' .. tostring(file))
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

    -- put cursor 2 lines below the headers
    local edit_line = #header + 2
    vim.api.nvim_buf_set_mark(0, 'a', edit_line, 0, {})
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

    -- add the 'meta' categories
    for _, v in pairs(M._get_metas()) do
        table.insert(header, v)
    end

    return header
end


function M._get_metas()
    local formatted_metas = {}
    local metas = {}
    local cache_config = M._get_disk_config()
    local current_journal = cache_config['current_journal']
    local default_journal_index = cache_config['default_journal_index']

    if (current_journal ~= nil) then
        metas = cache_config['journals'][current_journal].metas
    else
        metas = cache_config['journals'][default_journal_index].metas
    end

    if (metas ~= nil) then
        for _, v in pairs(metas) do
            local formatted_meta = '- ' .. v .. ': '
            table.insert(formatted_metas, formatted_meta)
        end
    end

    return formatted_metas
end


function M.view_down()
    vim.cmd('execute "normal! /^---$\rzt:nohlsearch\r"')
end


function M.view_up()
    vim.cmd('execute "normal! ?^---$\rzt:nohlsearch\r"')
end


return M
