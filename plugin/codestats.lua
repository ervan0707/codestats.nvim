if vim.g.loaded_codestats then
  return
end
vim.g.loaded_codestats = true

-- Create user commands
vim.api.nvim_create_user_command('CodeStatsEnable', function()
  require('codestats').enable()
end, {})

vim.api.nvim_create_user_command('CodeStatsDisable', function()
  require('codestats').disable()
end, {})

vim.api.nvim_create_user_command('CodeStatsShow', function()
  require('codestats.ui').show_stats()
end, {})


-- Create autocommand to track changes
local group = vim.api.nvim_create_augroup('CodeStatsChanges', { clear = true })

-- Track changes both in normal mode and insert mode
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = group,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    -- Increment changes counter
    vim.b[bufnr].codestats_changes = (vim.b[bufnr].codestats_changes or 0) + 1
    -- Record XP immediately
    require('codestats').record_xp()
  end,
})
