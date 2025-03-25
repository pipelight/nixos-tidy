{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.networking.privacy;
  nsdEnabled = config.services.nsd.enable;
in
  # enabled on privacy feature only
  mkIf cfg.enable {
    services = {
      unbound = {
        settings = {
          server = {
            unblock-lan-zones = "yes";
            val-permissive-mode = "yes";
            private-domain = ["lan"];

            # send minimal amount of information to upstream.
            hide-identity = "yes";
            hide-version = "yes";
            verbosity = 2;

            interface = [
              "0.0.0.0"
              "::0"
            ];
          };
          remote-control = {
            control-enable = true;
            control-interface = [
              "127.0.0.1"
              "::1"
            ];
          };
          forward-zone = [
            {
              name = ".lan";
              stub-addr = [
                "192.168.1.1"
                # "::1"
              ];
            }
            {
              name = ".";
              forward-addr = [
                #Mullvad
                "194.242.2.4"
                "2a07:e340::4"
                #Quad9
                "9.9.9.9"
                "2620:fe::fe"
                "2620:fe::9"
              ];
            }
          ];
          stub-zone = [
            (mkIf nsdEnabled {
              name = ".";
              stub-addr = [
                "127.0.0.1@553"
                "::1@553"
              ];
            })
          ];
        };
      };
    };
  }
