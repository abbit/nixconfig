{
  description = "Abbit's Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
      self.overlays.mypkgs
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
      ./common-configuration.nix
      hmConfig
    ];
  in {
    overlays = {
      mypkgs = final: _: (import ./packages {pkgs = final;});
      pkgs-unstable = final: _: {unstable = self.inputs.nixpkgs-unstable.legacyPackages.${final.system};};
    };

    darwinConfigurations."Abbits-MacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules =
        commonModules
        ++ [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
        ];
      inherit specialArgs;
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules =
        commonModules
        ++ [
          ./orbstack-configuration.nix
          home-manager.nixosModules.home-manager
        ];
      inherit specialArgs;
    };
  };
}
