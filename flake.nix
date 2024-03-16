{
  description = "Nixos modules utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: {
    nixosModules = {
      home-merger = ./home-merger.nix;
      allow-unfree = ./allow-unfree.nix;
    };
  };
}
