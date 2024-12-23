{
  description = "codestats.nvim development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Create a custom neovim wrapper with development tools
        dev-environment = pkgs.symlinkJoin {
          name = "codestats-dev-environment";
          paths = with pkgs; [
            stylua
            lua-language-server
            (writeScriptBin "nvim-dev" ''
              #!${pkgs.bash}/bin/bash
              NVIM_DATA_DIR=$(mktemp -d)
              PLUGIN_DIR="$PWD"  # Use current working directory
              export NVIM_DATA_DIR PLUGIN_DIR

              echo "Loading plugin from: $PLUGIN_DIR"  # Debug print

              ${pkgs.neovim}/bin/nvim \
                -u ${pkgs.writeText "init.lua" ''
                  -- Add plenary to runtime path
                  vim.opt.rtp:prepend("${pkgs.vimPlugins.plenary-nvim}")
                  vim.opt.rtp:prepend("${pkgs.vimPlugins.nui-nvim}")

                  -- Plugin configuration
                  local config = {
                    api_key = '',
                    excluded_filetypes = { 'help', 'text', 'txt', 'log' },
                    pulse_interval = 5000,
                    username = '',
                    debug = true
                  }

                  -- Function to setup/reload the plugin
                  local function setup_plugin()
                    -- Clear module cache
                    for name, _ in pairs(package.loaded) do
                      if name:match('^codestats') then
                        package.loaded[name] = nil
                      end
                    end

                    -- Add plugin to runtime path
                    if vim.env.PLUGIN_DIR then
                      print("Loading plugin from: " .. vim.env.PLUGIN_DIR)
                      vim.opt.rtp:prepend(vim.env.PLUGIN_DIR)
                    else
                      print("Warning: PLUGIN_DIR environment variable not set")
                      return false
                    end

                    -- Load plugin
                    local ok, codestats = pcall(require, 'codestats')
                    if ok then
                      codestats.setup(config)
                      return true
                    else
                      print("Warning: Could not load codestats plugin")
                      return false
                    end
                  end

                  -- Initial plugin setup
                  setup_plugin()

                  -- Reload function
                  function reload_codestats()
                    local success = setup_plugin()
                    if success then
                      vim.notify("codestats.nvim reloaded!", vim.log.levels.INFO)
                    else
                      vim.notify("Failed to reload codestats.nvim!", vim.log.levels.ERROR)
                    end
                  end

                  -- Map the reload function
                  vim.keymap.set('n', '<leader>cr', reload_codestats, { noremap = true, silent = true, desc = "Reload codestats.nvim" })
                ''} "$@"
            '')
          ];
        };
      in
      {
        packages = {
          default = dev-environment;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ dev-environment ];
        };

        devShells.publish = pkgs.mkShell pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_23
            semantic-release
            nodePackages."@semantic-release/git"
            nodePackages."@semantic-release/github"
          ];
        };
      });
}
