local M = {}
local config = require('codestats.config')

function M.check()
  local health = vim.health or require('health')

  health.start('CodeStats')

  -- Check if API key is configured
  if config.options.api_key then
    health.ok('API key configured')
  else
    health.report_error('API key not configured')
  end

  -- Check API URL
  health.info(string.format('Using API URL: %s', config.options.api_url))

  -- Check if curl is available
  if vim.fn.executable('curl') == 1 then
    health.ok('curl is available')
  else
    health.report_error('curl is not available')
  end

  -- Check if plenary.nvim is installed
  local has_plenary = pcall(require, 'plenary')
  if has_plenary then
    health.ok('plenary.nvim is installed')
  else
    health.report_error('plenary.nvim is not installed')
  end

  -- Check if nui.nvim is installed
  local has_nui = pcall(require, 'nui.popup')
  if has_nui then
    health.ok('nui.nvim is installed')
  else
    health.report_error('nui.nvim is not installed', {
      'Install nui.nvim using your package manager:',
      'Example for packer.nvim:',
      "use { 'MunifTanjim/nui.nvim' }",
    })
  end

  -- Check Neovim version
  local nvim_version = vim.version()
  local min_version = { 0, 5, 0 }

  if nvim_version.major > min_version[1]
      or (nvim_version.major == min_version[1] and nvim_version.minor >= min_version[2]) then
    health.ok(string.format('Neovim version %d.%d.%d',
      nvim_version.major, nvim_version.minor, nvim_version.patch))
  else
    health.report_error(string.format(
      'Neovim version %d.%d.%d is too old. Minimum required: %d.%d.%d',
      nvim_version.major, nvim_version.minor, nvim_version.patch,
      min_version[1], min_version[2], min_version[3]
    ))
  end
end

return M
