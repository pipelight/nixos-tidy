{
  lib,
  slib,
  ...
}: {
  /*
  Test umport with a top directory.
  */
  testHomeMerge = {
    expr = slib.mkHome {paths = [../templates];};
    expected = [
      ../templates/default.nix
      ../templates/module1/default.nix
    ];
  };
}
