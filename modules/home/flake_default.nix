{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    myrepo = {
      url = "github:berton7/myflake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    myrepo,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        mypkgs = myrepo.packages.${system};
      in
        with pkgs; {
          devShells.default = mkShell {
            # put here your build pkgs!
            buildInputs = [];
          };
        }
    );
}
