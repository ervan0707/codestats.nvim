# codestats.nvim

A Neovim plugin for tracking your coding statistics with [CodeStats.net](https://codestats.net).

## Requirements

- Neovim >= 0.5.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

### [Nix](https://nixos.org/)

#### For your personal configuration
```nix
# In your NixOS configuration or home-manager
(pkgs.vimUtils.buildVimPlugin {
  name = "codestats";
  src = pkgs.fetchFromGitHub {
    owner = "ervan0707";
    repo = "codestats.nvim";
    rev = "";
    hash = "";
  };
  dependencies = with pkgs.vimPlugins; [
    plenary-nvim
    nui-nvim
  ];
})

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'ervan0707/codestats.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
    },
    config = function()
        require('codestats').setup({
            -- your configuration here
        })
    end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'ervan0707/codestats.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim'
    },
    config = function()
        require('codestats').setup({
            -- your configuration here
        })
    end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'ervan0707/codestats.nvim'

" Initialize in your init.lua:
" lua require('codestats').setup({ ... })
```

### [dein](https://github.com/Shougo/dein.vim)
```vim
call dein#add('nvim-lua/plenary.nvim')
call dein#add('MunifTanjim/nui.nvim')
call dein#add('ervan0707/codestats.nvim')
```

### [Pathogen](https://github.com/tpope/vim-pathogen)
```bash
git clone https://github.com/nvim-lua/plenary.nvim.git ~/.config/nvim/bundle/plenary.nvim
git clone https://github.com/MunifTanjim/nui.nvim.git ~/.config/nvim/bundle/nui.nvim
git clone https://github.com/ervan0707/codestats.nvim.git ~/.config/nvim/bundle/codestats.nvim
```

### [Neovim's built-in package manager](https://neovim.io/doc/user/repeat.html#packages)
```bash
git clone https://github.com/nvim-lua/plenary.nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/plugins/start/plenary.nvim
git clone https://github.com/MunifTanjim/nui.nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/plugins/start/nui.nvim
git clone https://github.com/ervan0707/codestats.nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/plugins/start/codestats.nvim
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
