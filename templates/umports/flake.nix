{
  description = "A flake that uses nixos-tidy umports";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixos-tidy = {
      url = "github:pipelight/nixos-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###################################
    ## NixOs-tidy and dependencies
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###################################
    ## Testing purpose only
    # NUR - Nix User Repository
    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs;
  in rec {
    nixosConfigurations = {
      # Default module
      default = pkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ../commons/configuration.nix
          ../commons/hardware-configuration.nix

          ###################################
          # You may move this module into its own file.
          ({
            lib,
            inpus,
            config,
            ...
          }: let
            slib = inputs.nixos-tidy.lib;
          in {
            # Create a user.
            users.users."anon" = {
              isNormalUser = true;
            };

            imports =
              []
              # Import all nixos modules recursively
              ++ slib.umportNixModules {
                paths = [
                  inputs.nixos-tidy.nixosModules.home-merger
                  ./.
                ];
                exclude = [
                  # Do not forget to exclude current file
                  # and flake definition.
                  ./default.nix
                  ./flake.nix
                ];
              }
              # Import all home-manager modules recursively
              # Uses home-merger under the hood.
              ++ slib.umportHomeModules {
                paths = [
                  inputs.nur.modules.homeManager.default
                  ./.
                ];
                exclude = [
                  ./flake.nix
                ];
              }
              # Home-merger options
              {
                users = ["anon"];
              };
          })
          ###################################
        ];
      };
    };
    packages."${system}" = {
      default = nixosConfigurations.default.config.system.build.toplevel;
    };
  };
}
