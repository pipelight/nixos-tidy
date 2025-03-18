{
  lib,
  slib,
  ...
}: {
  /*
  Test umport with a top directory.
  */
  testMkModuleWrapper = {
    expr = slib.mkModuleWrapper {paths = [../templates];};
    expected = [
      ../templates/default.nix
      ../templates/module1/default.nix
    ];
  };
}
