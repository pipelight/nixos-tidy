{
  config,
  pkgs,
  nixpkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.allow-unfree;
in {
  options = {
    allow-unfree = mkOption {
      default = [];
      type = types.listOf types.str;
      description = "List of unfree packages allowed to be installed";
      example = lib.literalExpression ''[ "steam" ]'';
    };
  };
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: let
      pkgName = lib.getName pkg;
      matchPackges = reg: ! builtins.isNull (builtins.match reg pkgName);
    in
      builtins.any matchPackges cfg;
  };
}
