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
  local content_width = 0
  for _, line in ipairs(contents) do
    content_width = math.max(content_width, #line)
  end

  -- Calculate the box width needed
  local header_title = " " .. title .. " "
  local min_width_for_title = #header_title + 4 -- +4 for corner chars and some border
  local min_width_for_content = content_width + 2 -- +2 for side spaces
  local box_inner_width = math.max(min_width_for_title, min_width_for_content)

  local lines = {}

  -- Generate Header
  local title_border_length = math.max(0, math.floor((box_inner_width - #header_title) / 2))
  local remaining_border = box_inner_width - #header_title - title_border_length
  local header = "╭" .. string.rep("─", title_border_length) .. header_title .. string.rep("─", remaining_border) .. "╮"
  table.insert(lines, header)

  -- Generate content lines
  for _, content in ipairs(contents) do
    local content_padding = math.max(0, math.floor((box_inner_width - #content) / 2))
    local remaining_padding = box_inner_width - #content - content_padding
    local content_line = "│" .. string.rep(" ", content_padding) .. content .. string.rep(" ", remaining_padding) .. "│"
    table.insert(lines, content_line)
  end

  -- Generate Footer
  local footer = "╰" .. string.rep("─", box_inner_width) .. "╯"
  table.insert(lines, footer)

  return lines
end

local function generate_keybindings_box()
  local keybindings = {
    { name = "f", value = "Find files" },
    { name = "n", value = "New file" },
    { name = "q", value = "Quit" },
  }
  return generate_content_box("NeoVim Dashboard", keybindings)
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

  -- Add memory if available
  if sys_info.memory then
    table.insert(system_information, { name = "Memory", value = sys_info.memory })
  end

  -- Generate dynamic boxes
  local system_box = generate_content_box("System Information", system_information)
  local keybindings_box = generate_keybindings_box()

  -- Combine boxes with empty line separator
  local info_lines = {}
  for _, line in ipairs(system_box) do
    table.insert(info_lines, line)
  end
  table.insert(info_lines, "")
  for _, line in ipairs(keybindings_box) do
    table.insert(info_lines, line)
  end

  -- Calculate layout dynamically
  local art_width = 0
  for _, line in ipairs(art) do
    art_width = math.max(art_width, #line)
  end

  -- Calculate info width dynamically from the generated boxes
  local info_width = 0
  for _, line in ipairs(info_lines) do
    info_width = math.max(info_width, #line)
  end

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
