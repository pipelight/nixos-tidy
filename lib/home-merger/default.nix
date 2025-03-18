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
  } @ homeArgs:
    with lib; {
      home-manager =
        {
          useGlobalPkgs = useGlobalPkgs;
          extraSpecialArgs = extraSpecialArgs;
        }
        // builtins.listToAttrs (
          builtins.map (u: {
            name = "users";
            value = {
              ${u} = {
                home.stateVersion = stateVersion;
                imports = imports;
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
