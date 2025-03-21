# Nixos-tidy - Filesystem based config.

<img src="./public/images/nixos-tidy.png" width="300px"/>

Nix library and Nix modules
to ease the creation of **Nixos configurations**.

## Install (add to your config).

Add the flake to your existing configuration.

```nix
# flake.nix
inputs = {
    nixos-tidy.url = "github:pipelight/nixos-tidy";
};
```

```nix
# flake.nix
  outputs = {
    self,
    nixpkgs,
    ...
  }: {
      nixosConfiguration = {
      default = pkgs.lib.nixosSystem {
        modules = [
            inputs.nixos-tidy.nixosModules.home-merger
            inputs.nixos-tidy.nixosModules.allow-unfree
            ./default.nix
        ];
      };
    }
  };
```

Every files of this-file is recursively imported
without the need of import statements.

## A single Top-level import 🤌 (umports).

You want to separate your configuration files
by concerns not by module types.

```sh
.
├── gnome
│   ├── default.nix
│   ├── test.nix
│   └── home.nix
├── hyprland
│   ├── default.nix
│   ├── test.nix
│   └── home.nix
└── flake.nix # put boilerplate code at the flake top-level.
```

Get rid of **imports** statements everywhere.

A top-level import statement.
Imports all the files from inside a directory.

```nix
umports = {
    paths = [
        inputs.other_module.nixosModules.default
        ./my_module
    ];
};
```

Umport makes the distinctions between module types based on
file names.

- \*.nix as nix modules
- home.nix, home.\*.nix and home\_\*.nix as home-manages modules
- test.nix, test.\*.nix and test\_\*.nix as test modules.

## Multiple home-manager declarations (Home-merger).

### Top-level import (Umports)

```nix
home-merger = {
    users = my_config.users;
    umports.paths = [
            inputs.other_module.homeManagerModules.default
            ./my_module
        ];
    };
};
```

## Example

Minimalists examples in the `template` directory.

You may find a complete working example at [crocuda.nixos](https://github.com/pipelight/crocuda.nixos).

Where all the magic happens in `default.nix`.
