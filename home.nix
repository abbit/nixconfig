{
  lib,
  pkgs,
  config,
  user,
  homedir,
  isDarwin,
  ...
}: let
  shellAliases = {
    ls = "eza";
    ll = "eza -lah --group-directories-first";
    tree = "eza --tree";
    ipy = "python3 -m IPython";
  };
in
  with lib; {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.11";

    home.username = user;
    home.homeDirectory = homedir;

    home.packages = with pkgs;
      [
        fastfetch
        scc
        tlrc
        fontconfig
        coreutils-prefixed
        gnutls
      ]
      ++ optionals isDarwin [
        ffmpeg
        mangal-fork
      ];

    home.sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/bin"
    ];

    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      DIRENV_LOG_FORMAT = ""; # silence direnv logging
      RUSTFLAGS = "-L ${pkgs.libiconv}/lib"; # fix for build errors on macos
    };

    fonts.fontconfig.enable = true;

    # Let home-manager manage itself
    programs.home-manager.enable = true;

    programs.fzf.enable = true;
    programs.htop.enable = true;
    programs.lazygit.enable = true;
    programs.eza.enable = true;

    programs.bat = {
      enable = true;
      config.theme = "Catppuccin-mocha";
      themes = {
        Catppuccin-mocha = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
      userName = "Mikhail Kopylov";
      userEmail = "kopylovmichaelfl@gmail.com";
      aliases = {
        co = "commit";
        st = "status";
      };
      ignores = [
        ".DS_Store"
        ".vscode"
        ".idea"
        ".direnv"
        ".envrc"
      ];
      extraConfig = {
        color.ui = true;
        diff.colorMoved = true;
        github.user = "abbit";
        init.defaultBranch = "main";
      };
      delta.enable = true;
      delta.options = {
        navigate = true;
        syntax-theme = "Catppuccin-mocha";
      };
    };

    programs.gh = {
      enable = true;
      settings.aliases = {
        co = "pr checkout";
        clone = "repo clone";
        sync = "repo sync";
      };
      settings.prompt = "enabled";
      extensions = with pkgs; [
        unstable.gh-poi
      ];
    };

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        ${builtins.readFile ./configs/fish/config.fish}
        
        set -g SHELL ${pkgs.fish}/bin/fish
      '';

      shellAliases = shellAliases;

      plugins = [
        {
          name = "fzf.fish";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "v10.1";
            hash = "sha256-ivXa1S/HrXFzESsV0d9zIwQiuCOYNpa1tUrvA/b15yY=";
          };
        }
        {
          name = "autopair.fish";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "autopair.fish";
            rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
            sha256 = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
          };
        }
      ];
    };

    programs.neovim = {
      enable = true;
      package = pkgs.unstable.neovim-unwrapped;
      defaultEditor = true;

      withRuby = true;
      withNodeJs = true;
      withPython3 = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.starship = {
      package = pkgs.unstable.starship;
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      settings = {
        status.disabled = false;
        package.disabled = true;
        container.disabled = true;
        nix_shell = {
          format = "in [$symbol$state]($style) ";
          symbol = "❄️ nix shell";
          pure_msg = "(pure)";
          impure_msg = "";
        };
      };
    };

    programs.zoxide = {
      enable = true;
      options = ["--cmd c"];
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 10;
      keyMode = "vi";
      mouse = true;
      shortcut = "a";
      terminal = "xterm-256color";
      extraConfig = ''
        set -g default-command ${pkgs.fish}/bin/fish
        set -g default-shell ${pkgs.fish}/bin/fish

        ${builtins.readFile ./configs/tmux/tmux-light.conf}
      '';
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'violet'
            set -g @tmux_power_date_format '%d/%m/%y'
            set -g @tmux_power_time_format '%H:%M'
          '';
        }
      ];
    };

    # hack for macos
    programs.zsh = mkIf isDarwin {
      enable = true;
      shellAliases = shellAliases;

      initExtra = ''
        # Ghostty shell integration
        if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
            autoload -Uz -- "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
            ghostty-integration
            unfunction ghostty-integration
        fi
      '';
    };

    xdg.configFile =
      {
        nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/configs/nvim";
      }
      // optionalAttrs isDarwin {
        ghostty.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/configs/ghostty";
        mangal.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/configs/mangal";
      };
  }
