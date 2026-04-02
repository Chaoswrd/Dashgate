local M = {}
-- System detection
function M.get_os()
  local os_name = vim.loop.os_uname().sysname
  if os_name == "Linux" then
    -- Check for specific distributions
    local handle = io.popen(
      "lsb_release -si 2>/dev/null || cat /etc/os-release 2>/dev/null | grep '^ID=' | cut -d'=' -f2 | tr -d '\"'"
    )
    if handle then
      local result = handle:read("*a"):lower():gsub("%s+", "")
      handle:close()
      if result:find("ubuntu") then
        return "ubuntu"
      elseif result:find("arch") then
        return "arch"
      end
    end
    return "linux"
  elseif os_name == "Darwin" then
    return "macos"
  elseif os_name:find("Windows") then
    return "windows"
  else
    return "unknown"
  end
end

-- Parse uptime string into { days, hours, mins }
function M.parse_uptime(uptime_str)
  local result = { days = 0, hours = 0, mins = 0 }

  -- Strip everything from "user" or "load" onward
  local relevant = uptime_str:match("up%s+(.-)%s*%d+%s*user") or uptime_str:match("up%s+(.+)") or uptime_str

  -- Extract days
  local days = relevant:match("(%d+)%s*days?")
  if days then
    result.days = tonumber(days)
  end

  -- Extract HH:MM format (macOS/BSD style)
  local hh, mm = relevant:match("(%d+):(%d+)")
  if hh then
    result.hours = tonumber(hh)
    result.mins = tonumber(mm)
  end

  -- Extract spelled-out hours/minutes (Linux uptime -p style)
  local hours = relevant:match("(%d+)%s*hours?")
  if hours then
    result.hours = tonumber(hours)
  end
  local mins = relevant:match("(%d+)%s*min")
  if mins then
    result.mins = tonumber(mins)
  end

  return result
end

-- Get system information
function M.get_system_info()
  local info = {}
  local uname = vim.loop.os_uname()

  info.os = M.get_os()
  info.hostname = uname.nodename or "unknown"
  info.kernel = uname.release or "unknown"
  info.arch = uname.machine or "unknown"

  -- Get uptime
  local uptime_handle = io.popen("uptime -p 2>/dev/null || uptime")
  if uptime_handle then
    local uptime_str = uptime_handle:read("*a"):gsub("\n", "")
    uptime_handle:close()
    info.uptime = M.parse_uptime(uptime_str)
  else
    info.uptime = { days = 0, hours = 0, mins = 0 }
  end

  -- Get memory info (Linux/macOS)
  if info.os ~= "windows" then
    local mem_handle =
      io.popen("free -h 2>/dev/null | awk '/^Mem:/ {print $3\"/\"$2}' || vm_stat 2>/dev/null | head -4")
    if mem_handle then
      info.memory = mem_handle:read("*a"):gsub("\n", "") or "unknown"
      mem_handle:close()
    end
  end

  return info
end

return M
