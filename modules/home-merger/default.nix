{
  lib,
  inputs,
  config,
  ...
}: let
  slib = import ../../lib/umport/default.nix {inherit lib;};
in {
  # Set the module options
  options = with lib; {
    home-merger = {
      users = mkOption {
        type = with types; listOf str;
        default = [];
        example = literalExpression "[\"alice\",\"bob\"]";
        description = ''
          The name of users for whome to add this module.
        '';
      };
      stateVersion = mkOption {
        type = with types; str;
        default = config.system.stateVersion;
        description = ''
          In general you want it to be the same as your system.
          stateVersion = config.system.stateVersion;
        '';
        example = literalExpression "'25.05'";
      };
      useGlobalPkgs = mkOption {
        type = with types; bool;
        default = true;
        description = ''
          By default,
          Home Manager uses a private pkgs instance
          that is configured via the home-manager.users..nixpkgs options.

          Enable to instead use the global pkgs
          that is configured via the system level nixpkgs options
        '';
        example = true;
      };
      extraSpecialArgs = mkOption {
        type = with types; attrs;
        default = {};
        example = literalExpression "{ inherit inputs; }";
        description = ''
          Extra `specialArgs` passed to Home Manager. This
          option can be used to pass additional arguments to all modules.
        '';
      };
      imports = mkOption {
        type = with types; listOf raw;
        default = [];
        example = literalExpression "[ ./home.nix, otherModule ]";
        description = ''
          Modules to add to the user configuration.
        '';
      };
      umports = mkOption {
        type = with types; listOf raw;
        default = [];
        example = literalExpression "[ ./. ]";
        description = ''
          Modules to add to the user configuration.
        '';
      };
    };
  };

  imports = with slib; let
    homeManagerModule = inputs.home-manager.nixosModules.home-manager;
    cfg = config.home-merger;
  in
    [
      homeManagerModule
    ]
    # One should not duplicate paths in umport and import.
    ++ umportHomeModules {paths = _getPaths cfg.umports;}
    # ++ umportHomeModules {paths = cfg.umports;}
    {
      inherit (cfg) users stateVersion useGlobalPkgs extraSpecialArgs;
      imports = _getModules cfg.umports ++ _getModules cfg.imports;
    };
}
