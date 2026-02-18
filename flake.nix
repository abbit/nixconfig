{
  description = "Abbit's Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
    overlays = [
      inputs.rust-overlay.overlays.default
      self.overlays.my-pkgs
      self.overlays.pkgs-unstable
    ];

    mkHost = name: {
      system,
      user,
      isDarwin ? false,
    }: let
      homedir =
        (
          if isDarwin
          then "/Users/"
          else "/home/"
        )
        + user;

      extraArgs = {inherit inputs isDarwin user homedir;};

      systemFunc =
        if isDarwin
        then nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
      
      systemModules =
        if isDarwin
        then [
          inputs.determinate.darwinModules.default
        ]
        else [];

      osHmModules =
        if isDarwin
        then home-manager.darwinModules
        else home-manager.nixosModules;

      commonHostConfig = ./hosts/common.nix;
      hostConfig = ./hosts/${name}.nix;
      hmConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = import ./home.nix;
        home-manager.extraSpecialArgs = extraArgs;
      };
    in
      systemFunc {
        inherit system;

        modules = 
          [
          # Enable overlays
          {nixpkgs.overlays = overlays;}
          # Allow unfree packages.
          {nixpkgs.config.allowUnfree = true;}
          # Expose some extra arguments so modules can parameterize better based on these values.
          {config._module.args = extraArgs;}
          ] ++ systemModules ++ [
          commonHostConfig
          hostConfig
          osHmModules.home-manager
          hmConfig
        ];
      };
  in {
    overlays = {
      my-pkgs = final: _: (import ./pkgs {pkgs = final;});
      pkgs-unstable = final: _: {unstable = self.inputs.nixpkgs-unstable.legacyPackages.${final.system};};
    };

    darwinConfigurations."macos" = mkHost "macos" {
      system = "aarch64-darwin";
      user = "abbit";
      isDarwin = true;
    };

    nixosConfigurations."orbstack" = mkHost "orbstack" {
      system = "aarch64-linux";
      user = "abbit";
    };
  };
}
