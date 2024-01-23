{
  description = "Nix modules for home-manager utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
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
      }:
        with inputs;
        with lib; let
          # Shorter name to access final settings
          homeManagerModule = home-manager.nixosModules.home-manager;
          cfg = config.home-merger;
        in {
          # Set the module options
          options.home-merger = {
            users = mkOption {
              type = with types; listOf str;
              description = ''
                The name of the user for whome to add this module.
              '';
              default = ["anon"];
            };
            extraSpecialArgs = mkOption {
              # type = with types; listOf inferred;
              description = ''
                Extra args to pass to home-manager (ex: {inherit cfg input;})
              '';
              default = [];
            };
          };
          imports = [
            homeManagerModule
            {
              home-manager =
                {
                  useGlobalPkgs = false;
                  extraSpecialArgs = cfg.extraSpecialArgs;
                }
                // builtins.listToAttrs (
                  builtins.map (u: {
                    name = "users";
                    value = {
                      ${u} = {
                        home.stateVersion = "24.05";
                        imports = cfg.modules;
                      };
                    };
                  })
                  cfg.users
                );
            }
          ];
        };
    };
  };
}
