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
    modules ? [],
    imports ? [],
  } @ homeArgs:
    with lib; {
      home-manager =
        {
          inherit useGlobalPkgs extraSpecialArgs modules;
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

  mkHydratedHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    modules ? [],
    imports ? [],
  } @ homeArgs: {
    paths ? [],
    exclude ? [],
  } @ umportArgs:
    _mkHomeModuleWrapper
    (homeArgs
      // {
        imports = umportHomeModules umportArgs;
      });
in {
  inherit mkHydratedHomeModuleWrapper;
  inherit _mkHomeModuleWrapper;
}
