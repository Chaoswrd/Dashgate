# 🚀 Dashgate

A lightning-fast NeoVim dashboard plugin that greets you with neofetch-style system information and beautiful ASCII art. Built with performance in mind using pure Lua.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Lua](https://img.shields.io/badge/lua-5.1+-blue.svg)
![NeoVim](https://img.shields.io/badge/neovim-0.7+-green.svg)

## ✨ Features

- **🎨 OS-Aware ASCII Art**: Automatically detects your OS and displays the appropriate logo
- **📊 System Information**: Shows hostname, kernel, uptime, memory, and architecture
- **⚡ Lightning Fast**: Pure Lua implementation with minimal dependencies
- **🔄 Auto-Display**: Appears on startup when no files are opened
- **⌨️ Quick Navigation**: Jump to file finder or create new files instantly
- **🎯 Hot Reload**: Develop without restarting NeoVim

## 🖼️ Screenshots

### Ubuntu
```
         _,met$$$$$gg.              ╭─ System Information ─╮
      ,g$$$$$$$$$$$$$$$P.           │ OS: Ubuntu
    ,g$$P"     """Y$$.".            │ Host: dev-machine
   ,$$P'              `$$$.         │ Kernel: 5.15.0-72
  ',$$P       ,ggs.     `$$b:       │ Arch: x86_64
  `d$$'     ,$P"'   .    $$$        │ Uptime: up 2 days, 4 hours
   $$P      d$'     ,    $$P        │ Memory: 8.2G/16G
   $$:      $$.   -    ,d$$'        ╰──────────────────────╯
   $$;      Y$b._   _,d$P'
   Y$$.    `.`"Y$$$$P"'              ╭─ NeoVim Dashboard ───╮
   `$$b      "-.__                   │ f - Find files       │
    `Y$$                             │ n - New file         │
     `Y$$.                           │ q - Quit             │
       `$$b.                         ╰──────────────────────╯
         `Y$$b.
            `"Y$b._
                `""""
```

## 📦 Installation

### lazy.nvim
```lua
{
  "chaoswrd/dashgate",
  event = "VimEnter",
  config = function()
    require('dashgate').setup()
  end,
}
```

### packer.nvim
```lua
use {
  "chaoswrd/dashgate",
  config = function()
    require('dashgate').setup()
  end
}
```

### Manual Installation
```bash
# Clone to your NeoVim config
git clone https://github.com/chaoswrd/dashgate.git ~/.config/nvim/lua/dashgate

# Or for development
git clone https://github.com/chaoswrd/dashgate.git ~/dev/dashgate
```

## 🛠️ Configuration

### Basic Setup
```lua
require('dashgate').setup()
```

### Development Setup (Hot Reload)
Add this to your NeoVim config for instant reloading during development:

```lua
require('dashgate').setup()

-- Hot reload function for development
local function reload_dashgate()
  for name, _ in pairs(package.loaded) do
    if name:match('^dashgate') then
      package.loaded[name] = nil
    end
  end
  
  require('dashgate').setup()
  vim.cmd('Dashboard')
end

vim.keymap.set('n', '<leader>dr', reload_dashgate, { desc = 'Reload Dashgate' })
```

## 🎮 Usage

### Commands
- `:Dashboard` - Open the dashboard manually

### Keybindings (within dashboard)
- `f` - Open file finder (Telescope if available, otherwise netrw)
- `n` - Create new file
- `q` or `<ESC>` - Close dashboard

### Auto-Start
Dashgate automatically appears when you start NeoVim without opening any files.

## 🖥️ Supported Operating Systems

Dashgate automatically detects and displays appropriate ASCII art for:

- **🐧 Linux Distributions**
  - Ubuntu (classic swirl logo)
  - Arch Linux (mountain design)
  - Generic Linux (Tux-inspired)
- **🍎 macOS** (Apple logo)
- **🪟 Windows** (Windows flag design)

## ⚡ Performance

Dashgate is built for speed:
- **Pure Lua**: No external dependencies
- **Lazy Loading**: System info gathered only when needed
- **Minimal Buffer Operations**: Efficient rendering
- **Smart Caching**: Avoids redundant system calls

## 🔧 Development

### Project Structure
```
dashgate/
├── lua/
│   └── dashgate/
│       └── init.lua          # Main plugin file
├── README.md
└── LICENSE
```

### Contributing
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test with the hot reload setup
5. Submit a pull request

### Adding New OS Support
To add support for a new operating system:

1. Add detection logic in `get_os()` function
2. Add ASCII art in the `ascii_art` table
3. Test the detection and rendering

## 🐛 Troubleshooting

### Dashboard doesn't appear on startup
Make sure you have the VimEnter autocmd enabled and you're starting NeoVim without file arguments.

### System information shows "unknown"
Some system commands might not be available. Dashgate gracefully handles missing commands and shows "unknown" for unavailable information.

### ASCII art looks broken
Ensure your terminal supports Unicode characters and has a monospace font installed.

## 📋 Requirements

- NeoVim 0.7+
- Lua 5.1+
- Terminal with Unicode support (recommended)

## 🤝 Optional Dependencies

- **Telescope.nvim**: For enhanced file finding (falls back to netrw)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [neofetch](https://github.com/dylanaraps/neofetch) for system information display
- ASCII art adapted from various open-source neofetch themes
- Created in collaboration with [Claude Sonnet 4](https://claude.ai) by Anthropic
- Thanks to the NeoVim community for the amazing plugin ecosystem

## 🔗 Links

- [Report Issues](https://github.com/chaoswrd/dashgate/issues)
- [Feature Requests](https://github.com/chaoswrd/dashgate/discussions)
- [NeoVim Documentation](https://neovim.io/doc/)

---

<div align="center">

**Made with ❤️ for the NeoVim community**

[⭐ Star this repo](https://github.com/chaoswrd/dashgate) • [🐛 Report Bug](https://github.com/chaoswrd/dashgate/issues) • [💡 Request Feature](https://github.com/chaoswrd/dashgate/discussions)

</div>
