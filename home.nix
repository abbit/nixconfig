{
  lib,
  pkgs,
  username,
  config,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;

  homedir =
    (
      if isDarwin
      then "/Users/"
      else "/home/"
    )
    + username;

  shellAliases = {
    ls = "eza";
    ll = "eza -lah --group-directories-first";
    tree = "eza --tree";
    ipy = "python3 -m IPython";
  };

  terminal = {
    font.family = "JetBrainsMonoNL Nerd Font";
    font.size = 13;
    shell.command = "${pkgs.fish}/bin/fish";
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

    home.username = username;
    home.homeDirectory = homedir;

    home.packages = with pkgs;
      [
        scc
        tlrc
      ]
      ++ optionals isDarwin [
        ffmpeg
        mangal
      ];

    home.sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];

    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };

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
      };
      settings.prompt = "enabled";
      extensions = with pkgs; [
        gh-poi
      ];
    };

    programs.fish = {
      enable = true;
      shellInit = ''
        set -U fish_greeting # disable fish greeting
        set -U fish_key_bindings fish_vi_key_bindings # use vi-mode
      '';
      interactiveShellInit = optionalString isDarwin ''
        if set -q GHOSTTY_RESOURCES_DIR
          source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        end
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
      defaultEditor = true;

      withRuby = true;
      withNodeJs = true;
      withPython3 = true;

      # TODO: migrate from mason?
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
          format = "in [$symbol$state]($style)";
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

    # ==========================================
    #         Macbook-specific
    # ==========================================

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

        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
                . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
            else
                export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<
      '';
    };

    programs.alacritty = mkIf isDarwin {
      enable = true;
      settings = {
        import = ["${pkgs.catppuccin-alacritty}/catppuccin-mocha.yml"];

        font.size = terminal.font.size;
        font.normal.family = terminal.font.family;
        font.normal.style = "Regular";

        mouse.hide_when_typing = true;

        scrolling.history = 10000;
        scrolling.multiplier = 3;

        window.decorations = "full";
        window.padding.x = 0;
        window.padding.y = 0;
      };
    };

    xdg.configFile =
      {
        nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/configs/nvim";
      }
      // optionalAttrs isDarwin {
        "ghostty/config".text = ''
          theme = catppuccin-mocha

          font-size = ${builtins.toString terminal.font.size}
          font-family = ${terminal.font.family}

          macos-option-as-alt = true
          mouse-hide-while-typing = true
          quit-after-last-window-closed = true
          command = ${terminal.shell.command}
        '';
      };
  }
