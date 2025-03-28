{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.networking.privacy;
in
  with lib;
    mkIf cfg.enable {
      ##########################
      ## Dns
      # Enable dns local caching instead of resolvd.
      services.unbound.enable = true;

      # Set privacy respecting DNS
      networking.nameservers = lib.mkDefault [
        #Mullvad
        "194.242.2.4"
        "2a07:e340::4"
        #Quad9
        "9.9.9.9"
        "2620:fe::fe"
        "2620:fe::9"
      ];

      ##########################
      ## Firewall

      # Low level packet filtering
      # Replace legacy iptables with nftables
      networking.nftables.enable = true;

      networking.firewall = {
        enable = true;
        # libvirt DHCP compatibility
        checkReversePath = "loose";
      };

      environment.systemPackages = with pkgs; [
        # Network configuration
        dhcpcd
        macchanger
      ];
    }
