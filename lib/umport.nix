# Fork of **Yunfachi's Umport** module.
# https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix
#
# This fork integrates home_merger to load default.nix and home.nix files.
#
{lib, ...}: let
  ## The umport function
  ## Returns an list/array of uniq filepaths to import.
  umport-home = inputs @ {
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
          (file:
            pathIsRegularFile file
            && hasSuffix ".nix" (builtins.toString file)
            && hasInfix "home." (builtins.toString file)
            && !isExcluded file)
          (
            concatMap (
              _path:
                if recursive
                then toList (maybeMissing _path)
                else
                  mapAttrsToList (
                    name: type:
                      _path
                      + (
                        if type == "directory"
                        then "/${name}/home.nix"
                        else "/${name}"
                      )
                  )
                  (builtins.readDir _path)
            )
          )
        )
        ++ (
          if recursive
          then concatMap (path: toList path) (unique include)
          else unique include
        )
      );
  umport = inputs @ {
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
      # Remove duplicates
      unique (
        (
          # Filters
          filter
          (file:
            pathIsRegularFile file
            && hasSuffix ".nix" (builtins.toString file)
            && !hasInfix "home." (builtins.toString file)
            && !isExcluded file)
          (
            concatMap (
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
          )
        )
        ++ (
          if recursive
          then concatMap (path: toList path) (unique include)
          else unique include
        )
      );
  test = {
    path ? null,
    paths ? [],
    include ? [],
    exclude ? [],
    recursive ? true,
  }:
    paths;
in {
  inherit umport;
  inherit umport-home;
}
