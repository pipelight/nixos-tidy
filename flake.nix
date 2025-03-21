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
  } @ inputs: rec {
    templates = {
      default = {
        path = ./templates/umports/default.nix;
        description = ''
          Top-level umports for static config generation.
        '';
      };
    };

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

    nixosModules = {
      home-merger = ./modules/home-merger/default.nix;
      allow-unfree = ./modules/allow-unfree/default.nix;
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
