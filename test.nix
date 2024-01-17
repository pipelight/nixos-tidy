# Usage
# nix run github:nix-community/nixt -- test.nixt
{
  pkgs ? import <nixpkgs> {},
  nixt,
  ...
}: let
  inherit (pkgs) lib;
  utils = import ./default.nix {inherit lib;};
in
  nixt.mkSuite "check isEven" {
    "even number" = utils.isEven 2 == true;
    "odd number" = utils.isEven (-3) == true;
  }
