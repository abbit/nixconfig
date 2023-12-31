{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  shellAliases = {
    ls = "eza";
    ll = "eza -lah --group-directories-first";
    tree = "eza --tree";
  };
  terminal = {
    font.family = "JetBrainsMonoNL Nerd Font";
    font.size = 13;
    shell.command = "${pkgs.fish}/bin/fish";
  };
in {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  home.username = "abbit";
  home.homeDirectory = "/Users/abbit";

  home.packages = with pkgs; [
    scc
    chezmoi
    mangal
    tlrc
    ffmpeg
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.lazygit.enable = true;
  programs.eza.enable = true;

  programs.alacritty = {
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
      ".envrc"
      ".direnv/"
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
    shellInit = let
      # This naive quoting is good enough in this case. There shouldn't be any
      # double quotes in the input string, and it needs to be double quoted in case
      # it contains a space (which is unlikely!)
      dquote = str: "\"" + str + "\"";
      makeBinPathList = map (path: path + "/bin");
    in ''
      eval (/opt/homebrew/bin/brew shellenv)

      set -U fish_greeting # disable fish greeting
      set -U fish_key_bindings fish_vi_key_bindings # use vi-mode

      if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
      end

      # hack to fix $PATH entries order
      # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
      set fish_user_paths $fish_user_paths
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
  xdg.configFile.nvim.source = ./config/nvim;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      status.disabled = false;
    };
  };

  programs.zoxide = {
    enable = true;
    options = ["--cmd c"];
  };

  xdg.configFile."ghostty/config".text = ''
    theme = catppuccin-mocha

    font-size = ${builtins.toString terminal.font.size}
    font-family = ${terminal.font.family}

    macos-option-as-alt = true
    mouse-hide-while-typing = true
    quit-after-last-window-closed = true
    command = ${terminal.shell.command}
  '';

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
