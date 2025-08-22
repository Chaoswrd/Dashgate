local os = require("dashgate.os")
local ascii_art = require("dashgate.ascii-art")

local function formatTable(entries)
  -- Find the longest name for alignment
  local max_name_len = 0
  local max_value_len = 0
  for _, entry in ipairs(entries) do
    max_name_len = math.max(max_name_len, #entry.name)
    max_value_len = math.max(max_value_len, #entry.value)
  end

  -- Generate formatted lines
  local lines = {}
  for _, entry in ipairs(entries) do
    local padded_name = entry.name .. string.rep(" ", max_name_len - #entry.name)
    local padded_value = entry.value .. string.rep(" ", max_value_len - #entry.value)
    local padded_line = padded_name .. ": " .. padded_value

    table.insert(lines, padded_line)
  end

  return lines
end
local function generate_content_box(title, entries)
  -- Content Box Data
  local contents = formatTable(entries)
  local content_width = #contents[1]

  local lines = {}

  -- Generate Header
  local header_title = string.format(" %s ", title)

  local box_width = math.max(#header_title, content_width)

  local header_border = string.rep("─", (box_width - #header_title) / 2)

  local header = "╭─" .. header_border .. header_title .. header_border .. "─╮"

  table.insert(lines, header)

  local content_border = string.rep(" ", (box_width - content_width) / 2)

  table.insert(lines, "│ " .. string.rep(" ", box_width) .. " │")
  for _, content in ipairs(contents) do
    table.insert(lines, "│ " .. content_border .. content .. content_border .. " │")
  end
  table.insert(lines, "│ " .. string.rep(" ", box_width) .. " │")

  local footer = "╰" .. string.rep("─", content_width + 2) .. "╯"
  table.insert(lines, footer)

  return table.concat(lines, "\n")
end

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

  local system_information = {
    { name = "OS",     value = sys_info.os:gsub("^%l", string.upper) },
    { name = "Host",   value = sys_info.hostname },
    { name = "Kernel", value = sys_info.kernel },
    { name = "Arch",   value = sys_info.arch },
    { name = "Uptime", value = sys_info.uptime:sub(1, 20) },
  }

  local info_lines = generate_content_box("System Information", system_information)

  vim.notify(info_lines)

  -- Create info lines
  info_lines = {
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
