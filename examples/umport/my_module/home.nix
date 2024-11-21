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
    # ".config/keepassxc/keepassxc.ini".source = dotfiles/keepassxc/keepassxc.ini;
  };
}
