local os = require("dashgate.os")
local ascii_art = require("dashgate.ascii-art")

local M = {}

function M.format_uptime(uptime)
  local parts = {}
  if uptime.days > 0 then
    table.insert(parts, uptime.days .. "d")
  end
  if uptime.hours > 0 then
    table.insert(parts, uptime.hours .. "h")
  end
  if uptime.mins > 0 then
    table.insert(parts, uptime.mins .. "m")
  end
  if #parts == 0 then
    return "< 1m"
  end
  return table.concat(parts, " ")
end

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

  -- Helper: build a bordered box with dynamic width
  local function strwidth(s)
    return vim.api.nvim_strwidth(s)
  end

  local function make_box(title, content_lines)
    -- Find the widest content line by display width
    local max_content = strwidth(title) + 4 -- minimum: title + border dashes
    for _, line in ipairs(content_lines) do
      max_content = math.max(max_content, strwidth(line))
    end

    local box = {}
    -- Top border: ╭─ Title ─╮
    local title_dashes = max_content - strwidth(title) - 2
    local left_dashes = 1
    local right_dashes = math.max(1, title_dashes - left_dashes)
    local top = "╭" .. string.rep("─", left_dashes) .. " " .. title .. " " .. string.rep("─", right_dashes) .. "╮"
    table.insert(box, top)

    local box_display_width = strwidth(top)
    -- Content lines padded to fill the box
    for _, line in ipairs(content_lines) do
      local padding = box_display_width - strwidth(line) - 2 -- 2 for closing " │"
      table.insert(box, line .. string.rep(" ", math.max(0, padding)) .. " │")
    end

    -- Bottom border
    table.insert(box, "╰" .. string.rep("─", box_display_width - 2) .. "╯")
    return box, box_display_width
  end

  -- Build system info content (without closing border)
  local sys_content = {
    string.format("│ OS: %s", sys_info.os:gsub("^%l", string.upper)),
    string.format("│ Host: %s", sys_info.hostname),
    string.format("│ Kernel: %s", sys_info.kernel),
    string.format("│ Arch: %s", sys_info.arch),
    string.format("│ Uptime: %s", M.format_uptime(sys_info.uptime)),
  }
  if sys_info.memory then
    table.insert(sys_content, string.format("│ Memory: %s", sys_info.memory))
  end

  local sys_box, info_width = make_box("System Information", sys_content)

  -- Build shortcuts box at the same width
  local shortcut_content = {
    "│ f - Find files",
    "│ n - New file",
    "│ q - Quit",
  }
  local shortcut_box = make_box("Shortcuts", shortcut_content)

  -- Assemble info_lines
  local info_lines = { "" }
  for _, line in ipairs(sys_box) do
    table.insert(info_lines, line)
  end
  table.insert(info_lines, "")
  for _, line in ipairs(shortcut_box) do
    table.insert(info_lines, line)
  end

  -- Calculate layout
  local art_width = 0
  for _, line in ipairs(art) do
    art_width = math.max(art_width, #line)
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
