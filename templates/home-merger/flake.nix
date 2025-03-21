{
  description = "A flake that uses nixos-tidy home-merger";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixos-tidy = {
      url = "github:pipelight/nixos-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###################################
    ## NixOs-tidy and dependencies
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###################################
    ## Testing
    # NUR - Nix User Repository
    nur.url = "github:nix-community/NUR";
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
          ../commons/configuration.nix
          ../commons/hardware-configuration.nix

          inputs.nixos-tidy.nixosModules.home-merger
          inputs.nixos-tidy.nixosModules.allow-unfree

          ###################################
          # Top level home-merger

          # No need to import home-manager anymore
          # -- inputs.home-manager.nixosModules.home-manager

          ({
            lib,
            inpus,
            config,
            ...
          }: {
            # Create user if you want.
            # Home-merger will create a user if you don't (practical!)
            users.users."anon" = {
              isNormalUser = true;
            };
            home-merger = {
              users = ["anon"];
              extraSpecialArgs = {inherit inputs;};
              umports = [
                ./.
                inputs.nur.modules.homeManager.default
              ];
            };
          })
        ];
      };
    };
  };
}
