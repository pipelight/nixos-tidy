{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.crocuda;

  useradd = user_list:
    builtins.listToAttrs (
      builtins.map (user: {
        name = user;
        value = {
          isNormalUser = true;
        };
      })
      user_list
    );
  system_useradd = user_list:
    builtins.listToAttrs (
      builtins.map (user: {
        name = user;
        value = {
          isSystemUser = true;
        };
      })
      user_list
    );
  add_users_to_groups = user_list: group_list:
    builtins.listToAttrs (
      builtins.map (group:
        (user: {
          name = group;
          value = {
            isSystemUser = true;
          };
        })
        user_list)
      group_list
    );

  users.groups = let
    users = cfg.users;
  in {
    networkmanager.members = users;
    bluetooth.members = users;
  };
in {
  # Usage
  users.users = normal_users cfg.users;
}
