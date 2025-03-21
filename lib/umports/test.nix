{
  lib,
  slib,
  ...
}:
with slib; {
  testGetPaths = {
    expr = _getPaths [../../templates/umports];
    expected = [
      ../../templates/umports
    ];
  };
  testGetModules = {
    expr = _getModules [../../templates/umports];
    expected = [];
  };
  /*
  Test umport with a top directory.
  */
  testGetNixModules = {
    expr = getNixModules {
      paths = [../../templates/umports];
    };
    expected = [
      ../../templates/umports/flake.nix
      ../../templates/umports/my_module/default.nix
    ];
  };

  /*
  Test umport with a top directory and exclude list.
  */
  testGetNixModulesExclude = {
    expr = getNixModules {
      paths = [../../templates/umports];
      exclude = [../../templates/umports/my_module];
    };
    expected = [
      ../../templates/umports/flake.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testGetHomeModules = {
    expr = getHomeModules {
      paths = [../../templates/umports];
    };
    expected = [
      ../../templates/umports/my_module/home.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testUmportAllModules = {
    expr =
      umportAllModules {
        paths = [../../templates/umports];
      }
      {};
    expected = [
      ../../templates/umports/flake.nix
      ../../templates/umports/my_module/default.nix
      {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = {};
          users = {
            anon = {
              home.stateVersion = "25.05";
              imports = [
                ../../templates/umports/my_module/home.nix
              ];
            };
          };
        };
      }
    ];
  };
  testMkHomeModuleWrapper = {
    expr = _mkHomeModuleWrapper {};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        users = {
          anon = {
            imports = [];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
  testMkHydratedHomeModuleWrapper = {
    expr =
      _mkHydratedHomeModuleWrapper
      {}
      {paths = [../../templates/umports];};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        users = {
          anon = {
            imports = [
              ../../templates/umports/my_module/home.nix
            ];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
}
