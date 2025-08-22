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
    info.uptime = uptime_str:match("up (.+)") or uptime_str
  else
    info.uptime = "unknown"
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
