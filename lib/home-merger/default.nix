{lib, ...}: let
  /*
  Make a top level module to:
    - import every home-manager modules files.
    - apply modules to user list.
  */
  mkHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
  } @ args:
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
                # In general you want:
                # home.stateVersion = config.system.stateVersion;
                home.stateVersion = stateVersion;
                imports = cfg.modules;
              };
            };
          })
          # cfg.users
          users
        );
    };
in {
  inherit mkHomeModuleWrapper;
}
