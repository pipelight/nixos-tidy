{
  description = "Nix modules for home-manager utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
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
      }:
        with inputs;
        with lib; let
          # Shorter name to access final settings
          cfg = config.services.home-merger;
        in {
          # imports = [
          #   import
          #   ./default.nix
          #   {inherit config pkgs lib utils inputs;}
          # ];

          # Set the module options
          options.services.home-merger = {
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
        };
    };
  };
}
