{
  config,
  lib,
  ...
}:
with lib; let
  slib = import ../../lib/network/default.nix {inherit lib;};

  cfg = config.networking.privacy;

  # Dns local caching/resolver.
  unboundEnabled = config.services.unbound.enable;

  ## Globals

  # Mac address
  computed_mac = slib.str_to_mac cfg.network.privacy.ipv6.secret;

  # Interface identifier
  # From static
  iid = cfg.ipv6.iid;
  # From secret
  computed_iid = slib.str_to_iid cfg.ipv6.secret;

  token =
    if (!isNull iid)
    then iid
    else computed_iid;
in
  mkIf (cfg.enable
    && cfg.ipv6.strategy
    == "random") {
    ##########################
    # Force usage of ipv6 privacy extension in
    # - kernel parameters (low level)
    # - networkmanager (high level)

    ## Kernel
    boot = {
      kernelParams = ["IPv6PrivacyExtensions=1"];
      # More information about keys possible values at:
      # https://sysctl-explorer.net/net/ipv6/
      kernel.sysctl = {
        # Enable maximal privacy extensions
        "net.ipv6.conf.default.use_tempaddr" = mkForce 2;
        "net.ipv6.conf.all.use_tempaddr" = 2;

        # Generate random ipv6
        # 0 = "eui64"
        # 1 = "eui64"
        # 2 = "stable-privacy" with secret
        # 3 = "stable-privacy" with random secret
        "net.ipv6.conf.default.addr_gen_mode" = 3;
        "net.ipv6.conf.all.addr_gen_mode" = 3;
      };
    };

    ##########################
    ## dhcpcd
    networking = {
      # Force dhcpcd usage with networkmanager (not working)
      # for tool concistency with servers that do not use networkmanager.
      # useDHCP = mkForce true;
      dhcpcd = {
        # enable = true; #default
        extraConfig = ''
          # nohook resolv.conf
          # slaac private
        '';
      };
    };

    ##########################
    # You should use either systemd-networkd OR NetworkManager.

    ## system-networkd
    systemd.network.config = ''
      [Network]
      DHCP=yes
      IPv6PrivacyExtensions=kernel
    '';

    ## NetworkManager
    # https://www.networkmanager.dev/docs/api/latest
    networking.networkmanager = mkIf config.networking.networkmanager.enable {
      logLevel = "INFO";

      ## Use external dns -> unbound
      dns =
        if unboundEnabled
        then "none"
        else "default";

      ## Use external dhcp -> dhcpcd (not working)
      # Not working because of concurency error.
      # dhcp = "dhcpcd";
      dhcp = "internal";

      connectionConfig = {
        # MAC address randomization
        # Random on cable link
        "ethernet.cloned-mac-address" = mkForce "random";
        # Random on wifi
        "wifi.cloned-mac-address" = mkForce "random";
      };

      ensureProfiles.profiles = {
        default = {
          connection = {
            id = "wired-random";
            type = "ethernet";
          };
          ipv4 = {
            dns-search = "lan";
            # dns-priority default = 100, vpn = 50
            dns-priority = 20;
            method = "auto";
          };
          ipv6 = {
            dns-search = "lan";
            # Local resolver priority
            # dns-priority default = 100, vpn = 50
            dns-priority = 20;
            method = "auto";

            # Random inbound ip
            addr-gen-mode = "stable-privacy";

            # Random outbound ip
            ip6-privacy = 2;
          };
        };
      };
    };
  }
