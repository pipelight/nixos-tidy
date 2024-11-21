{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    umport = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport;
    umport-home = (import ./lib/umport.nix {inherit (nixpkgs) lib nixosModules;}).umport-home;
  };
}
