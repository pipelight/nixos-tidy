{
  config,
  lib,
  utils,
}:
with lib;
with utils; let
  cfg = config.networking;
  interfaces = attrValues cfg.interfaces;
in {
  systemd.services = let
    createVswitchDevice = n: v:
      nameValuePair "${n}-netdev"
      (let
        deps = concatLists (map deviceDependency (attrNames (filterAttrs (_: config: config.type != "internal") v.interfaces)));
        internalConfigs = map (i: "network-addresses-${i}.service") (attrNames (filterAttrs (_: config: config.type == "internal") v.interfaces));
        ofRules = pkgs.writeText "vswitch-${n}-openFlowRules" v.openFlowRules;
      in {
        description = "Open vSwitch Interface ${n}";
        wantedBy = ["network-setup.service" (subsystemDevice n)] ++ internalConfigs;
        # before = [ "network-setup.service" ];
        # should work without internalConfigs dependencies because address/link configuration depends
        # on the device, which is created by ovs-vswitchd with type=internal, but it does not...
        before = ["network-setup.service"] ++ internalConfigs;
        partOf = ["network-setup.service"]; # shutdown the bridge when network is shutdown
        bindsTo = ["ovs-vswitchd.service"]; # requires ovs-vswitchd to be alive at all times
        after = ["network-pre.target" "ovs-vswitchd.service"] ++ deps; # start switch after physical interfaces and vswitch daemon
        wants = deps; # if one or more interface fails, the switch should continue to run
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        path = [pkgs.iproute2 config.virtualisation.vswitch.package];
        preStart = ''
          echo "Resetting Open vSwitch ${n}..."
          ovs-vsctl --if-exists del-br ${n} -- add-br ${n} \
                    -- set bridge ${n} protocols=${concatStringsSep "," v.supportedOpenFlowVersions}
        '';
        script = ''
          echo "Configuring Open vSwitch ${n}..."
          ovs-vsctl ${concatStrings (mapAttrsToList (name: config: " -- --may-exist add-port ${n} ${name}" + optionalString (config.vlan != null) " tag=${toString config.vlan}") v.interfaces)} \
            ${concatStrings (mapAttrsToList (name: config: optionalString (config.type != null) " -- set interface ${name} type=${config.type}") v.interfaces)} \
            ${concatMapStrings (x: " -- set-controller ${n} " + x) v.controllers} \
            ${concatMapStrings (x: " -- " + x) (splitString "\n" v.extraOvsctlCmds)}


          echo "Adding OpenFlow rules for Open vSwitch ${n}..."
          ovs-ofctl --protocols=${v.openFlowVersion} add-flows ${n} ${ofRules}
        '';
        postStop = ''
          echo "Cleaning Open vSwitch ${n}"
          echo "Shutting down internal ${n} interface"
          ip link set dev ${n} down || true
          echo "Deleting flows for ${n}"
          ovs-ofctl --protocols=${v.openFlowVersion} del-flows ${n} || true
          echo "Deleting Open vSwitch ${n}"
          ovs-vsctl --if-exists del-br ${n} || true
        '';
      });
  in
    mapAttrs' createVswitchDevice cfg.vswitches;

  options = let
    vswitchInterfaceOpts = {name, ...}: {
      options = {
        name = mkOption {
          description = "Name of the interface";
          example = "eth0";
          type = types.str;
        };

        vlan = mkOption {
          description = "Vlan tag to apply to interface";
          example = 10;
          type = types.nullOr types.int;
          default = null;
        };

        type = mkOption {
          description = "Openvswitch type to assign to interface";
          example = "internal";
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
  in {
    virtualisation.vswitch = mkIf (cfg.vswitches != {}) {enable = true;};
    networking.interfaces.vswitches = mkOption {
      default = {};
      example = {
        vs0.interfaces = {
          eth0 = {};
          lo1 = {type = "internal";};
        };
        vs1.interfaces = [
          {name = "eth2";}
          {
            name = "lo2";
            type = "internal";
          }
        ];
      };
      description = ''
        This option allows you to define Open vSwitches that connect
        physical networks together. The value of this option is an
        attribute set. Each attribute specifies a vswitch, with the
        attribute name specifying the name of the vswitch's network
        interface.
      '';

      type = with types;
        attrsOf (submodule {
          options = {
            interfaces = mkOption {
              description = "The physical network interfaces connected by the vSwitch.";
              type = with types; attrsOf (submodule vswitchInterfaceOpts);
            };

            controllers = mkOption {
              type = types.listOf types.str;
              default = [];
              example = ["ptcp:6653:[::1]"];
              description = ''
                Specify the controller targets. For the allowed options see `man 8 ovs-vsctl`.
              '';
            };

            openFlowRules = mkOption {
              type = types.lines;
              default = "";
              example = ''
                actions=normal
              '';
              description = ''
                OpenFlow rules to insert into the Open vSwitch. All `openFlowRules` are
                loaded with `ovs-ofctl` within one atomic operation.
              '';
            };

            # TODO: custom "openflow version" type, with list from existing openflow protocols
            supportedOpenFlowVersions = mkOption {
              type = types.listOf types.str;
              example = ["OpenFlow10" "OpenFlow13" "OpenFlow14"];
              default = ["OpenFlow13"];
              description = ''
                Supported versions to enable on this switch.
              '';
            };

            # TODO: use same type as elements from supportedOpenFlowVersions
            openFlowVersion = mkOption {
              type = types.str;
              default = "OpenFlow13";
              description = ''
                Version of OpenFlow protocol to use when communicating with the switch internally (e.g. with `openFlowRules`).
              '';
            };

            extraOvsctlCmds = mkOption {
              type = types.lines;
              default = "";
              example = ''
                set-fail-mode <switch_name> secure
                set Bridge <switch_name> stp_enable=true
              '';
              description = ''
                Commands to manipulate the Open vSwitch database. Every line executed with `ovs-vsctl`.
                All commands are bundled together with the operations for adding the interfaces
                into one atomic operation.
              '';
            };
          };
        });
    };
  };
}
