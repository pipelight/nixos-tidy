# Nixos-tidy

Nix library and Nix modules
to ease the creation of
**sharable, flexible and standardized Nixos configurations**.

You may find a complete working example in the crocuda module repository.
Where all the magic happens in `default.nix`.
-> [crocuda.nixos](https://github.com/pipelight/crocuda.nixos).

## Install

Add the flake to your existing configuration.

```nix
# flake.nix
{
  description = "My NixOS flake";
  inputs = {
    nixos-tidy.url = "github:pipelight/nixos-tidy";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
      nixosConfiguration = {
      default = pkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
            inputs.nixos-tidy.nixosModules.home-merger;
            inputs.nixos-tidy.nixosModules.allow-unfree;
            ./default.nix
        ];
      };
    }
  };
}
```

## Yunfachi's Umport

Now a way to get rid of all this boilerplate of **import** statements,
is to use a top-level **umport**.

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

```sh

.
├── gnome
│   ├── default.nix
│   └── home.nix
├── hyprland
│  ├── default.nix
│  └── home.nix
└── default.nix #put boilerplate code at the top-level.
```

## Allow unfree software (with regex)

Cherry pick the unfree software you want to allow with regexes.

### Problem

You can either allow every unfree software, or you must set it per package.
This can become very anoying when facing big dependency trees like with
printers, scanners, graphics cards,... you know the drill.

```nix
#default.nix
config.allowUnfree = true;
# or
config.allowUnfreePredicate = [
    "package_name"
    "other_similar_package_name"
    "on_and_on"
];
```

### Solution

Fortunately some packages have the same prefixe in their names (nvidia_this, nvidia_that,...)
Through the allow-unfree function you can define the package to allow with regexes.

## Misc

A allow-unfree options that supports regex.

```nix
#default.nix
allow-unfree = [
    # use regexes
    "nvidia-.*"
    "cuda.*"
];
```
