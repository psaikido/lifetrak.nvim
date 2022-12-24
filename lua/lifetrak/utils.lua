local M = {}

local Path = require('plenary.path')


function M.get_metas()
    local metas = {}
    local cache_config = M.get_disk_config()
    local current_journal = cache_config['current_journal']
    local default_journal_index = cache_config['default_journal_index']
    local idx = current_journal

    if (current_journal == nil) then
        idx = default_journal_index
    end

    metas = cache_config['journals'][idx].metas

    return metas
end


function M.get_disk_config()
    local cache_config = M.get_json_file_name()
    local disk_config = vim.json.decode(Path:new(cache_config):read())
    return disk_config
end


function M.get_json_file_name()
    local data_path = vim.fn.stdpath("data")
    return string.format('%s/lifetrak.json', data_path)
end


function M.reload()
    require('plenary.reload').reload_module("lifetrak")
    vim.notify("Lifetrak modules reloaded!", vim.log.levels.INFO)
end


function M.get_whole_buffer()
    return vim.api.nvim_buf_get_lines(0, 0, -1, {})
end


function M.output(entries)
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


return M
