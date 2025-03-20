{
  lib,
  slib,
  ...
}:
with slib; {
  testGetPaths = {
    expr = _getPaths [../../templates/umport];
    expected = [
      ../../templates/umport
    ];
  };
  testGetModules = {
    expr = _getModules [../../templates/umport];
    expected = [];
  };
  /*
  Test umport with a top directory.
  */
  testGetNixModules = {
    expr = getNixModules {
      paths = [../../templates/umport];
    };
    expected = [
      ../../templates/umport/flake.nix
      ../../templates/umport/my_module/default.nix
    ];
  };

  /*
  Test umport with a top directory and exclude list.
  */
  testGetNixModulesExclude = {
    expr = getNixModules {
      paths = [../../templates/umport];
      exclude = [../../templates/umport/my_module];
    };
    expected = [
      ../../templates/umport/flake.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testGetHomeModules = {
    expr = getHomeModules {
      paths = [../../templates/umport];
    };
    expected = [
      ../../templates/umport/my_module/home.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testUmportAllModules = {
    expr =
      umportAllModules {
        paths = [../../templates/umport];
      }
      {};
    expected = [
      ../../templates/umport/flake.nix
      ../../templates/umport/my_module/default.nix
      {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = {};
          users = {
            anon = {
              home.stateVersion = "25.05";
              imports = [
                ../../templates/umport/my_module/home.nix
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
      {paths = [../../templates/umport];};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        users = {
          anon = {
            imports = [
              ../../templates/umport/my_module/home.nix
            ];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
}
