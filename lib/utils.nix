{lib, ...}: let
  # Check if path is in the excluded file list.
  isExcluded = with lib;
  with fileset;
    path: exclude: let
      excludedFiles = filter (path: pathIsRegularFile path) exclude;
      excludedDirs = filter (path: pathIsDirectory path) exclude;
    in
      if elem path excludedFiles
      then true
      else (filter (excludedDir: lib.path.hasPrefix excludedDir path) excludedDirs) != [];
  # A filter for *.home.*.nix files only.
  filter_nixModules = with lib;
  with fileset;
    file: exclude:
      pathIsRegularFile file
      && hasSuffix ".nix" (builtins.toString file)
      && hasInfix "home." (builtins.toString file)
      && !isExcluded file exclude;

  # A filter for *.nix (!*.home.*.nix) files only.
  filter_homeModules = with lib;
  with fileset;
    file: exclude:
      pathIsRegularFile file
      && hasSuffix ".nix" (builtins.toString file)
      && !hasInfix "home." (builtins.toString file)
      && !isExcluded file exclude;
in {
}
