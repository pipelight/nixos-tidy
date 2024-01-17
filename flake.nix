{
  description = "Nix modules for home-manager utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs;
  in {
    nixosModules = {
      # Default module
      default = {
        config,
        pkgs,
        lib,
        ...
      }: {
        imports = [
          ./default.nix
        ];
      };
    };
  };
}
