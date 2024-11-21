{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    ## Password managers
    keepassxc
    gnupg
    cryptsetup
  ];

  home.file = {
    "test/umport".text = ''
      This is a random test file to check if umport-home module works.
    '';
  };
}
