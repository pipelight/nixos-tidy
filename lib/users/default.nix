{lib}: let
  # Creates normal unpriviledged users from a provided list of names.
  user_add_many = user_list: {
    users.users =
      {}
      // builtins.listToAttrs (
        builtins.map (user: {
          name = user;
          value = {
            isNormalUser = true;
          };
        })
        user_list
      );
  };
  system_user_add_many = user_list: {
    users.users =
      {}
      // builtins.listToAttrs (
        builtins.map (user: {
          name = user;
          value = {
            isSystemUser = true;
          };
        })
        user_list
      );
  };

  groups_add_users = group_list: user_list: {
    users.groups =
      {}
      // builtins.listToAttrs (
        builtins.map (group: {
          name = group;
          value = {
            members = user_list;
          };
        })
        group_list
      );
  };

  ensure_users = cfg: users: let
    mustCreate =
      builtins.filter
      (
        username:
        # if true
          if !builtins.hasAttr "${username}" cfg.users.users
          then true
          else false
      )
      users;
  in
    user_add_many mustCreate;
in {
  inherit user_add_many;
  inherit system_user_add_many;
  inherit groups_add_users;
  inherit ensure_users;
}
