{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Testing
    lix-unit = {
      url = "github:adisbladis/lix-unit";
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
      slib = {
        umport = (import ./lib/utils.nix {inherit (nixpkgs) lib nixosModules;}).umport;
        umport-home =
          (import ./lib/umport.nix {
            inherit slib;
            inherit (nixpkgs) lib nixosModules;
          })
          .umport-home;
      };
      tests = import ./lib/test.utils.nix {
        inherit slib;
        inherit (nixpkgs) lib nixosModules;
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: let
      lib = self.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Boilerplate to run tests with lix-unit
      # !! Unstable: not workgin for now!
      # Will have to use nix-unit on command line: "nix-unit --flake '.#tests'"
      checks = {
        default =
          pkgs.runCommand "tests" {
            src = ./.;
            nativeBuildInputs = [
              inputs.lix-unit.packages.${system}.default
            ];
          }
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
    });
}
