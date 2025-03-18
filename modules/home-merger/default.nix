{
  config,
  lib,
  inputs,
  ...
}: let
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;
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
        types = string;
        default = config.system.stateVersion;
        description = ''
          In general you want it to be the same as your system.
        '';
        example = literalExpression "'25.05'";
      };
      useGloblalPkgs = mkEnableOption ''
        By default,
        Home Manager uses a private pkgs instance
        that is configured via the home-manager.users..nixpkgs options.

        Enable to instead use the global pkgs
        that is configured via the system level nixpkgs options
      '';
      extraSpecialArgs = mkOption {
        type = with types; attrs;
        default = {};
        example = literalExpression "{ inherit inputs; }";
        description = ''
          Extra `specialArgs` passed to Home Manager. This
          option can be used to pass additional arguments to all modules.
        '';
      };
      modules = mkOption {
        type = with types; listOf raw;
        default = [];
        example = literalExpression "[ ./home.nix, otherModule ]";
        description = ''
          Modules to add to the user configuration.
        '';
      };
    };
  };

  imports = let
    cfg = config.home-merger;
  in [
    homeManagerModule
    {
      home-manager =
        {
          useGlobalPkgs = true;
          extraSpecialArgs = cfg.extraSpecialArgs;
        }
        // builtins.listToAttrs (
          builtins.map (u: {
            name = "users";
            value = {
              ${u} = {
                home.stateVersion = "24.05";
                # home.stateVersion = config.system.stateVersion;
                imports = cfg.modules;
              };
            };
          })
          cfg.users
        );
    }
  ];
}
