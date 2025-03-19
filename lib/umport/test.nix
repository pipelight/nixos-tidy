{
  lib,
  slib,
  inputs,
  ...
}:
with slib; {
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
  testGetAllModules = {
    expr =
      getAllModules {
        paths = [../../templates];
      }
      {};
    expected = [
      ../../templates/default.nix
      ../../templates/module1/default.nix
      inputs.home-manager.nixosModules.home-manager
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
}
