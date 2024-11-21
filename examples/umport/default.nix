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
  imports = let
    fn_test = {
      path ? null,
      paths ? [],
      include ? [],
      exclude ? [],
      recursive ? true,
    }:
      paths;
    fn_umport = inputs @ {
      path ? null,
      paths ? [],
      include ? [],
      exclude ? [],
      recursive ? true,
    }:
      with lib;
      with fileset; let
        excludedFiles = filter (path: pathIsRegularFile path) exclude;
        excludedDirs = filter (path: pathIsDirectory path) exclude;
        isExcluded = path:
          if elem path excludedFiles
          then true
          else (filter (excludedDir: lib.path.hasPrefix excludedDir path) excludedDirs) != [];
      in
        unique (
          (
            filter
            (file: pathIsRegularFile file && hasSuffix ".nix" (builtins.toString file) && !isExcluded file)
            (concatMap (
                _path:
                  if recursive
                  then toList _path
                  else
                    mapAttrsToList (
                      name: type:
                        _path
                        + (
                          if type == "directory"
                          then "/${name}/default.nix"
                          else "/${name}"
                        )
                    )
                    (builtins.readDir _path)
              )
              (unique (
                if path == null
                then paths
                else [path] ++ paths
              )))
          )
          ++ (
            if recursive
            then concatMap (path: toList path) (unique include)
            else unique include
          )
        );
  in
    [
      # ./configuration.nix
      # ./hardware-configuration.nix
      #
      # inputs.nixos-tidy.nixosModules.home-merger # replaces home-manager import
      # inputs.nixos-tidy.nixosModules.allow-unfree
      # inputs.nixos-tidy.nixosModules.umport
      # # Usage example
      # # This module can and should be put in a separate file
      # ({
      #   pkgs,
      #   lib,
      #   utils,
      #   ...
      # }: {
      #   # Define your users to apply home-manager config.
      #   my_config.users = ["alice" "bob"];
      #
      #   # Create users
      #   users.users.alice.isNormalUser = true;
      #   users.users.bob.isNormalUser = true;
      #
      #   # umport = {
      #   # paths = [./my_module/default.nix];
      #   # recursive = true;
      #   # };
      # })
    ]
    ++ fn_test {
      paths = [./my_module];
    };
}
