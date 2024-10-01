{
  description = "Nixos config flake";

  nixConfig = {
    extra-substituters = [
      "https://berton7.cachix.org"
    ];
    extra-trusted-public-keys = [
      "berton7.cachix.org-1:l/TMwhoI++Yzzmb+ZkbB2bkjgO2X+KZ0JfJoi8NB3oA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    myrepo = {
      url = "github:berton7/myflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    myrepo,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      nixosvm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                mypkgs = myrepo.packages.${system};
              })
            ];
          }
          ./hosts/nixosvm/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.vscode-server.nixosModules.default
        ];
      };
      nixosvm-work = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                mypkgs = myrepo.packages.${system};
              })
            ];
          }
          ./hosts/nixosvm-work/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosvm-magoga = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                mypkgs = myrepo.packages.${system};
              })
            ];
          }
          ./hosts/nixosvm-magoga/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixos-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                mypkgs = myrepo.packages.${system};
              })
            ];
          }
          ./hosts/nixos-desktop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                mypkgs = myrepo.packages.${system};
              })
            ];
          }
          ./hosts/nixos-laptop/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
