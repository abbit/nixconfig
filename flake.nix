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
    hostname = "Abbits-MacBook-Air";
    username = "abbit";
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [self.overlays.mypkgs];
    };
  in {
    overlays.mypkgs = final: prev: {
      gh-poi = final.callPackage ./packages/gh-poi.nix {};
      catppuccin-alacritty = final.callPackage ./packages/catppuccin-alacritty.nix {};
    };

    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        ./darwin-configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home-manager.nix;
        }
      ];
      specialArgs = {inherit inputs username;};
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.${hostname}.pkgs;

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
