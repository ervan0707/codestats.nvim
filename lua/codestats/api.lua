local M = {}
local config = require('codestats.config')
local curl = require('plenary.curl')

-- Send pulse to CodeStats API
function M.send_pulse(pulse_data, callback)
  local headers = {
    ['X-API-Token'] = config.options.api_key,
    ['Content-Type'] = 'application/json',
  }

  local url = config.options.api_url .. '/my/pulses'
  local body = vim.fn.json_encode(pulse_data)

  curl.post(url, {
    headers = headers,
    body = body,
    callback = vim.schedule_wrap(function(response)
      local success = response.status >= 200 and response.status < 300
      if not success then
        print("Response Body:", response.body)
        vim.notify(
          string.format('CodeStats: Failed to send pulse (Status: %d)\nBody: %s',
            response.status,
            response.body or "No response body"
          ),
          vim.log.levels.ERROR
        )
      end
      if callback then
        callback(success)
      end
    end),
  })
end

-- Fetch user profile and stats
function M.fetch_profile_stats(callback)
  if not config.options.username then
    vim.notify('CodeStats: Username not configured', vim.log.levels.ERROR)
    callback(false, nil)
    return
  end

  local url = config.options.api_url .. '/users/' .. config.options.username

  curl.get(url, {
    callback = vim.schedule_wrap(function(response)
      if response.status >= 200 and response.status < 300 then
        local ok, data = pcall(vim.fn.json_decode, response.body)
        if ok then
          -- Format machines data
          local machines = {}
          for name, machine_data in pairs(data.machines or {}) do
            machines[name] = {
              xp = machine_data.xps or 0,
              new_xp = machine_data.new_xps or 0
            }
          end

          -- Format languages data
          local languages = {}
          for name, lang_data in pairs(data.languages or {}) do
            languages[name] = {
              xp = lang_data.xps or 0,
              new_xp = lang_data.new_xps or 0
            }
          end

          local stats = {
            username = data.user,
            total_xp = data.total_xp or 0,
            new_xp = data.new_xp or 0,
            machines = machines,
            languages = languages,
            dates = data.dates or {},
          }
          callback(true, stats)
        else
          vim.notify('Failed to parse CodeStats response', vim.log.levels.ERROR)
          callback(false, nil)
        end
      else
        vim.notify(
          string.format('Failed to fetch CodeStats data (Status: %d)\nBody: %s',
            response.status,
            response.body or "No response body"
          ),
          vim.log.levels.ERROR
        )
        callback(false, nil)
      end
    end),
  })
end

return M
