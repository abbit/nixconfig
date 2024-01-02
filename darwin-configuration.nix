{
  pkgs,
  username,
  homedir,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # tools
    fd
    ripgrep
    rclone
    jq
    nushell
    # programming languages
    nodejs_20
    go
    (python3.withPackages (
      p:
        with p; [
          ipython
          requests
        ]
    ))
  ];

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.${username}.home = homedir;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # ====================================
  #         Darwin specific
  # ====================================

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    casks = [
      "arc"
      "bitwarden"
      "blackhole-16ch"
      "iina"
      "orbstack"
      "raycast"
      "rectangle"
      "rescuetime"
      #"sioyek"
      "skim"
      "spotify"
      "stats"
      "transmission"
    ];
  };

  fonts.fontDir.enable = true;
  fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})];

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
    };
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # cron-like job to sync some local folders to Google Drive
  # runs every hour on minute 0
  launchd.user.agents."gdrive-sync" = {
    script = ''
      echo "[$(date "+%Y-%m-%d %H:%M:%S")] Running sync job..."
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Books gdrive:/Books
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Docs gdrive:/Docs
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Documents/Misc gdrive:/Misc
      ${pkgs.rclone}/bin/rclone sync --exclude ".DS_Store" ${homedir}/Pictures/pics gdrive:/pics
      echo "[$(date "+%Y-%m-%d %H:%M:%S")] All things synced!"
    '';
    serviceConfig = {
      UserName = username;
      StartCalendarInterval = [{Minute = 0;}];
      StandardOutPath = "/tmp/gdrive-sync-logs.txt";
      StandardErrorPath = "/tmp/gdrive-sync-logs.txt";
    };
  };

  # We install Nix using a separate installer by Determinate Systems
  # so we don't want nix-darwin to manage it for us.
  # This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Used for backwards compatibility, read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
