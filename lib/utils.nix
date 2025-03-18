{lib, ...}: let
  ## Filters
  # A filter for nix modules files only.
  # - follow this globbing pattern *.nix
  # - rejects home modules *.home.*.nix
  filter_nixModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile path
      && hasSuffix ".nix" (builtins.toString path)
      && !hasInfix "home." (builtins.toString path)
      && !isExcluded {
        inherit exclude;
        inherit path;
      };

  # A filter for home modules files only
  # - follows this globbing pattern *.home.*.nix
  filter_homeModules = {exclude ? []} @ args: path:
    with lib;
    with fileset;
      pathIsRegularFile file
      && hasSuffix ".nix" (builtins.toString path)
      && hasInfix "home." (builtins.toString path)
      && !isExcluded {
        inherit exclude;
        inherit path;
      };
  # Check if path is in the excluded file list.
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

  umport = {
    paths ? [],
    exclude ? [],
  } @ args:
    with lib;
    with fileset;
      unique (
        filter
        (filter_nixModules {
          inherit exclude;
        })
        (concatMap (path: toList path) paths)
      );
in {
  inherit isExcluded;
  inherit umport;
}
