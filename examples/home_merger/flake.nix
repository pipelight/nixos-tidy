{
  description = "A flake that uses home-merger";
  inputs = {
    # NixOs pkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    ###################################
    ## NixOs-tidy and dependencies
    nixos-tidy = {
      url = "path:/home/anon/Fast/nixos-tidy";
      # url = "github:pipelight/nixos-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###################################
    ## Optional good stuffs
    # NUR - Nix User Repository
    # nur.url = "github:nix-community/NUR";

    # Utils
    # flake-utils.url = "github:numtide/flake-utils";
    # flake-parts.url = "github:hercules-ci/flake-parts";
    # impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs;
  in rec {
    nixosConfigurations = {
      # Default module
      default = pkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./default.nix
        ];
      };
    };
    packages."${system}" = {
      default = nixosConfigurations.default.config.system.build.toplevel;
    };
  };
}
