{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.crocuda;

  unboundEnabled = config.services.unbound.enable;

  ## Globals
  iid = cfg.network.privacy.ipv6.iid;
  # computed_iid = slib.ip.str_to_iid cfg.network.privacy.ipv6.secret;
  # token =
  #   if (!isNull iid)
  #   then iid
  #   else computed_iid;
  # computed_mac = slib.ip.str_to_mac cfg.network.privacy.ipv6.secret;
in
  mkIf (cfg.network.privacy.enable
    && cfg.network.privacy.ipv6.strategy
    == "fixed") {
    ##########################
    # Force usage of ipv6 privacy extension in
    # - kernel parameters (low level)
    # - networkmanager (high level)
    # - systemd-networkd (high level)
    # + dhcp (high level)

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
        "net.ipv6.conf.default.addr_gen_mode" = 2;
        "net.ipv6.conf.all.addr_gen_mode" = 2;

        # Set secret to hashed string
        # "net.ipv6.conf.default.stable_secret" = "::${token}";
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
          # slaac token ::${token}
        '';
      };
    };

    ##########################
    # You should use either systemd-networkd OR NetworkManager.

    ## system-networkd
    systemd.network.config = ''
      [Network]
      DHCP=yes
      # IPv6Token=::${token}
    '';

    networking.interfaces = mkIf (!config.networking.networkmanager.enable) {
      # end0.macAddress = computed_mac;
      # eno1.macAddress = computed_mac;
      # ens3.macAddress = computed_mac;
    };

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
            id = "wired-fixed";
            type = "ethernet";
          };
          ethernet = {
            # cloned-mac-address = computed_mac;
          };
          ipv4 = {
            dns-search = "lan";
            # dns-priority default = 100, vpn = 50
            dns-priority = 20;
            method = "auto";
          };
          ipv6 = {
            dns-search = "lan";
            # dns-priority default = 100, vpn = 50
            dns-priority = 20;
            method = "auto";

            # Fixed inbound ip
            addr-gen-mode = "eui64";
            # token = "::${token}";

            # Random outbound ip
            ip6-privacy = 2;
          };
        };
      };
    };
  }
