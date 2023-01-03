local M = {}

local utils = require('lifetrak.utils')
local filter_tags = require('lifetrak.filter_tags')
local filter_metas = require('lifetrak.filter_metas')
local Path = require('plenary.path')
local config = {}


function M.init(opts)
  config = opts
  M._refresh()
  M._create_user_commands()
end


function M._refresh()
  local cache_config = utils.get_json_file_name()
  Path:new(cache_config):write(vim.fn.json_encode(config), "w")
end


function M._create_user_commands()
  vim.api.nvim_create_user_command(
    'Lifetrak',
    function()
      M.open_current()
    end,
    {nargs = 0, desc = 'Open current journal'}
  )

  -- Give the following commands if the buffer is an ".lft" filetype
  if vim.bo.filetype ~= 'lft' then
    return
  end

  vim.api.nvim_create_user_command(
    'LifetrakChangeCurrent',
    function()
      M.change_current()
    end,
    {nargs = 0, desc = 'Change current journal'}
  )

  vim.api.nvim_create_user_command(
    'LifetrakEntry',
    function()
      M.journal_entry()
    end,
    {nargs = 0, desc = 'New journal entry'}
  )

  vim.api.nvim_create_user_command(
    'LifetrakFilterTags',
    function()
      filter_tags.choose_tag()
    end,
    {nargs = 0, desc = 'Filter by tag'}
  )

  vim.api.nvim_create_user_command(
    'LifetrakFilterMetas',
    function()
      filter_metas.choose_meta()
    end,
    {nargs = 0, desc = 'Filter by tag'}
  )
end


function M.open_current()
  local disk_config = utils.get_disk_config()
  local chosen_index = disk_config['default_journal_index']
  local file = disk_config['journals'][chosen_index].file
  M._open_journal(file, chosen_index)
end


function M.change_current()
  local disk_config = utils.get_disk_config()
  local question = ''

  for k, v in pairs(disk_config['journals']) do
    question = question .. k .. ': ' .. v['file'] .. "\n"
  end

  vim.ui.input({ prompt = question .. "\nChoose a journal's number: " }, function(input)
    M._set_journal_file(tonumber(input), disk_config)
  end)
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
  for _, v in pairs(M._get_formatted_metas()) do
    table.insert(header, v)
  end

  return header
end


function M._get_formatted_metas()
  local formatted_metas = {}
  local metas = utils.get_metas()

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
