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
  slib,
  inputs,
  ...
}:
with slib; let
  ## Filters
  /*
  Check if path is in the excluded file list.
  */
  _isExcluded = {
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
  A filter for nix modules files only.
   - follow this globbing pattern *.nix
   - rejects home modules *.home.*.nix
  */
  _filterNixModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      # Reject home modules
      && !(hasInfix "home." (builtins.toString path)
        || hasInfix "home_" (builtins.toString path))
      && !_isExcluded {
        inherit exclude;
        inherit path;
      };

  /*
  A filter for home modules files only
  - follows this globbing pattern home.*.nix
  */
  _filterHomeModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      && (hasInfix "home." (builtins.toString path)
        || hasInfix "home_" (builtins.toString path))
      && !_isExcluded {
        inherit exclude;
        inherit path;
      };

  /*
  A filter for home modules files only
  - follows this globbing pattern test.*.nix
  */
  _filterTestModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      && (hasInfix "test." (builtins.toString path)
        || hasInfix "test_" (builtins.toString path))
      # Reject home modules
      && (!hasInfix "home." (builtins.toString path)
        || !hasInfix "home_" (builtins.toString path))
      && !_isExcluded {
        inherit exclude;
        inherit path;
      };

  ## Getters

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
  getNixModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (_filterNixModules {
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
  getHomeModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (_filterHomeModules {
          inherit exclude;
        })
        (concatMap (path: toList path) paths)
      );

  /*
  Import recursively every files from paths.

  ```nix
  import = umportTestModules { paths = [./.]}
  ````
  */
  getTestModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (_filterNixModules {
          inherit exclude;
        })
        (concatMap (path: toList path) paths)
      );

  getAllModules = {
    paths ? [],
    exclude ? [],
  } @ getArgs: {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs: let
    homeManagerModule = inputs.home-manager.nixosModules.home-manager;
  in
    []
    ++ getNixModules getArgs
    ++ [homeManagerModule (_mkHydratedHomeModuleWrapper homeArgs getArgs)];
in {
  inherit _isExcluded;

  inherit getNixModules;
  inherit getHomeModules;
  inherit getTestModules;

  inherit getAllModules;
}
