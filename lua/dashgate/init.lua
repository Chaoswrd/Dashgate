local dashboard = require("dashgate.dashboard")
local M = {}

local plugin_state = {
  -- Contains the dashboard buffer
  dashboard_buf = nil,
  -- Contains the original window
  window_buf = nil,
  -- Stores the original window options
  original_window_options = {},
}

local dashboard_window_options = {
  { option = "number",         value = false },
  { option = "relativenumber", value = false },
  { option = "cursorline",     value = false },
  { option = "cursorcolumn",   value = false },
  { option = "foldcolumn",     value = "0" },
  { option = "signcolumn",     value = "no" },
}

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

local function enable_plugin()
  -- If there's no dashboard buffer then create a new one
  if not plugin_state.dashboard_buf or not vim.api.nvim_buf_is_valid(plugin_state.dashboard_buf) then
    plugin_state.dashboard_buf = dashboard.create_dashboard_buffer()
  end

  -- Store the original window options
  -- TODO: Multiple windows make break this? I don't know...
  if not plugin_state.window_buf or not vim.api.nvim_win_is_valid(plugin_state.window_buf) then
    plugin_state.window_buf = vim.api.nvim_get_current_win()
    -- Loop over all the window options the dashboard sets, retrieve them for the current window and save them for later
    for index, window_option in ipairs(dashboard_window_options) do
      plugin_state.original_window_options[index] =
      { option = window_option.option, value = vim.api.nvim_get_option_value(window_option.option, {}) }
    end
  end
end

local function cleanup_plugin(event)
  local win_id = vim.api.nvim_get_current_win()
  -- local is_buf_visible =  winId == -1 or
  if win_id == plugin_state.window_buf then
    for _, window_option in ipairs(plugin_state.original_window_options) do
      vim.api.nvim_set_option_value(window_option.option, window_option.value, { scope = "local", win = win })
    end
    plugin_state.dashboard_buf = nil
    plugin_state.window_buf = nil
    plugin_state.saved_options = nil
  end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = cleanup_plugin,
})

-- Main function to show dashboard
function M.show()
  enable_plugin()
  vim.api.nvim_set_current_buf(plugin_state.dashboard_buf)

  dashboard.render_dashboard(plugin_state.dashboard_buf)
  setup_keymaps(plugin_state.dashboard_buf)

  -- =Set Window Options=
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
