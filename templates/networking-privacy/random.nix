{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.crocuda;
in
  mkIf (cfg.network.privacy.enable
    && cfg.network.privacy.ipv6.strategy
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

    ## dhcpcd
    networking.dhcpcd = {
      enable = true; #default
      extraConfig = ''
        nohook resolve.conf
        slaac private
      '';
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
    networking.networkmanager = {
      logLevel = "INFO";

      ## Use external dns -> unbound
      dns = "none";

      ## Use external dhcp -> dhcpcd
      dhcp = "dhcpcd";
      # dhcp = "internal";

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
            method = "auto";
          };
          ipv6 = {
            # Random inbound ip
            method = "auto";
            addr-gen-mode = "stable-privacy";

            # Random outbound ip
            ip6-privacy = 2;
          };
        };
      };
    };
  }
