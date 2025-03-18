{
  lib,
  slib,
  ...
}:
with slib; {
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
            imports = [../../templates/module1/home.nix];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
}
