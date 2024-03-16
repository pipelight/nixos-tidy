{
  config,
  lib,
  ...
}: let
  cfg = config.allow-unfree;
in {
  # Set the module options
  options = with lib; {
    allow-unfree = mkOption {
      default = [];
      type = with types; listOf str;
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
