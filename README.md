# Nix Home-merger utilty for simpler home-manager

## Manage homes from flakes.

As of today, nix users can not declare "home-manager.users" multiple times. I
haven't inspected the source code so I don't know why

- maybe the option is defined as unique
- maybe lib.mkMerge isn't possible due to internal architecture

If you want to use **multiple** flakes that modify specific users homes through
home-manager, You will get the error `option home-manager.user already declared`
because of multiple usages of home-manager through your flakes,

Here is a workaround with its helper functions

1. Do not apply changes from inside the flake! But export home modules from your
   flakes.

```nix
# Declare a "home" module in Nix flake outputs

outputs = {
    nixosModules = {
      # Set the exported module name.
      home = {
        config,
        pkgs,
        lib,
        ...
      }: {
        imports = with utils; mKMergeHomes [./a/home.nix ./b/home.nix] { inherit stuffs };

        # shorthand for
        imports = [ 
            (import ./a/home.nix { inherit stuffs });
        ]

        # or without inheritence
        imports = with utils; [./terminal/home.nix ./git/home.nix];
      }
    }
}
```

2. Then merge "home" modules in a top flake and apply the modules to a user or
   user list.

## Usage

```nix
home_modules = mkMergeHomes 
    [./a/home.nix ./b/home.nix ] 
    {inherit config pkgs lib inputs cfg;} ;

mkApplyHomes home_modules ["username" ];
```

A function to merge home files and apply them to a list of users merge_homes [
homeManagerModule1, homeManagerModule2 ]
