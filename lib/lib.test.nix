{
  lib,
  slib,
  ...
}: {
  testPass = {
    expr = slib.umport {paths = [../templates];};
    expected = ["./templates/default.nix"];
  };

  testFail = {
    expr = {x = 1;};
    expected = {y = 1;};
  };

  testFailEval = {
    expr = throw "NO U";
    expected = 0;
  };
}
