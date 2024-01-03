{
  description = "Abbit's darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: let
    username = "abbit";
    homedir = "/Users/${username}";

    specialArgs = {inherit inputs username homedir;};

    hmConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home-manager.nix;
      home-manager.extraSpecialArgs = specialArgs;
    };
  in {
    overlays.mypkgs = final: prev: {
      gh-poi = final.callPackage ./packages/gh-poi.nix {};
      catppuccin-alacritty = final.callPackage ./packages/catppuccin-alacritty.nix {};
    };

    darwinConfigurations."Abbits-MacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({pkgs, ...}: {nixpkgs.overlays = [self.overlays.mypkgs];})
        ./common-configuration.nix
        ./darwin-configuration.nix
        home-manager.darwinModules.home-manager
        hmConfig
      ];
      specialArgs = specialArgs;
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ({pkgs, ...}: {nixpkgs.overlays = [self.overlays.mypkgs];})
        ./common-configuration.nix
        ./orbstack-configuration.nix
        home-manager.nixosModules.home-manager
        hmConfig
      ];
      specialArgs = specialArgs;
    };

    formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
    formatter."aarch64-linux" = nixpkgs.legacyPackages."aarch64-linux".alejandra;
  };
}
