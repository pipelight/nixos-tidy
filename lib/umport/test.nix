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
  testUmport = {
    expr = umportNixModules {
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
  testUmportExclude = {
    expr = umportNixModules {
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
  testUmportHome = {
    expr = umportHomeModules {
      paths = [../../templates];
    };
    expected = [
      ../../templates/module1/home.nix
    ];
  };

  /*
  Test umport home with a top directory.
  */
  testUmportAll = {
    expr =
      umportAllModules {
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
          modules = [];
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
