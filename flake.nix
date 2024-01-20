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
          # imports = [
          #   import
          # ./default.nix
          #   {inherit config pkgs lib utils inputs;}
          # ];

          # Set the module options
          options.home-merger = {
            enable = mkOption {
              type = with types; bool;
              description = "Enable services";
              default = true;
            };
            users = mkOption {
              type = with types; listOf str;
              description = ''
                The name of the user for whome to add this module.
              '';
              default = ["anon"];
            };
            modules = mkOption {
              type = with types; listOf inferred;
              description = ''
                The name of the user for whome to add this module.
              '';
              default = [];
            };
          };
          config = mkMerge [
            # (mkIf
            #   cfg.enable
            #   (
            #     {}
            #     // import
            #     ./default.nix {inherit config pkgs lib utils inputs cfg;}
            #   ))
            # (mkIf
            #   cfg.enable
            #   (
            # A Function to apply home.nix home-manager
            # configurations to multiple users
            # Args:
            # - home_modules; a list of home-manager modules "home.nix" files,
            # - apply_on_users; a list of usernames
            # Return
            # - a list of modules
            # Usage:
            # ```nix
            #  imports = [] ++ mkApplyHomes [(import ./a/home.nix)] ["anon"];
            # ```
            #   homeManagerModule
            #   {
            #     home-manager =
            #       {
            #         useGlobalPkgs = false;
            #         extraSpecialArgs = {inherit system inputs;};
            #       }
            #       // builtins.listToAttrs (
            #         builtins.map (u: {
            #           name = "users";
            #           value = {
            #             ${u} = {
            #               home.stateVersion = "24.05";
            #               imports = [];
            #               # imports = cfg.modules;
            #             };
            #           };
            #         })
            #         cfg.users
            #       );
            #   }
            # ))
          ];

          imports = [
            homeManagerModule
            {
              home-manager =
                {
                  useGlobalPkgs = false;
                  extraSpecialArgs = {inherit system inputs;};
                }
                // builtins.listToAttrs (
                  builtins.map (u: {
                    name = "users";
                    value = {
                      ${u} = {
                        home.stateVersion = "24.05";
                        # imports = [];
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
