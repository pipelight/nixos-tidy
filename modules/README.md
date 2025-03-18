# Home-merger (better separation of concerns)

Merge a nixOs module and its home-manager equivalent module in a single module.
_Internaly uses home-manager_.

## Problem

**When using home-manager** you can find yourself
with an unflexible configuration that can't be shared without
substential rewritting efforts because:

- You can get away with **hardcoded user names** (and some other variables).

  ```nix
  users.users.<username> = {
      some_stuffs = {};
  }
  ```

- For a same program, you have to import standard modules and home-manager modules separately,
  resulting in file duplication and **awkward dependency management**.

  ```sh
  .
  ├── nixos
  │   ├── gnome.nix
  │   └── hyprland.nix
  └── home-manager
      ├── gnome.nix #should be grouped with its homologous.
      └── hyprland.nix
  ```

  and **unwelcoming top-level module declaration**.

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

## Solution

To circumvent this issues, you may want to
either make your own functions,
ditch home-manager (pretty radical),
or simply use the home-merger module.

- This results in **tidy filetrees**, with separation of concerns.

  ```sh
  .
  ├── gnome
  │   ├── default.nix
  │   └── home.nix
  └── hyprland
      ├── default.nix
      └── home.nix
  ```

- And **friendly top-level module declaration**.

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

The magic happens in the standard module file (here `default.nix`).
You can import a home-manager modules through home-merger.

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

### How it works

Calling home-manager directly would raise an error
because you can only declare the home-manager module once.

The home-merger function simply aggregates every home-manager nixosModules
to declare them at once.

_It is just a 60 lines function but oh boy does it do good!_

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

And use it as an argument value in home-merger.

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

Head to the template directory for a boilerplate
-> [example](https://github.com/pipelight/nixos-tidy/example).
