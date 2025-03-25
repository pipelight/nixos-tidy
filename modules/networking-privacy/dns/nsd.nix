{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.crocuda;
  dns = inputs.dns.lib;
  unboundEnabled = config.services.unbound.enable;
in
  with lib;
    mkIf cfg.servers.dns.enable {
      services = {
        nsd = {
          enable = true;
          # zonefilesCheck = false;

          verbosity = 2;
          extraConfig = ''
            server:
              hide-identity: yes
              hide-version: yes
          '';

          port =
            if unboundEnabled
            # Run on non default port if unbound is already running
            then 553
            # Listen on default port
            else 53;

          interfaces =
            if unboundEnabled
            # Listen on localhost only if unbound is already running.
            then ["127.0.0.1" "::1"]
            # Listen on public
            else ["0.0.0.0" "::0"];

          zones = with dns.combinators;
            mkDefault {
              "example.com" = {
                data = dns.toString "example.com" {
                  useOrigin = true;
                  TTL = 60 * 60;
                  SOA = {
                    nameServer = "ns1";
                    adminEmail = "admin";
                    serial = 60 * 365 * 24 * 60 * 60;
                  };
                };
              };
            };
        };
      };
    }
