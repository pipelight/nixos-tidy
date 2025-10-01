{
  lib,
  inputs,
  ...
}: let
  dns = inputs.dns.lib;
in rec {
  mkDefaultZone = {
    domain,
    ipv4,
    ipv6,
  }:
    with dns.combinators; let
      data =
        {
          useOrigin = true;
          TTL = 60 * 60;
          SOA = {
            nameServer = "ns1";
            adminEmail = "admin";
            serial = 60 * 365 * 24 * 60 * 60;
          };
        }
        // host ipv4 ipv6
        // delegateTo ["ns1" "ns2"]
        // {
          MX = [(mx.mx 10 "mx1")];
          TXT = [
            (spf.soft ["mx"])
          ];
          SRV = [
            {
              service = "autodiscovery";
              proto = "tcp";
              port = 443;
              target = "autoconfig";
            }
          ];
          DMARC = [
            (dmarc.postmarkapp "mailto:admin@${domain}")
          ];
        }
        // {
          subdomains = let
            # Use local nameservers and mail servers.
            a_records = host ipv4 ipv6;
          in {
            # Nameservers
            ns1 = a_records;
            ns2 = a_records;
            # Mail servers
            mx1 =
              a_records
              // {
                TXT = [
                  (spf.soft ["a"])
                ];
              };
            # Wildcard
            "*" = a_records;
          };
        };
    in {
      ${domain} = {
        data = dns.toString domain data;
      };
    };
}
