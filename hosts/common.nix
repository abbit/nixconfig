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
    ]
    ++ lib.optionals isDarwin [
      # darwin specific
      libiconv
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
