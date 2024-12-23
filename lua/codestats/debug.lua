local config = require('codestats.config')

local M = {}

-- Format the log message
local function format_log(message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  return string.format("[%s] %s\n", timestamp, message)
end

-- Write to log file
local function write_log(message)
  local file = io.open(config.options.log_file, "a")
  if file then
    file:write(message)
    file:close()
  end
end

-- Main logging function
function M.log(message)
  if not config.options.debug then return end

  local formatted_message = format_log(message)
  write_log(formatted_message)
  print(formatted_message)
end

-- Debug utilities
function M.dump(value, description)
  if not config.options.debug then return end
  local formatted = vim.inspect(value)
  M.log(string.format("%s: %s", description or "Value dump", formatted))
end

return M
