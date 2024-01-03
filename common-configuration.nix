{
  pkgs,
  username,
  homedir,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # tools
    vim
    fd
    ripgrep
    rclone
    jq
    nushell
    # programming languages
    gcc
    nodejs_20
    go
    (python3.withPackages (
      p:
        with p; [
          ipython
          requests
        ]
    ))
    # TODO: add rust
  ];

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  programs.fish.enable = true;

  users.users.${username} = {
    home = homedir;
    shell = pkgs.fish;
  };

  time.timeZone = "Asia/Novosibirsk";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';
}
