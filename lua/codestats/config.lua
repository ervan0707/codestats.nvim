local M = {}

M.defaults = {
  api_key = nil,
  api_url = 'https://codestats.net/api', -- Default API URL
  username = nil,
  enabled = true,
  debug = false,
  log_file = vim.fn.stdpath('data') .. '/codestats_debug.log',
  excluded_filetypes = {
    'help',
    'markdown',
    'text',
    'txt',
    'log',
  },
  pulse_interval = 10000, -- 10 seconds
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
  -- Ensure API URL doesn't end with a slash
  M.options.api_url = M.options.api_url:gsub('/$', '')
end

return M
