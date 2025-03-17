{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lix-unit = {
      url = "github:adisbladis/lix-unit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
    rec {
      nixosModules = {
        home-merger = ./lib/home-merger.nix;
        allow-unfree = ./lib/allow-unfree.nix;
      };
      # templates = {
      #   default = ./templates/default.nix;
      # };
      lib = {
        umport = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport;
        umport-home = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport-home;
      };
      tests = import ./tests.nix;
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: let
      lib = self.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Boilerplate to run tests with lix-unit
      checks = {
        default = pkgs.runCommand "tests" {
          src = ./.;
          nativeBuildInputs =
            [
              inputs.lix-unit.packages.${system}.default
            ]
            ''
              export HOME="$(realpath .)"

              # The nix derivation must be able to find all used inputs
              # in the nix-store because it cannot download it during buildTime.

              nix-unit --eval-store "$HOME" \
                --extra-experimental-features flakes \
                --override-input nixpkgs ${nixpkgs} \
                --flake ${self}#tests
              touch $out
            '';
        };
      };
    });
}
