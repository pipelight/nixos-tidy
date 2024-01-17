{
  config,
  pkgs,
  lib,
  input,
  cfg,
}: {
  ######################################
  #
  # As of today, nix users can not declare "home-manager.users" multiple times.
  # I haven't inspected the source code so I don't know why
  # - maybe the option is defined as unique
  # - maybe lib.mkMerge isn't possible due to internal architecture
  #
  # If you want to make *multiple* flakes that modify specific users homes through home-manager
  # And get rid of the error "option home-manager.user already declared" because
  # of multiple usages through your flakes,
  #
  # Here is a workaround with its helper functions
  #
  # 1. Do not apply changes from inside the flake!
  #    But export home modules from your flakes.
  #
  # 2. Then merge home_modules in a top flake and apply the modules
  #    to a user or user list.
  #
  ######################################

  ### USAGE
  # home_modules = mkMergeHomes [./a/home.nix ./b/home.nix ] {inherit config pkgs lib inputs cfg;} ;
  # mkApplyHomes home_modules ["username" ];

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
