{
  lib,
  slib,
  ...
}:
with slib; let
  /*
  Make a top level module to:
    - import every home-manager modules files.
    - apply modules to user list.
  */
  _mkHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs:
    with lib; {
      home-manager =
        {
          inherit useGlobalPkgs extraSpecialArgs;
        }
        // builtins.listToAttrs (
          builtins.map (u: {
            name = "users";
            value = {
              ${u} = {
                inherit imports;
                home.stateVersion = stateVersion;
              };
            };
          })
          users
        );
    };

  _mkHydratedHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs: {
    paths ? [],
    exclude ? [],
  } @ getArgs:
    with lib;
      _mkHomeModuleWrapper
      {
        inherit users stateVersion useGlobalPkgs extraSpecialArgs;
        imports =
          []
          ++ imports
          ++ getHomeModules getArgs;
      };

  umportHome = _mkHydratedHomeModuleWrapper;
in {
  inherit _mkHydratedHomeModuleWrapper;
  inherit _mkHomeModuleWrapper;
  inherit umportHome;
}
