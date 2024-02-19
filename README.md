# Nixos utils

Utilities for modular and readable nixos configurations.

### Installation

Use flakes.

```nix
# flake.nix
{
  description = "NixOS flake for paranoid network configuration";
  inputs = {
    nixos-utils.url = "github:pipelight/nixos-utils";
  };
  outputs = {
    nixpkgs,
    nixos-utils,
    ...
  } @ inputs: let
    homeMergerModule = nixos-utils.nixosModules.home-merger;
    allowUnfreeModule = nixos-utils.nixosModules.home-merger;
  in {
      nixosConfiguration = { 
      crocuda = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
            ./default
            homeMergerModule
            allowUnfreeModule
        ];
      };
    }
  };
}
```

## Home-merger

**Internaly uses home-manager**.

Separate concerns and scatter your `home.nix` files.

```sh
.
├── module1 (gnome)
│   ├── default.nix
│   └── home.nix
└── module2 (hyprland)
    ├── default.nix
    └── home.nix
```

Import home files from your module `default.nix`.

```nix
#default.nix
home-merger = {
    # A list of user name for which to apply the modules
    users = ["alice", "bob"];
    # Arguments to pass to the module
    extraSpecialArgs = { inherit inputs cfg; };
    # A list of modules to be applied to the user
    modules= [./home.nix];
}
```

This flake is truncated. Here you only declared a dependencie on the home-merger
flake. You will need to further import it according to your needs.

More detailes below.

## Allow-unfree

Cherry pick the unfree software you want to allow

```nix
allow-unfree = [
    # use regexes
    "nvidia"
];
```
