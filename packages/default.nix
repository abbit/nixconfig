{pkgs}: {
  catppuccin-alacritty = pkgs.callPackage ./catppuccin-alacritty.nix {};
  mangal-fork = pkgs.callPackage ./mangal-fork.nix {};
}
