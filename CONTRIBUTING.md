# Contributing to codestats.nvim

Thank you for your interest in contributing to codestats.nvim! This document will guide you through setting up your development environment and outline the contribution process.

## Development Setup

This project uses Nix Flakes to provide a consistent development environment. This ensures that all contributors work with the same tools and dependencies.

### Prerequisites

1. Install Nix with Flakes support:
   ```bash
   # For Linux/macOS
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Enable Flakes (if not already enabled) by adding to your `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```

### Development Environment

1. Clone the repository:
   ```bash
   git clone git@github.com:ervan0707/codestats.nvim.git
   cd codestats.nvim
   ```

2. Enter the development shell:
   ```bash
   $ nix develop
   $ nvim-dev 
   ```
   or
    ```bash
   $ nix build .
   $ ./result/bin/nvim-dev #run the wrapped nvim binary
   ```

   This will provide you with all necessary development tools:
   - Neovim
   - stylua (Lua formatter)
   - lua-language-server (LSP)

### Testing Your Changes

The development environment includes a custom Neovim wrapper (`nvim-dev`) that automatically loads the plugin from your working directory. To test your changes:

1. Run the development version of Neovim:
   ```bash
   $ nvim-dev
   ```

2. The plugin will be loaded with the following default configuration:
   ```lua
   {
     api_key = 'your token',
     excluded_filetypes = { 'help', 'text', 'txt', 'log' },
     pulse_interval = 5000,
     username = 'skinnyvans',
     debug = false
   }
   ```

3. You can reload the plugin without restarting Neovim using the keybinding:
   - `<leader>cr` - Reload codestats.nvim

## Development Workflow

1. Create a new branch for your feature/fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and format the code:
   ```bash
   stylua .
   ```

3. Test your changes using `nvim-dev`

4. Commit your changes:
   ```bash
   git commit -m "feat: add amazing feature"
   ```

5. Push your changes and create a Pull Request

## Code Style

- Follow the existing code style
- Use `stylua` for formatting Lua code
- Write clear commit messages following [Semantic Release](https://semantic-release.gitbook.io/semantic-release/#commit-message-format) conventions:
  ```
  <type>(<scope>): <description>

  [optional body]

  [optional footer(s)]
  ```

  Types:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation only changes
  - `style`: Changes that do not affect the meaning of the code
  - `refactor`: A code change that neither fixes a bug nor adds a feature
  - `perf`: A code change that improves performance
  - `test`: Adding missing tests or correcting existing tests
  - `chore`: Changes to the build process or auxiliary tools
  - `revert`: Reverts a previous commit

  Example:
  ```
  feat(xp): add experience points calculation

  Implement XP tracking for different programming languages.

  BREAKING CHANGE: New database schema required

## Dependencies

The development environment includes:
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Required for development
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) - Required for UI components

## Getting Help

If you have questions or need help, please:
1. Check existing issues
2. Create a new issue with a clear description of your problem or question

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license.

Thank you for contributing to codestats.nvim! 🎉
