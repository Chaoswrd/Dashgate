# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Dashgate is a NeoVim plugin (Lua) that renders a startup dashboard with OS-aware ASCII art and system info (hostname, kernel, uptime, memory). No build system, no dependencies, no test suite.

## Formatting

```bash
stylua lua/ plugin/
```

Configuration is in `stylua.toml`: 2-space indentation.

## Architecture

```
plugin/dashgate.lua     # NeoVim entry point: registers :Dashboard/:DashGate commands, UIEnter autocmd
lua/dashgate/
  init.lua              # plugin_state tracking, M.show(), keymaps, window option save/restore
  dashboard.lua         # buffer creation and rendering (assembles content from os.lua + ascii-art.lua)
  os.lua                # OS detection via vim.loop.os_uname() + io.popen() system calls
  ascii-art.lua         # pure data: OS name → multi-line ASCII art table
```

**Data flow:** `UIEnter` → `dashgate.show()` → `create_dashboard_buffer()` → `render_dashboard(buf)` → `get_system_info()` + ASCII art lookup → buffer write.

**State management:** `plugin_state` in `init.lua` stores the dashboard buffer ID, original buffer, and saved window options so they can be restored when the dashboard closes.

**Graceful degradation:** Falls back to netrw if Telescope is unavailable; uses `"unknown"` for any system command that fails.

## Hot Reload (Development)

```lua
local function reload_dashgate()
  for name, _ in pairs(package.loaded) do
    if name:match('^dashgate') then package.loaded[name] = nil end
  end
  require('dashgate').setup()
  vim.cmd('Dashboard')
end
vim.keymap.set('n', '<leader>dr', reload_dashgate)
```

## Dashboard Keymaps (when open)

| Key | Action |
|-----|--------|
| `f` | Find files (Telescope or netrw fallback) |
| `n` | New file |
| `q` / `<ESC>` | Close dashboard |
