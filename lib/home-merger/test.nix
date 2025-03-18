{
  lib,
  slib,
  ...
}:
with slib; {
  /*
  Test umport with a top directory.
  */
  testMkHomeModuleWrapper = {
    expr = _mkHomeModuleWrapper {};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        modules = [];
        users = {
          anon = {
            imports = [];
            home.stateVersion = "25.05";
          };
        };
      };
    };
  };
}
