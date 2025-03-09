{ lib, hostname, hostconfig, hosts, user, pkgs, config, ... }: {
  options = with lib; {
    tap_if_name = mkOption {
      type = types.str;
      description =
        "Every tap device on the host can only be connected to one vm.";
    };
    tap_bridge_name = mkOption {
      type = types.str;
      description = "I dont know if this is needed.";
      default = "br0";
    };
    tap_mac_address = mkOption {
      type = types.str;
      description = "I guess that every vm needs a unique MAC address.";
    };
    tap_network_addr = mkOption {
      type = types.str;
      description = "Every vm needs a unique IP address.";
    };
  };

  imports = [ ../modules/users.nix ];

  config = with hostconfig; {
    networking.hostName = hostname;
    networking.domain = "kubernetes.local";
    networking.enableIPv6 = false;

    tap_network_addr = "${ip}/24";
    inherit tap_if_name tap_mac_address;

    services.getty.autologinUser = user;
    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [ curl vim ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    services.openssh.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.networkmanager.enable = false;
    networking.useDHCP = false;

    networking.hosts = let
      nameValuePair = lib.attrsets.nameValuePair;
      mapConfig = hostname: cfg:
        let
          ip = cfg.ip;
          domain = config.networking.domain;
        in nameValuePair "${ip}" [ "${hostname}.${domain}" "${hostname}" ];
    in lib.attrsets.mapAttrs' mapConfig hosts;

    systemd.network = {
      enable = true;
      networks."30-ethernet-dummy" = {
        enable = true;
        matchConfig.MACAddress = config.tap_mac_address;
        linkConfig = {
          # or "routable" with IP addresses configured
          ActivationPolicy = "always-up";
          RequiredForOnline = "yes";
        };
        networkConfig = { Address = [ config.tap_network_addr ]; };
      };
    };

    virtualisation.vmVariant = {
      virtualisation = {
        qemu = {
          networkingOptions = [
            "-netdev tap,id=nd0,ifname=${config.tap_if_name},script=no,downscript=no,br=${config.tap_bridge_name}"
            "-device virtio-net-pci,netdev=nd0,mac=${config.tap_mac_address}"
          ];
        };
      };
    };

    system.stateVersion = "24.11";
  };
}
