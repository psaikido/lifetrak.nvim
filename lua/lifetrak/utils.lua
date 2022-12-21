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


return M
