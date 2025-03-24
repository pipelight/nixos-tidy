{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    ###################################
    ## NixOs-tidy and dependencies
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-utils,
    flake-parts,
    nixpkgs,
    ...
  }: rec {
    lib = slib;
    slib =
      {}
      // (import ./lib/umports {
        inherit (nixpkgs) lib;
      })
      // (import ./lib/users {
        inherit (nixpkgs) lib;
      })
      // (import ./lib/network {
        inherit (nixpkgs) lib;
      });

    templates = {
      default = {
        path = ./templates/umports/default.nix;
        description = ''
          Top-level umports for static config generation.
        '';
      };
    };

    nixosModules = {
      home-merger = flake-parts.lib.importApply ./modules/home-merger/default.nix {inherit inputs;};
      allow-unfree = ./modules/allow-unfree/default.nix;
      networking-privacy = ./modules/networking-privacy/default.nix;
    };

    ## Unit tests
    tests =
      (import ./lib/umports/test.nix {
        inherit slib;
        inherit (nixpkgs) lib;
      })
      // (import ./lib/users/test.nix {
        inherit slib;
        inherit (nixpkgs) lib;
      })
      // (import ./lib/network/test.nix {
        inherit slib;
        inherit (nixpkgs) lib;
      });
  };
}
