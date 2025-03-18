{
  lib,
  slib,
  ...
}: {
  /*
  Test umport with a top directory.
  */
  testUmport = {
    expr = slib.umportNixModules {paths = [../templates];};
    expected = [
      ../templates/default.nix
      ../templates/module1/default.nix
    ];
  };

  /*
  Test umport with a top directory and exclude list.
  */
  testUmportExclude = {
    expr = slib.umportNixModules {
      paths = [../templates];
      exclude = [../templates/module1];
    };
    expected = [../templates/default.nix];
  };
  /*
  Test umport home with a top directory.
  */
  testUmportHome = {
    expr =
      slib.umportHomeModules
      {
        paths = [../templates];
      }
      # Username list to apply homeModules to.
      ["anon"];
    expected = [
      ../templates/module1/home.nix
    ];
  };
}
