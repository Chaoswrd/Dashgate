local M = {}

-- System detection
local function get_os()
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

-- ASCII art for different operating systems
local ascii_art = {
  ubuntu = {
    "             _,met$$$$$gg.            ",
    "          ,g$$$$$$$$$$$$$$$P.         ",
    '        ,g$$P"     """Y$$."`.         ',
    "       ,$$P'              `$$$.       ",
    "      ',$$P       ,ggs.     `$$b:     ",
    "      `d$$'     ,$P\"'   .    $$$     ",
    "       $$P      d$'     ,    $$P      ",
    "       $$:      $$.   -    ,d$$'      ",
    "       $$;      Y$b._   _,d$P'        ",
    '       Y$$.    `.`"Y$$$$P"\'          ',
    '       `$$b      "-.__                ',
    "        `Y$$                          ",
    "         `Y$$.                        ",
    "           `$$b.                      ",
    "             `Y$$b.                   ",
    '                `"Y$b._               ',
    '                    `""""             ',
  },

  arch = {
    "                   -`                 ",
    "                  .o+`                ",
    "                 `ooo/                ",
    "                `+oooo:               ",
    "               `+oooooo:              ",
    "               -+oooooo+:             ",
    "             `/:-:++oooo+:            ",
    "            `/++++/+++++++:           ",
    "           `/++++++++++++++:          ",
    "          `/+++ooooooooo+++:          ",
    "         ./ooosssso++osssssso+.       ",
    "        .oossssso-````/ossssss+`      ",
    "       -osssssso.      :ssssssso.     ",
    "      :osssssss/        osssso+++.    ",
    "     /ossssssss/        +ssssooo/-    ",
    "   `/ossssso+/:-        -:/+osssso+-  ",
    "  `+sso+:-`                 `.-/+oso: ",
    " `++:.                           `-/+/",
    " .`                                 `/",
  },

  macos = {
    "                        'c.            ",
    "                     ,xNMM.            ",
    "                   .OMMMMo             ",
    "                   OMMM0,              ",
    "         .;loddo:' loolloddol;.        ",
    "       cKMMMMMMMMMMNWMMMMMMMMMM0:      ",
    "     .KMMMMMMMMMMMMMMMMMMMMMMMWd.      ",
    "     XMMMMMMMMMMMMMMMMMMMMMMMX.        ",
    "    ;MMMMMMMMMMMMMMMMMMMMMMMM:         ",
    "    :MMMMMMMMMMMMMMMMMMMMMMMM:         ",
    "    .MMMMMMMMMMMMMMMMMMMMMMMMX.        ",
    "     kMMMMMMMMMMMMMMMMMMMMMMMMWd.      ",
    "     .XMMMMMMMMMMMMMMMMMMMMMMMMMMk     ",
    "      .XMMMMMMMMMMMMMMMMMMMMMMMMK.     ",
    "        kMMMMMMMMMMMMMMMMMMMMMMd       ",
    "         ;KMMMMMMMWXXWMMMMMMMk.        ",
    "           .cooc,.    .,coo:.          ",
  },

  linux = {
    "        #####           ",
    "       #######          ",
    "       ##O#O##          ",
    "       #######          ",
    "     ###########        ",
    "    #############       ",
    "   ###############      ",
    "   ################     ",
    "  #################     ",
    " #####################  ",
    "#####################   ",
    "######################  ",
    "#######################",
    "#######################",
    " #####################  ",
    "  ###################   ",
    "   #################    ",
    "    ###############     ",
    "     #############      ",
    "      ###########       ",
    "        #######         ",
    "         #####          ",
  },

  windows = {
    "        ,.=:!!t3Z3z.,           ",
    "       :tt:::tt333EE3           ",
    "       Et:::ztt33EEEL @Ee.,     ",
    "      ;tt:::tt333EE7 ;EEEEEEt,  ",
    "     :Et:::zt333EEQ. $EEEEEEtE@",
    "     it::::tt333EEF @EEEEEEEttE.",
    '    ;3=*^```"*4EEV :EEEEEEEtttEt',
    "    ,.=::::!t=., ` @EEEEEEtttz33QF",
    '   ;::::::::zt33)   "4EEEtttji3P*',
    "  :t::::::::tt33.:Z3z.. `` ,..g. ",
    "  i::::::::zt33F AEEEtttt::::ztF ",
    " ;:::::::::t33V ;EEEttttt::::t3  ",
    " E::::::::zt33L @EEEtttt::::z3F  ",
    '{3=*^```"*4E3) ;EEEtttt:::::tZ`  ',
    "             ` :EEEEtttt::::z7   ",
    '                 "VEzjt:;;z>*`   ',
  },

  unknown = {
    "   ?????????   ",
    " ????????????? ",
    "???????????????",
    "???????????????",
    "???????????????",
    "???????????????",
    " ????????????? ",
    "   ?????????   ",
  },
}

-- Get system information
local function get_system_info()
  local info = {}
  local uname = vim.loop.os_uname()

  info.os = get_os()
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

-- Plugin state
local dashboard_buf = nil
local dashboard_win = nil

-- Create the dashboard buffer
local function create_dashboard_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_name(buf, "Dashboard")

  return buf
end

-- Render the dashboard content
local function render_dashboard(buf)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)

  -- Get system info
  local sys_info = get_system_info()
  local art = ascii_art[sys_info.os] or ascii_art.unknown

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

-- Set up dashboard keymaps
local function setup_keymaps(buf)
  local opts = { noremap = true, silent = true, buffer = buf }

  vim.keymap.set("n", "q", "<cmd>bdelete<cr>", opts)
  vim.keymap.set("n", "<ESC>", "<cmd>bdelete<cr>", opts)

  vim.keymap.set("n", "f", function()
    vim.cmd("bdelete")
    if pcall(vim.cmd, "Telescope find_files") then
      -- Telescope available
    else
      vim.cmd("edit .") -- Fallback to netrw
    end
  end, opts)

  vim.keymap.set("n", "n", function()
    vim.cmd("bdelete")
    vim.cmd("enew")
  end, opts)
end

-- Main function to show dashboard
function M.show()
  if not dashboard_buf or not vim.api.nvim_buf_is_valid(dashboard_buf) then
    dashboard_buf = create_dashboard_buffer()
  end

  vim.api.nvim_set_current_buf(dashboard_buf)
  dashboard_win = vim.api.nvim_get_current_win()

  render_dashboard(dashboard_buf)
  setup_keymaps(dashboard_buf)

  -- Set window options
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = false
  vim.wo.cursorcolumn = false
  vim.wo.foldcolumn = "0"
  vim.wo.signcolumn = "no"
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
end

return M
