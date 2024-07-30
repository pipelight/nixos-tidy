{
  description = "A tidy flake template";

  inputs = {
    # NixOs pkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    ###################################
    ## NixOs-tidy and dependencies
    nixos-tidy = {
      url = "github:pipelight/nixos-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###################################
    ## Optional good stuffs
    # NUR - Nix User Repository
    # nur.url = "github:nix-community/NUR";

    # Utils
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      flake = {
        nixosConfigurations = {
          # Default module
          default = nixpkgs.lib.nixosSystem {
            modules = [
              (
                {
                  # config,
                  pkgs,
                  lib,
                  utils,
                  inputs,
                  ...
                }:
                  with lib; {
                    # Define a user for which to apply the home-manager configs.
                    options.my_config = {
                      users = mkOption {
                        type = with types; listOf str;
                        description = ''
                          The name of the user whome to add this module for.
                        '';
                        default = ["anon"];
                      };
                    };
                    imports = [
                      ./configuration.nix
                      # inputs.nixos-tidy.nixosModules.home-merger # replaces home-manager import
                      # inputs.nixos-tidy.nixosModules.allow-unfree
                    ];
                  }
              )
            ];
          };
        };
      };
      systems =
        flake-utils.lib.allSystems;
    };
}
