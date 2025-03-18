## Allow unfree software (with regex)

Cherry-pick the unfree software you want to allow with regexes.

### Problem

You can either allow every unfree software, or you must set it per package.
This can become very annoying when facing big dependency trees like with
printers, scanners, graphics cards... you know the drill.

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

Fortunately some packages have the same prefix in their names (nvidia_this, nvidia_that,...)
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
