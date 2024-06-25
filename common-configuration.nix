{
  lib,
  pkgs,
  username,
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
in {
  environment.systemPackages = with pkgs;
    [
      # tools
      gnumake
      curl
      wget
      neovim
      fd
      ripgrep
      jq
      nushell
      # programming languages
      unstable.go_1_22
      unstable.nodejs_20
      (rust-bin.stable.latest.default.override {
        extensions = ["rust-src"];
      })
      (python3.withPackages (
        p:
          with p; [
            ipython
            requests
          ]
      ))
      # LSPs, linters, formatters, etc.
      alejandra
    ]
    ++ lib.optionals (!isDarwin) [
      gcc
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
