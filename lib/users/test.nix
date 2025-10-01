{
  lib,
  slib,
  ...
}:
with slib; {
  testMkUser = {
    expr = user_add_many ["alice" "bob"];
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
    expr = system_user_add_many ["alice" "bob"];
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
    expr = groups_add_users ["wheel" "audio"] ["alice" "bob"];
    expected = {
      users.groups.wheel.members = ["alice" "bob"];
      users.groups.audio.members = ["alice" "bob"];
    };
  };
  testEnsureUsers = {
    expr = ensure_users {
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
