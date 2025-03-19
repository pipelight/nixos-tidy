{
  lib,
  slib,
  ...
}:
with slib; {
  testGetPaths = {
    expr = _getPaths [../../templates];
    expected = [
      ../../templates
    ];
  };
  testGetModules = {
    expr = _getModules [../../templates];
    expected = [];
  };
  /*
  Test umport with a top directory.
  */
  testGetNixModules = {
    expr = getNixModules {
      paths = [../../templates];
    };
    expected = [
      ../../templates/default.nix
      ../../templates/module1/default.nix
    ];
  };

  /*
  Test umport with a top directory and exclude list.
  */
  testGetNixModulesExclude = {
    expr = getNixModules {
      paths = [../../templates];
      exclude = [../../templates/module1];
    };
    expected = [
      ../../templates/default.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testGetHomeModules = {
    expr = getHomeModules {
      paths = [../../templates];
    };
    expected = [
      ../../templates/module1/home.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testUmportAllModules = {
    expr =
      umportAllModules {
        paths = [../../templates];
      }
      {};
    expected = [
      ../../templates/default.nix
      ../../templates/module1/default.nix
      {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = {};
          users = {
            anon = {
              home.stateVersion = "25.05";
              imports = [
                ../../templates/module1/home.nix
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
      {paths = [../../templates];};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        users = {
          anon = {
            imports = [
              ../../templates/module1/home.nix
            ];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
}
