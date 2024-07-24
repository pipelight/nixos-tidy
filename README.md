# Nixos-tidy

A set of Nix functions/modules
to ease the creation of
**sharable, flexible and standardized Nixos configurations**.

## Home-merger (better separation of concerns)

**Internaly uses home-manager**.

### Problem

When using home-manager you can find yourself
with an unflexible configuration that can't be shared without
substential rewritting efforts because:

- You can get away with **hardcoded user names** (and some other variables).

```nix
users.users.<username> = {
    some_stuffs = {};
}
```

- You have to export standard modules and home-manager modules separately,
  resulting in **awkward file tree and dependency management**,
  and **unwelcoming top-level module declaration**.

```sh
.
├── nixos
│   ├── gnome.nix
│   └── hyprland.nix
└── home-manager
    ├── gnome.nix # should be grouped with its homologous
    └── hyprland.nix
```

```nix
# flake.nix
nixosConfiguration = {
    default = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
            ./nixos/gnome.nix
            home-manager.nixosModules.home-manager {
                home-manager.users.<username> = {pkgs,...}: {
                   imports = [
                      ./home-manager/gnome.nix
                   ];
                };
            };
        ];
    };
};

```

### Solution

You may want to make your own function to circumvent this issues,
or simply use the home-merger module.

It enables **tidy filetrees**.

```sh
.
├── gnome
│   ├── default.nix
│   └── home.nix
└── hyprland
    ├── default.nix
    └── home.nix
```

And **friendly top-level module declaration**.
You then only need to import one file for both
standard module and home-manager module.

```nix
# flake.nix
nixosConfiguration = {
    default = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
            ./gnome/default.nix
            ./hyprland/default.nix
        ];

    };
};
```

The magic happens in the standard module file.

```nix
# default.nix
home-merger = {
    # A list of users username for which to apply the modules.
    users = ["alice", "bob"];

    # Arguments to pass to the module
    extraSpecialArgs = { inherit inputs cfg; };

    # A list of modules to be applied to the users
    modules = [
        ./home.nix
    ];
}
```

## Usage in your configuration files

Time to glow by your nix aptitudes.

You may want to declare your users only once
at the top-level of your configuration.

Just create a global variable.

```nix
# flake.nix
options = with lib; {
  my_config = {
      users = mkOption {
        type = with types; listOf str;
        default = [];
        example = literalExpression "[\"alice\",\"bob\"]";
        description = ''
          The name of users to apply modules to.
        '';
      };
  };
};
config.my_config.users = ["anon"];

```

And use it in home-merger.

```nix
# default.nix
home-merger = {
    users = config.my_config.users;
    extraSpecialArgs = { inherit inputs; };
    modules = [
        ./home.nix
    ];
}
```

### Install

Use flakes.

```nix
# flake.nix
{
  description = "My NixOS flake";
  inputs = {
    nixos-utils.url = "github:pipelight/nixos-tidy";
  };
  outputs = {
    nixpkgs,
    nixos-utils,
    ...
  } @ inputs: let
    homeMergerModule = nixos-utils.nixosModules.home-merger;
  in {
      nixosConfiguration = {
      default = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
            ./default
            homeMergerModule
        ];
      };
    }
  };
}
```

## Allow-unfree (with regex)

Cherry pick the unfree software you want to allow (can and should use regex!!)

```nix
#default.nix
allow-unfree = [
    # use regexes
    "nvidia"
];
```

### Install

Use flakes.

```nix
# flake.nix
{
  description = "My NixOS flake";
  inputs = {
    nixos-utils.url = "github:pipelight/nixos-tidy";
  };
  outputs = {
    nixpkgs,
    nixos-utils,
    ...
  } @ inputs: let
    allowUnfreeModule = nixos-utils.nixosModules.allow-unfree;
  in {
      nixosConfiguration = {
      default = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
            ./default
            allowUnfreeModule
        ];
      };
    }
  };
}
```
