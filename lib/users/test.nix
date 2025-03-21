{
  lib,
  slib,
  ...
}:
with slib; {
  testMkUser = {
    expr = userAddMany ["alice" "bob"];
    expected = {
      users.users = {
        alice = {
          isNormalUser = true;
        };
        bob = {
          isNormalUser = true;
        };
      };
    };
  };
  testMkSystemUser = {
    expr = userAddMany_system ["alice" "bob"];
    expected = {
      users.users = {
        alice = {
          isSystemUser = true;
        };
        bob = {
          isSystemUser = true;
        };
      };
    };
  };
  testAddUserToGroup = {
    expr = add_users_to_groups ["alice" "bob"] ["wheel" "audio"];
    expected = {
      users.groups.wheel.members = ["alice" "bob"];
      users.groups.audio.members = ["alice" "bob"];
    };
  };
  testEnsureUsers = {
    expr = ensureUsers {
      users.users = {
        anon = {
          isNormalUser = true;
        };
      };
    } ["alice" "bob" "anon"];
    expected = {
      users.users = {
        alice = {
          isNormalUser = true;
        };
        bob = {
          isNormalUser = true;
        };
      };
    };
  };
}
