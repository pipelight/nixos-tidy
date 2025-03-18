{
  lib,
  slib,
  ...
}: {
  testUmport = {
    expr = slib.umport {paths = [../templates];};
    expected = ["./templates/default.nix"];
  };
}
