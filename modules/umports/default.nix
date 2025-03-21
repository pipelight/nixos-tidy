{
  lib,
  config,
  ...
}: let
  slib = import ../../lib/umports/default.nix {inherit lib;};
in {
  # Set the module options
  options = with lib; {
    umports = {
      paths = mkOption {
        type = with types; listOf path;
        default = [];
        example = literalExpression "[../my_module]";
        description = ''
          List of paths you want to recursively import
          modules from.
        '';
      };
      exclude = mkOption {
        type = with types; listOf path;
        default = [];
        example = literalExpression "[../my_module]";
        description = ''
          List of paths to ignore.
        '';
      };
    };
  };

  imports = with lib;
  with slib; let
    cfg = {inherit (config) umports;};
  in
    []
    ++ umportHomeModules {
      paths = _getPaths cfg.umports.paths;
      exclude = _getPaths cfg.umports.exclude;
    }
    ++ _getModules cfg.umports.paths;
}
