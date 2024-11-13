{
  description = "Abbit's Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    specialArgs = {inherit inputs username;};

    overlays = [
      inputs.rust-overlay.overlays.default
      self.overlays.my-pkgs
      self.overlays.pkgs-unstable
    ];

    hmConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ./home.nix;
      home-manager.extraSpecialArgs = specialArgs;
    };

    commonModules = [
      {nixpkgs = {inherit overlays;};} # enable overlays
      ./hosts/common.nix
      hmConfig
    ];
  in {
    overlays = {
      my-pkgs = final: _: (import ./pkgs {pkgs = final;});
      pkgs-unstable = final: _: {unstable = self.inputs.nixpkgs-unstable.legacyPackages.${final.system};};
    };

    darwinConfigurations = {
      macos = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules =
          commonModules
          ++ [
            ./hosts/macos.nix
            home-manager.darwinModules.home-manager
          ];
        inherit specialArgs;
      };
    };

    nixosConfigurations = {
      orb = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          commonModules
          ++ [
            ./hosts/orbstack.nix
            home-manager.nixosModules.home-manager
          ];
        inherit specialArgs;
      };
    };
  };
}
