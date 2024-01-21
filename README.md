# Home-merger: Split home-manager declarations in their related flakes.

Manage users home from multiple flakes.

> [!IMPORTANT]\
> Beta, Works like a charm but lacks flexibility.

## Manage homes from mutltiple flakes.

### The problem...

You manage your **NixOs configuration** with **flakes and home-manager**. You
want to import a flake that uses home-manager as well... **Error**.

As of today, nix users can not declare `home-manager.users` multiple times
through configuration files. If you want to use **multiple** flakes that modify
specific users homes through home-manager, you will get the error
`option home-manager.user already declared`.

### A solution

The home-merger flake is a way to circumvent this restriction.

It adds an option set to your configuration that you can use multiple times to
import home-manager modules for specific users.

```nix
home-merger = {
    # A list of user name for which to apply the modules
    users = ["alice", "bob"];
    # A list of modules to be applied
    modules= [./home.nix];
}
```

## Usage

### Standalone

You can begin to use it standalone in a default.nix file.

```nix
# default.nix
{
    pkgs,
    lib,
    inputs,
    ...
}:{
    home-merger = {
        # A list of user name
        users = ["alice", "bob"];
        # A list of modules
        modules= [./home.nix];
    }
}
```

This is pragmatic but doesn't allow for much cohesion between home.nix files.
Here we want to see **which users has which modules enabled at glance.** So we
will use the flake style.

### Flake style

Let's say you split your flakes into three files.

This flake is related to **networking things**. You want to separate concerns.


```sh
my-network-flake
├── default.nix
├── flake.nix
└── home.nix
```

```nix
# default.nix
{
    pkgs,
    lib,
    inputs,
    cfg, # Passes the arguments (modules and users) to the home.nix file
    ...
}:{
    home-merger = {
        # A list of user name
        users = cfg.users;
        # A list of modules
        modules= [./home.nix];
    }
}
```

```nix
# flake.nix (truncated file)
outputs = {
    nixosModules = {
      default = {
        config,
        pkgs,
        lib,
        ...
      }: {
        imports = [ 
            # This ugly import statement is essential to pass the "cfg" set
            # to downstream modules
            # without raising an "infifite recursion" error.
            (import ./default.nix { inherit config pkgs lib utils inputs cfg});
        ]
      }
    }
};
```
