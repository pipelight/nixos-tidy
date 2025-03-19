{
  lib,
  config,
  ...
}: let
  slib = import ../../lib/umport/default.nix {inherit lib;};
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
          List of paths you want to exclude from
          importing.
        '';
      };
    };
  };

  imports = with lib;
  with slib; let
    cfgUmport = config.umport;
  in
    if (cfgUmport.paths != [])
    then umportNixModules {inherit (cfgUmport) paths;}
    else umportNixModules {paths = [];};
}
