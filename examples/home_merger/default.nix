###################################
## A default file for a nixosModule/nixosConfiguration
# Here you should:
# - define the options to be used later on
# - import internal modules
{
  config,
  pkgs,
  lib,
  utils,
  inputs,
  ...
}:
with lib; {
  # Define your options
  # Define users for which to apply the home-manager configs.
  options.my_config = {
    users = mkOption {
      type = with types; listOf str;
      description = ''
        The name of the user whome to add this module for.
      '';
      default = ["anon"];
    };
  };

  # Import your modules
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix

    inputs.nixos-tidy.nixosModules.home-merger # replaces home-manager import
    inputs.nixos-tidy.nixosModules.allow-unfree
    # Usage example
    # This module can and should be put in a separate file
    ({
      pkgs,
      lib,
      utils,
      ...
    }: let
      # Define your users to apply home-manager config.
      my_config.users = ["alice" "bob"];
    in {
      # Create users
      users.users.alice.isNormalUser = true;
      users.users.bob.isNormalUser = true;

      home-merger = {
        users = my_config.users;
        modules = [
          ./my_module/home.nix
        ];
      };
    })

    # An example module
    ./my_module/default.nix
  ];
}
