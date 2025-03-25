{
  config,
  lib,
  ...
}: {
  # Set the module options
  options = with lib; {
    networking = {
      privacy = {
        enable = mkEnableOption ''
          Enable ipv6 privacy features.
          Quad9 dns.
        '';
        ipv6 = {
          secret = mkOption {
            type = with types; str;
            description = ''
              A string to generate the inbound ipv6 interface identifier from.
              Only used if strategy is set to "fixed".
            '';
            default = config.networking.hostName;
          };
          iid = mkOption {
            type = with types; nullOr str;
            description = ''
              A dummy ipv6 interface identifier (the last 64bits)
              to generate default inbound address from.
              Only used if strategy is set to "fixed".
            '';
            example = lib.literalExpression ''
              babe:feed:b0ba:fett
            '';
            default = null;
          };
          strategy = mkOption {
            type = with types; enum ["fixed" "random"];
            description = ''
              Set the level of privacy.

              - fixed: Recommended for servers.
                Set fixed ipv6 based on a secret whether than on device macaddress.

              - random: Recommended for desktops.
                Set random ipv6 for outgoing traffic on each network with rotation every few hours.

            '';
            default = "fixed";
          };
        };
      };
    };
  };

  /*
  Create a default network manager connection
  Or a default vswitch.

  Prohibit systemd-networkd usage.
  (Because it is lagging behind in terms of privacy features as of 22/05/2025)
  But still force some parameters just in case.

  */
  imports = [
    # Set a fixed inbound ipv6 + random outbounds
    ./common.nix
    ./fixed.nix
    # Set random ipv6 inbound/outbound
    ./random.nix

    # Dns resolver
    ./dns/unbound.nix
  ];
}
