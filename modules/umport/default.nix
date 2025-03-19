{
  config,
  lib,
  inputs,
  ...
}: let
  # homeManagerModule = inputs.home-manager.nixosModules.home-manager;
in {
  # Set the module options
  options = with lib; {
    umport = mkOption {
      type = with types; listOf path;
      default = [];
      example = literalExpression "[../my_module]";
      description = ''
        List of paths you want to recursively import
        modules from.
      '';
    };
    umport-home = {
      users = mkOption {
        type = with types; listOf str;
        default = [];
        example = literalExpression "[../my_module]";
        description = ''
          List of paths you want to recursively import
          home modules from.
          Modules are imported into home-manager.
        '';
      };
    };
    umport-test = {
      type = with types; listOf path;
      default = [];
      example = literalExpression "[../my_module]";
      description = ''
        List of paths you want to recursively import
        unit test (nix-unit) modules from.
      '';
    };
  };
}
