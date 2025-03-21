{lib}: let
  userAddMany = user_list: {
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
  userAddMany_system = user_list: {
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

  add_users_to_groups = user_list: group_list: {
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

  ensureUsers = cfg: users: let
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
    userAddMany mustCreate;
in {
  inherit userAddMany;
  inherit userAddMany_system;
  inherit add_users_to_groups;
  inherit ensureUsers;
}
