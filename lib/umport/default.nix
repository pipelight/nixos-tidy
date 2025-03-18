/*
  Fork of **Yunfachi's Umport** module.
https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix

This fork is a heavy rework of yunfachi's umport function.
Mainly, it has been splited into understandable chunks.

Features:
- integrates home_merger.
*/
{
  lib,
  # nixosModules,
  ...
}: let
  ## Filters
  /*
  A filter for nix modules files only.
   - follow this globbing pattern *.nix
   - rejects home modules *.home.*.nix
  */
  filterNixModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      # Reject home modules
      && !hasInfix "home." (builtins.toString path)
      && !hasInfix "home_" (builtins.toString path)
      && !isExcluded {
        inherit exclude;
        inherit path;
      };

  /*
  A filter for home modules files only
  - follows this globbing pattern home.*.nix
  */
  filterHomeModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      && hasInfix "home." (builtins.toString path)
      && hasInfix "home_" (builtins.toString path)
      && !isExcluded {
        inherit exclude;
        inherit path;
      };

  /*
  A filter for home modules files only
  - follows this globbing pattern test.*.nix
  */
  filterTestModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      && hasInfix "test." (builtins.toString path)
      && hasInfix "test_" (builtins.toString path)
      # Reject home modules
      && !hasInfix "home." (builtins.toString path)
      && !hasInfix "home_" (builtins.toString path)
      && !isExcluded {
        inherit exclude;
        inherit path;
      };

  /*
  Check if path is in the excluded file list.
  */
  isExcluded = {
    path,
    exclude ? [],
  } @ args:
    with lib;
    with fileset; let
      excludedFiles = filter (path: pathIsRegularFile path) exclude;
      excludedDirs = filter (path: pathIsDirectory path) exclude;
    in
      if isNull exclude
      then false
      else if elem path excludedFiles
      then true
      else (filter (excludedDir: lib.path.hasPrefix excludedDir path) excludedDirs) != [];

  /*
  Import recursively every files from paths.

  Usually you want top level import with.

  - import every path from calling site
    `paths = [./.]`
  - ignore current file to avoid infinite recursion
    `exclude = [./default.nix]`

  ```nix
  import = umportNixModules { paths = [./.] exclude = [./default.nix]}
  ````
  */
  umportNixModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (filterNixModules {
          inherit exclude;
        })
        (concatMap (path: toList path) paths)
      );

  /*
  Import recursively every files from paths.

  Ignores `default.nix` and *.nix by default
  so no need to add `exclude = [./default.nix]`

  ```nix
  import = umportHomeModules { paths = [./.]}
  ````
  */
  umportHomeModules = {
    paths ? [],
    exclude ? [],
  } @ args: users:
    with lib;
    with fileset; let
      home-merger = import ./home-merger.nix;
    in {
      nixosModules.home-merger = {
        extraSpecialArgs = {
          inherit inputs cfg pkgs-stable pkgs-unstable pkgs-deprecated;
        };
        users = cfg.users;
        modules = unique (
          filter
          (filterNixModules {
            inherit exclude;
          })
          (concatMap (path: toList path) paths)
        );
      };
    };

  /*
  Import recursively every files from paths.

  ```nix
  import = umportTestModules { paths = [./.]}
  ````
  */
  umportTestModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (filterNixModules {
          inherit exclude;
        })
        (concatMap (path: toList path) paths)
      );
in {
  inherit isExcluded;
  inherit umportNixModules;
  inherit umportHomeModules;
  inherit umportTestModules;
}
