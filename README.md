# Nixos-tidy

<img src="./public/images/nixos-tidy.png" width="300px"/>

Nix library and Nix modules
to ease the creation of
**sharable, flexible and standardized Nixos configurations**.

You may find a complete working example in the crocuda module repository.
Where all the magic happens in `default.nix`.
-> [crocuda.nixos](https://github.com/pipelight/crocuda.nixos).

## Add to your nix config.

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

## Top-level import 🤌.

A top-level import statement.
Imports all the files from inside a directory.

```nix
imports = inputs.nixos-tidy.umport {
    # User specific
    paths = [./my_module];
};
home-merger = {
    users = my_config.users;
    modules = inputs.nixos-tidy.umport-home {
        paths = [./my_module];
    };
};
```

Every files of this-file tree will be recursively imported
without the need of import statements.

Umport makes the distinctions between module types based on
file names.

- \*.nix as nix modules
- home.nix, home.\*.nix and home\_\*.nix as home-manages modules
- test.nix, test.\*.nix and test\_\*.nix as test modules.

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
└── default.nix #put boilerplate code at the top-level.
```
