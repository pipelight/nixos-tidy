/*
  Fork of **Yunfachi's Umport** module.
https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix

This fork is a heavy rework of yunfachi's umport function.
Mainly, it has been splited into understandable chunks.

Features:
- integrates home_merger.
*/
{lib}: let
  ## Filters
  /*
  Remove everything that is not a path from list.
  */
  _getPaths = list:
    with lib;
      unique (
        filter isPath list
      );

  /*
  Remove everything that is a path from list.
  */
  _getModules = list:
    with lib;
      unique (
        filter _isNotPath list
      );
  _isNotPath = raw:
    with lib;
      !isPath raw;

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
  Return a list of every files from paths.

  Usually you want top level import with.

  - import every path from calling site
    `paths = [./.]`
  - ignore current file to avoid infinite recursion
    `exclude = [./default.nix]`

  ```nix
  import = getNixModules { paths = [./.] exclude = [./default.nix]}
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

  umportNixModules = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset; let
      sanitized_paths = _getPaths paths;
      modules = _getModules paths;
      full_list =
        []
        ++ getNixModules {
          inherit exclude;
          paths = sanitized_paths;
        }
        ++ modules;
    in
      full_list;

  /*
  Return a list of every home files from paths.

  Ignores `default.nix` and *.nix by default
  so no need to add `exclude = [./default.nix]`

  ```nix
  import = getHomeModules { paths = [./.]}
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

  umportHomeModules = {
    paths ? [],
    exclude ? [],
  } @ getArgs: {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs:
    with lib;
    with fileset; let
      sanitized_paths = _getPaths paths;
      modules = _getModules paths;
      full_list =
        []
        ++ (getHomeModules {
          inherit exclude;
          paths = sanitized_paths;
        })
        ++ modules;
    in
      []
      ++ [(_mkHydratedHomeModuleWrapper homeArgs full_list)];

  _mkHydratedHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs: list:
    _mkHomeModuleWrapper
    {
      inherit users stateVersion useGlobalPkgs extraSpecialArgs;
      imports =
        []
        ++ imports
        ++ list;
    };

  /*
  Make a top level module to:
    - import every home-manager modules files.
    - apply modules to user list.
  */
  _mkHomeModuleWrapper = {
    users ? ["anon"],
    stateVersion ? "25.05",
    useGlobalPkgs ? true,
    extraSpecialArgs ? {},
    imports ? [],
  } @ homeArgs: {
    home-manager =
      {
        inherit useGlobalPkgs extraSpecialArgs;
      }
      // builtins.listToAttrs (
        builtins.map (u: {
          name = "users";
          value = {
            ${u} = {
              inherit imports;
              home.stateVersion = stateVersion;
            };
          };
        })
        users
      );
  };

  /*
  Return a list of every test files from paths.

  ```nix
  import = getTestModules { paths = [./.]}
  ````
  */
  umportTestModules = getTestModules;
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
in {
  inherit _isExcluded;
  inherit _getPaths;
  inherit _getModules;

  inherit getNixModules;
  inherit getHomeModules;
  inherit getTestModules;

  inherit _mkHydratedHomeModuleWrapper;
  inherit _mkHomeModuleWrapper;

  inherit umportNixModules;
  inherit umportTestModules;

  inherit umportHomeModules;
}
