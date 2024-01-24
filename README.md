# Home-merger - Manage users home from multiple flakes.

**Internaly uses home-manager**.

Manage users home from inside multiple flakes without collision.

## For what usage ?

I use it to manage a lot of modules without compromising on readability. It
allows for small flake files that contains the every arguments for their
submodules.

This diminishes the number of lines in the `flake.nix` file. You can then know
what a flake does and to which users without having to read modules.

Modify users from inside a subflake without collisions.

### The problem...

If you manage your **NixOs configuration** with **flakes and home-manager**. You
want to import a flake that uses home-manager too... **Error**.

As of today, nix users can not declare `home-manager.users` multiple times
through configuration files. If you want to use **multiple** flakes that modify
specific users homes through home-manager, you will get the error
`option home-manager.user already declared`.

### A solution

The home-merger flake is a way to circumvent this restriction.

## Example

It adds an option set to your configuration that you can use multiple times to
import home-manager modules for specific users.

```nix
home-merger = {
    # A list of user name for which to apply the modules
    users = ["alice", "bob"];
    # Arguments to pass to the module
    extraSpecialArgs = { inherit inputs cfg; };
    # A list of modules to be applied
    modules= [./home.nix];
}
```

### Installation (flake)

You must use nixos with flakes. Add this repository adress to your flake inputs.

```nix
# flake.nix (truncated file)
{
  description = "NixOS flake for paranoid network configuration";
  inputs = {
    home-merger.url = "github:pipelight/home-merger";
  };
  outputs = {
    nixpkgs,
    home-merger,
    ...
  };
}
```

This flake is truncated. Here you only declared a dependencie on the home-merger
flake. You will need to further import it according to your needs.

More detailes below.

## Usage

- A standalone usage.
- A Nixos flake configuration.
- A Nixos flake configuration that imports flakes modules.

### Standalone

You can begin to use it standalone in a default.nix file. It imports a
`home.nix` file from your `default.nix`.

Those files being related, it was awkward to import them both at the flake
level. This way only the `default.nix` needs to be imported from the `flake.nix`
file.

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

This is pragmatic but doesn't allow for much flexibility because the username is
hardcoded.

We want to define a global variable for usernames.

We want to see **which users has which modules enabled at glance.** So we will
use the flake style.

### Configuration with flakes

Let's say you want to separate concerns and create a flake is related to
**paranoid networking things**. You want this flake to be **applied to a
specific list of users**.

First split your flakes into three files.

```sh
my-network-flake
├── default.nix
├── flake.nix
└── home.nix
```

```nix
# flake.nix
{
  description = "NixOS flake for paranoid network configuration";
  inputs = {
    home-merger.url = "github:pipelight/home-merger";
  };
  outputs = {
    nixpkgs,
    home-merger,
    ...
  } @ inputs: let

      system = "x86_64-linux";
      pkgs = nixpkgs;
      homeMergerModule = home-merger.nixosModules.default;

  in
    nixosConfiguration = {
      desktop = pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs system;};

        # Define your variables to inject inside modules
        modules = let
          ApplyOnUsers = ["alice" "bob"];
        in [
          homeMergerModule
          (import ./default.nix {inherit config pkgs lib utils inputs ApplyOnUsers;})
        ];
      }
    }
};
```

Pass the `cfg` argument down to the home-manager module.

The `home.nix` file is directly imported by the `default.nix`.

This way instead of importing 2 modules with hardcoded usernames you can import
a single module and pass usernames as variables.

The usual:

```nix
imports = [
    networkModule,
    homeNetworkModule
]
```

Becomes:

```nix
imports = [ 
    (import networkModule { inherit config pkgs lib utils inputs ApplyOnUsers});
]
```

```nix
# default.nix
{
    pkgs,
    lib,
    utils,
    inputs,
    ApplyOnUsers, # Passes whatever variables you need
    ...
}:{
    home-merger = {
        # A list of user name
        users = ApplyOnUsers;
        # By passing inputs, you can use flakes from inside your `home.nix` file.
        extraSpecialArgs = { inherit inputs; };
        # A list of home-manager modules to import
        modules= [./home.nix];
    }
}
```

### Modules with flakes

The most flexible. This is what I personnaly use... TODO
