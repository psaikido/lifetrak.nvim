local M = {}

local utils = require('lifetrak.utils')

function M.choose_meta()
    local metas = utils.get_metas()
    print(vim.inspect(metas))

    -- for _, v in pairs(utils.get_metas()) do
    --     table.insert(header, v)
    -- end
    -- local cache_config = lifetrak._get_disk_config()
    -- u.p(cache_config)

    -- local tags = M._get_tags()
    -- local tags_list = ''

    -- for k, v in pairs(tags) do
    --     tags_list = tags_list .. k .. ': ' .. v .. "\n"
    -- end

    -- local tag_prompts = "Choose a tag: \n" .. tags_list .. ': '
    -- vim.ui.input({ prompt = tag_prompts }, function(input)
    --     M._filter_by_tag(tags[tonumber(input)])
    -- end)
end


return M
