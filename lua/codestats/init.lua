local M = {}
local api = require('codestats.api')
local config = require('codestats.config')
local debug = require('codestats.debug')
local utils = require('codestats.utils')

-- Plugin state
local enabled = false
local pulse_timer = nil
local pending_xp = {}

-- Initialize the plugin
function M.setup(opts)
  debug.log('Starting plugin setup')
  debug.dump(opts, 'Setup options')

  config.setup(opts)

  if not config.options.api_key then
    debug.log('API key not configured - plugin initialization failed')
    vim.notify('CodeStats: API key not configured', vim.log.levels.WARN)
    return
  end

  -- Start pulse timer immediately
  M.start_pulse_timer()
  enabled = true
  debug.log('Plugin setup completed successfully')
end

-- Record XP for current buffer
function M.record_xp()
  if not enabled then
    debug.log('XP recording skipped - plugin disabled')
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if not utils.should_track_filetype(ft) then
    debug.log(string.format('Skipping XP recording for filetype: %s', ft))
    return
  end

  local xp = utils.calculate_xp()
  debug.log(string.format('Calculated XP for current buffer: %d', xp))

  if xp > 0 then
    pending_xp[ft] = (pending_xp[ft] or 0) + xp
    debug.log(string.format('Added %d XP for %s, new total: %d', xp, ft, pending_xp[ft]))
  end
end

function M.send_pulse()
  if vim.tbl_isempty(pending_xp) then
    debug.log('No pending XP to send')
    return
  end

  local pulse_data = {
    coded_at = utils.get_iso_timestamp(), -- Use coded_at instead of timestamp
    xps = {},
  }

  for lang, xp in pairs(pending_xp) do
    table.insert(pulse_data.xps, {
      language = lang,
      xp = math.floor(xp), -- Ensure XP is an integer
    })
  end
  debug.log('Preparing to send pulse')
  debug.dump(pulse_data, 'Pulse data')

  api.send_pulse(pulse_data, function(success)
    if success then
      debug.log('Pulse sent successfully')
      pending_xp = {}
    else
      debug.log('Failed to send pulse')
    end
  end)
end

-- Start the pulse timer
function M.start_pulse_timer()
  if pulse_timer then
    debug.log('Stopping existing pulse timer')
    M.stop_pulse_timer() -- Stop existing timer before creating new one
  end

  local interval = config.options.pulse_interval
  debug.log(string.format('Starting pulse timer with interval: %d ms', interval))

  pulse_timer = vim.loop.new_timer()
  pulse_timer:start(
    interval,
    interval,
    vim.schedule_wrap(function()
      debug.log('Pulse timer triggered')
      M.send_pulse()
    end)
  )
end

-- Stop the pulse timer
function M.stop_pulse_timer()
  if pulse_timer then
    debug.log('Stopping pulse timer')
    pulse_timer:stop()
    pulse_timer:close()
    pulse_timer = nil
  end
end

-- Enable tracking
function M.enable()
  enabled = true
  M.start_pulse_timer()
  debug.log('Plugin enabled')
  vim.notify('CodeStats: Enabled', vim.log.levels.INFO)
end

-- Disable tracking
function M.disable()
  enabled = false
  M.stop_pulse_timer()
  debug.log('Plugin disabled')
  vim.notify('CodeStats: Disabled', vim.log.levels.INFO)
end

return M
