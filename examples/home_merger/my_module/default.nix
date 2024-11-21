{
  config,
  pkgs,
  lib,
  utils,
  inputs,
  ...
}: {
  environment.etc = {
    "test/umport".text = ''
      This is a random test file to check if umport module works.
    '';
  };
}
