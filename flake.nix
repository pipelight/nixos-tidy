{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lix-unit.url = "github:adisbladis/lix-unit";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: rec {
    nixosModules = {
      home-merger = ./lib/home-merger.nix;
      allow-unfree = ./lib/allow-unfree.nix;
    };
    # templates = {
    #   default = ./templates/default.nix;
    # };
    lib = {
      umport = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport;
      umport-home = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport-home;
    };

    libTests = import ./test.nix;
  };
}
