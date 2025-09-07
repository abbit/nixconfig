{
  lib,
  pkgs,
  user,
  homedir,
  isDarwin,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      # tools
      gnumake
      curl
      wget
      fd
      ripgrep
      jq
      graphviz # go tool pprof dependency
      unstable.neovim
      unstable.just
    ]
    ++ [
      # programming languages
      unstable.go_1_24
      unstable.nodejs_20
      (rust-bin.stable.latest.default.override {extensions = ["rust-src"];})
      (python3.withPackages (p: with p; [ipython requests]))
      # LSPs, linters, formatters, etc.
      alejandra
    ]
    ++ lib.optionals isDarwin [
      # darwin specific
      libiconv
    ]
    ++ lib.optionals (!isDarwin) [
      # linux specific
      gcc
    ];

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  programs.fish.enable = true;

  users.users.${user} = {
    home = homedir;
    shell = pkgs.fish;
  };

  time.timeZone = "Europe/Moscow";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';
}
