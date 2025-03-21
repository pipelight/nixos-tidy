{
  lib,
  config,
  ...
}: let
  slib = import ../../lib/umport/default.nix {inherit lib;};
in {
  # Set the module options
  options = with lib; {
    umports = mkOption {
      type = with types; listOf path;
      default = [];
      example = literalExpression "[../my_module]";
      description = ''
        List of paths you want to recursively import
        modules from.
      '';
    };
  };

  imports = with lib;
  with slib; let
    cfg = {inherit (config) umports;};
  in
    []
    ++ umportHomeModules {paths = _getPaths {inherit (cfg) umports;}.umports;}
    ++ _getModules {inherit (cfg) umports;}.umports;
}
