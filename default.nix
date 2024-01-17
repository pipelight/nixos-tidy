{
  config,
  pkgs,
  lib,
  input,
  cfg,
}: {
  # A function to merge home files and apply them to a list of users
  # merge_homes [ homeManagerModule1, homeManagerModule2 ]
  mkMergeHomes = home_files: inheritage:
  # For every home-manager module paths
  # example: "home.nix"
  # import and pass args
    map
    (
      rel_path: (import rel_path inheritage)
    )
    home_files;

  # Apply home modules to user list
  mkApplyHomes = home_modules: users: [
    homeManagerModule
    {
      home-manager = [
        {
          useGlobalPkgs = true;
          extraSpecialArgs = {inherit system inputs;};
        }
        (listToAttrs (
          # For every user name
          # example "anon"
          map (u: {
            name = "users";
            value = {
              ${u} = {
                home.stateVersion = "24.05";
                imports =
                  # For every home-manager module paths
                  # example: "home.nix"
                  home_modules;
              };
            };
          })
          cfg.users
        ))
      ];
    }
  ];

  # Apply default modules and provide user list for internal usage
  mkApplyModules = default_modules: users: [
  ];
}
