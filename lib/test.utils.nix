{
  lib,
  slib,
  ...
}: {
  testUmport = {
    expr = slib.umport {paths = [../templates];};
    expected = [
      ../templates/default.nix
      ../templates/module1/default.nix
    ];
  };

  testUmportExclude = {
    expr = slib.umport {
      paths = [../templates];
      exclude = [../templates/module1];
    };
    expected = [../templates/default.nix];
  };
}
