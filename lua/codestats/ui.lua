local Popup = require('nui.popup')
local NuiTable = require('nui.table')
local event = require('nui.utils.autocmd').event

local M = {}
local api = require('codestats.api')

-- Helper functions
local function format_xp(xp)
  return string.format("%d", xp)
end

local function format_date_xp(dates)
  local sorted_dates = {}
  for date, xp in pairs(dates) do
    table.insert(sorted_dates, { date = date, xp = xp })
  end
  table.sort(sorted_dates, function(a, b) return a.date > b.date end)
  return sorted_dates
end

-- Center align text in width
local function center_align(text, width)
  local padding = width - #text
  if padding <= 0 then return text end
  local left_pad = math.floor(padding / 2)
  local right_pad = padding - left_pad
  return string.rep(" ", left_pad) .. text .. string.rep(" ", right_pad)
end

local function create_loading_popup()
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Loading CodeStats Data ",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = 60,
      height = 6,
    },
  })

  popup:mount()

  vim.schedule(function()
    local lines = {
      "",
      "  Loading your CodeStats data...",
      "  Please wait...",
      "",
    }
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  end)

  return popup
end

local function create_stats_popup(stats)
  local width = 70
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " CodeStats - " .. stats.username .. " ",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = width + 4,
      height = "80%",
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  popup:mount()

  -- Close handlers
  for _, key in ipairs({ 'q', '<Esc>', '<C-c>' }) do
    popup:map('n', key, function() popup:unmount() end, { noremap = true })
  end

  local function append_lines(lines)
    local line_count = vim.api.nvim_buf_line_count(popup.bufnr)
    vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(popup.bufnr, line_count, line_count, false, lines)
    vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)
  end

  -- Set buffer as modifiable initially
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', true)

  -- Overall Stats
  append_lines({
    "Overall Statistics",
    string.format("Total XP: %s", format_xp(stats.total_xp)),
    string.format("New XP: %s", format_xp(stats.new_xp)),
    "",
    "Languages",
    "",
  })

  -- Languages Table
  local sorted_languages = {}
  for lang, data in pairs(stats.languages) do
    table.insert(sorted_languages, {
      name = lang,
      xp = data.xp,
      new_xp = data.new_xp
    })
  end
  table.sort(sorted_languages, function(a, b) return a.xp > b.xp end)

  local languages_table = NuiTable({
    bufnr = popup.bufnr,
    columns = {
      {
        header = "Language",
        accessor_key = "name",
        align = "left",
        padding = { left = 2, right = 2 },
      },
      {
        header = "Total XP",
        accessor_key = "total_xp",
        align = "right",
        padding = { left = 2, right = 2 },
      },
      {
        header = "New XP",
        accessor_key = "new_xp",
        align = "right",
        padding = { left = 2, right = 2 },
      },
    },
    data = vim.tbl_map(function(lang)
      return {
        name = lang.name,
        total_xp = format_xp(lang.xp),
        new_xp = format_xp(lang.new_xp),
      }
    end, sorted_languages),
  })

  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', true)
  languages_table:render()
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)

  -- Add spacing for machines section
  append_lines({ "", "Machines", "" })

  -- Machines Table
  local sorted_machines = {}
  for machine, data in pairs(stats.machines) do
    table.insert(sorted_machines, {
      name = machine,
      xp = data.xp,
      new_xp = data.new_xp
    })
  end
  table.sort(sorted_machines, function(a, b) return a.xp > b.xp end)

  local machines_table = NuiTable({
    bufnr = popup.bufnr,
    columns = {
      {
        header = "Machine",
        accessor_key = "name",
        align = "left",
        padding = { left = 2, right = 2 },
      },
      {
        header = "Total XP",
        accessor_key = "total_xp",
        align = "right",
        padding = { left = 2, right = 2 },
      },
      {
        header = "New XP",
        accessor_key = "new_xp",
        align = "right",
        padding = { left = 2, right = 2 },
      },
    },
    data = vim.tbl_map(function(machine)
      return {
        name = machine.name,
        total_xp = format_xp(machine.xp),
        new_xp = format_xp(machine.new_xp),
      }
    end, sorted_machines),
  })

  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', true)
  machines_table:render()
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)

  -- Add spacing for recent activity section
  append_lines({ "", "Recent Activity", "" })

  -- Recent Activity Table
  local recent_dates = format_date_xp(stats.dates)
  local dates_table = NuiTable({
    bufnr = popup.bufnr,
    columns = {
      {
        header = "Date",
        accessor_key = "date",
        align = "left",
        padding = { left = 2, right = 2 },
      },
      {
        header = "XP",
        accessor_key = "xp",
        align = "right",
        padding = { left = 2, right = 2 },
      },
    },
    data = vim.tbl_map(function(date_data)
      return {
        date = date_data.date,
        xp = format_xp(date_data.xp),
      }
    end, { unpack(recent_dates, 1, 5) }),     -- Show only last 5 days
  })

  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', true)
  dates_table:render()
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)

  -- Add closing message
  append_lines({ "", "Press q, <Esc> or <C-c> to close" })

  -- Set final buffer options
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(popup.bufnr, 'readonly', true)
end

function M.show_stats()
  local loading_popup = create_loading_popup()

  api.fetch_profile_stats(function(success, stats)
    loading_popup:unmount()
    if success then
      create_stats_popup(stats)
    end
  end)
end

return M
