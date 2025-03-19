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
        path = ./templates/default.nix;
        description = ''
          Top-level umport for static config generation.
        '';
      };
    };
    nixosModules = {
      umport = ./modules/umport/default.nix;
      home-merger = ./modules/home-merger/default.nix;
      allow-unfree = ./modules/allow-unfree/default.nix;
    };

    lib = slib;
    slib =
      {}
      // (import ./lib/home-merger {
        inherit slib;
        inherit (nixpkgs) lib;
      })
      // (import ./lib/umport {
        inherit self inputs slib;
        inherit (nixpkgs) lib;
      });

    tests =
      {}
      // import ./lib/home-merger/test.nix {
        inherit slib;
        inherit (nixpkgs) lib;
      }
      // import ./lib/umport/test.nix {
        inherit self inputs slib;
        inherit (nixpkgs) lib;
      }
      // import ./modules/umport/test.nix {
        inherit (nixpkgs) lib;
        inherit (nixosModules) umport;
        config = {
        };
      };
  };
}
