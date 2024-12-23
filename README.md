# codestats.nvim

A Neovim plugin for tracking your coding statistics with [CodeStats.net](https://codestats.net).

## Requirements

- Neovim >= 0.5.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

Using packer.nvim:
```lua
use {
    'ervan0707/codestats.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' }
}
```

## Configuration

```lua
require('codestats').setup({
    api_url = 'your_api_url', -- default: 'https://codestats.net/api'
    username = 'your_username', -- Required
    api_key = 'your_api_key', -- Required
    excluded_filetypes = { 'help', 'markdown', 'text', 'txt', 'log' },
    pulse_interval = 10000, -- milliseconds
})
```

## Commands

- `:CodeStatsEnable` - Enable tracking
- `:CodeStatsDisable` - Disable tracking
- `:CodeStatsShow` - Show your statistics

## Todo List
- [ ] Make the :CodeStatsShow popup prettier
- [ ] Add more configuration options

## License

MIT
