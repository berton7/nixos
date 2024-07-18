{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      nixosvm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixosvm/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.vscode-server.nixosModules.default
        ];
      };
      nixosvm-work = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixosvm-work/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosvm-magoga = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixosvm-magoga/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixos-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixos-desktop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixos-laptop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
