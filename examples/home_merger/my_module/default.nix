{
  config,
  pkgs,
  lib,
  utils,
  inputs,
  ...
}: {
  # Import home files
  home-merger = {
    enable = true;
    users = config.my_config.users;
    modules = [
      ./home.nix
    ];
  };
  allow-unfree = [
    # AI
    "lib.*"
    "cuda.*"
    # Nvidia
    "nvidia.*"
  ];
}
