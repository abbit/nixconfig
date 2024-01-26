{pkgs}: {
  gh-poi = pkgs.callPackage ./gh-poi.nix {};
  catppuccin-alacritty = pkgs.callPackage ./catppuccin-alacritty.nix {};
  mangal-fork = pkgs.callPackage ./mangal-fork.nix {};
}
