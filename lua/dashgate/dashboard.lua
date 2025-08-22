local os = require("dashgate.os")
local ascii_art = require("dashgate.ascii-art")

local M = {}
-- Create the dashboard buffer
function M.create_dashboard_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_name(buf, "Dashboard")

  return buf
end

-- Render the dashboard content
function M.render_dashboard(buf)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)

  -- Get system info
  local sys_info = os.get_system_info()
  local art = ascii_art.ascii_art[sys_info.os] or ascii_art.unknown

  -- Create info lines
  local info_lines = {
    "",
    "╭─ System Information ─╮",
    string.format("│ OS: %s", sys_info.os:gsub("^%l", string.upper)),
    string.format("│ Host: %s", sys_info.hostname),
    string.format("│ Kernel: %s", sys_info.kernel),
    string.format("│ Arch: %s", sys_info.arch),
    string.format("│ Uptime: %s", sys_info.uptime:sub(1, 20)),
  }

  if sys_info.memory then
    table.insert(info_lines, string.format("│ Memory: %s", sys_info.memory))
  end

  table.insert(info_lines, "╰──────────────────────╯")
  table.insert(info_lines, "")
  table.insert(info_lines, "╭──────────────────────╮")
  table.insert(info_lines, "│ f - Find files       │")
  table.insert(info_lines, "│ n - New file         │")
  table.insert(info_lines, "│ q - Quit             │")
  table.insert(info_lines, "╰──────────────────────╯")

  -- Calculate layout
  local art_width = 0
  for _, line in ipairs(art) do
    art_width = math.max(art_width, #line)
  end

  local info_width = 25
  local total_width = art_width + info_width + 4 -- padding
  local start_col = math.floor((win_width - total_width) / 2)
  local start_row = math.floor((win_height - math.max(#art, #info_lines)) / 2)

  -- Build combined lines
  local lines = {}

  -- Add empty lines to center vertically
  for i = 1, math.max(0, start_row) do
    table.insert(lines, "")
  end

  -- Combine ASCII art with system info
  local max_lines = math.max(#art, #info_lines)
  for i = 1, max_lines do
    local art_line = art[i] or string.rep(" ", art_width)
    local info_line = info_lines[i] or ""

    local combined_line = string.rep(" ", math.max(0, start_col)) .. art_line .. "    " .. info_line

    table.insert(lines, combined_line)
  end

  -- Set all lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return M
