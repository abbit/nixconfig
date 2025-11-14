{
  config,
  pkgs,
  user,
  homedir,
  ...
}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  programs.zsh.enable = true;

  # Needed to address bug where $PATH is not properly set for fish:
  # https://github.com/LnL7/nix-darwin/issues/122
  programs.fish.shellInit = ''
    for p in (string split : ${config.environment.systemPath})
      if not contains $p $fish_user_paths
        set -g fish_user_paths $fish_user_paths $p
      end
    end
  '';

  environment.extraInit = ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
  # For some reason if the Fish completions are added at the end of `fish_complete_path` they don't
  # seem to work, but they do work if added at the start.
  programs.fish.interactiveShellInit = ''
    if test -d (brew --prefix)"/share/fish/completions"
      set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
      set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    casks = [
      "appcleaner"
      "arc"
      "betterdisplay"
      "bitwarden"
      "blackhole-16ch"
      "calibre"
      "coteditor"
      "ghostty"
      "iina"
      "logseq"
      "orbstack"
      "raycast"
      "rectangle"
      "rescuetime"
      "sfm"
      "skim"
      "spotify"
      "stats"
      "telegram-desktop"
      "transmission"
      "visual-studio-code"
    ];
  };

  fonts.packages = [(pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})];

  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
        tilesize = 51;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXPreferredViewStyle = "Nlsv"; # Change default Finder view to List view
      };
      dock.mru-spaces = false; # Do not automatically rearrange Spaces
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # cron-like job to sync some local folders to Google Drive
  # runs every hour on minute 0
  launchd.user.agents."gdrive-sync" = {
    script = ''
      echo "[$(date "+%Y-%m-%d %H:%M:%S")] Running sync job..."
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Books gdrive:/Books
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Docs gdrive:/Docs
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Notes gdrive:/Notes
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Pictures/pics gdrive:/pics
      echo "[$(date "+%Y-%m-%d %H:%M:%S")] All things synced!"
    '';
    serviceConfig = {
      UserName = user;
      StartCalendarInterval = [{Minute = 0;}];
      StandardOutPath = "/tmp/gdrive-sync-logs.txt";
      StandardErrorPath = "/tmp/gdrive-sync-logs.txt";
    };
  };

  # We install Nix using a separate installer by Determinate Systems
  # so we don't want nix-darwin to manage it for us.
  # This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Used for backwards compatibility, read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
