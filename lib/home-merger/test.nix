{
  lib,
  slib,
  ...
}:
with slib; {
  /*
  Test umport with a top directory.
  */
  testMkModuleWrapper = {
    expr = _mkHomeModuleWrapper {};
    expected = {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {};
        users = {
          anon = {
            home.stateVersion = "25.05";
            imports = [];
          };
        };
      };
    };
  };
}
