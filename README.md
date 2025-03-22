# Nixos-tidy - Filesystem based config.

<img src="./public/images/nixos-tidy.png" width="300px"/>

Modules and library for filesystem based configuration.

## Install (add to your config).

Add the flake to your existing configuration.

```nix
# flake.nix
inputs = {
  nixos-tidy = {
    url = "github:pipelight/nixos-tidy";
    inputs.nixpkgs.follows = "nixpkgs";
  };
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
        # pick some modules
        inputs.nixos-tidy.nixosModules.home-merger
        ({
          config,
          pkgs,
          lib,
          inputs,
          ...
        }: let
            # Use functions from library.
            slib = inputs.nixos-tidy.lib;
        in {

        })
      ];
    };
  }
};
```

## Examples

- Minimalist

  Find many minimalists examples self-contained in a single `flake.nix` file,
  in the [templates directory](https://github.com/pipelight/nixos-tidy/blob/master/templates/).

- Real world

  And a complete working example at [crocuda.nixos](https://github.com/pipelight/crocuda.nixos).
  Where all the magic happens in `default.nix`.

## A single Top-level imports 🤌 (umports).

Use `slib = inputs.nixos-tidy.lib`

Get rid of **imports** statements everywhere.
You only need **one top-level imports** statement.

It imports recursively all the files from inside a directory.

### Nix only (without home-manager)

```nix
# flake.nix
imports = let
  slib = inputs.nixos-tidy.lib;
in
  []
  # Import all nixos modules recursively
  ++ slib.umportNixModules {
    paths = [
      inputs.anOtherFlake.nixosModules.default
      ./.
    ];
    exclude = [
      # Do not forget to exclude current file
      # and flake definition.
      ./default.nix
      ./flake.nix
    ];
  };
```

### With home-manager

It enables a most wanted separation of concerns,
where home-manager modules and nix modules
can lay in the same directory.

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

```nix
imports = let
  slib = inputs.nixos-tidy.lib;
in
  []
  # Import all nixos modules recursively
  ++ slib.umportNixModules {
    paths = [
      inputs.anOtherFlake.nixosModules.default
      ./.
    ];
    exclude = [
      # Do not forget to exclude current file
      # and flake definition.
      ./default.nix
      ./flake.nix
    ]
  }
  ++ slib.umportHomeModules {
    paths = [
      inputs.nur.modules.homeManager.default
      ./.
    ];
  }
  # Home-merger options
  {
    users = ["anon"];
  };
```

### File naming constraints.

See the [template flake with umports](https://github.com/pipelight/nixos-tidy/blob/master/templates/umports/flake.nix) for a working example (with home-manager).

Umports makes the distinctions between module types based on
filenames.
So be sure to have your filenames checked.

Nix: \*.nix
Home-manager: home.nix || home.\*.nix || home\_\*.nix
Unit-tests: test.nix || test.\*.nix || test\_\*.nix.

## A flexible home-manager (Home-merger).

Use `inputs.nixos-tidy.nixosModules.home-merger`.

With home-manager, you may only declare your users config in a single place.
It makes it difficult to have users declared in separate files.

Home-merger is a wrapper around home-manager that you can call multiple times.

### Top-level import (Umports)

- Use it to split user declarations.

```nix
# file_1.nix
home-merger = {
  users = ["alice"];
  umports.paths = [
    ./alice_modules
  ];
};
```

```nix
# file_2.nix
home-merger = {
  users = ["bob"];
  imports = [
    inputs.anOtherModule.homeManagerModules.default
  ];
  umports.paths = [
    ./bob_modules
  ];
};
```

- Or to import a `home.nix` module from an adjacent `default.nix` module.

```sh
.
└── fish
    ├── default.nix
    └── home.nix
```

```nix
# fish/default.nix
programs.fish.enable = true;

home-merger = {
  users = ["bob"];
  umports.paths = [
      ./home.nix
  ];
};
```

```nix
# fish/home.nix
home.programs.fish.enable = true;
```

## Allow-unfree

Use `inputs.nixos-tidy.nixosModules.allow-unfree`

Cherry-pick unfree software exceptions with regexes.

```nix
#default.nix
allow-unfree = [
  # use regexes
  "nvidia-.*"
  "cuda.*"
];
```

## Network privacy (ipv6)

Use `inputs.nixos-tidy.nixosModules.networking-privacy`

Not released yet.
Only on dev branch.

Strengthen ipv6 privacy configuration for
Linux kernel,
NetworkManager,
openvswitch,
static configuration
and systemd-networkd.
