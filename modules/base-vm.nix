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

  config = let prefixLength = 24;
  in with hostconfig; {
    nixpkgs.hostPlatform = "x86_64-linux";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking = {
      hostName = hostname;
      domain = "kubernetes.local";
      enableIPv6 = false; # no fqdn without this
      firewall.allowedTCPPorts = [ 22 ];
      useNetworkd = true;
      useDHCP = true;

      nameservers = [ "192.168.100.1" "8.8.8.8" ];

      interfaces.eth1.ipv4 = {
        addresses = [{
          address = ip;
          prefixLength = 24;
        }];
      };

      # generate /etc/hosts
      hosts = let
        nameValuePair = lib.attrsets.nameValuePair;
        mapConfig = hostname: cfg:
          let
            ip = cfg.ip;
            domain = config.networking.domain;
          in nameValuePair "${ip}" [ "${hostname}.${domain}" "${hostname}" ];
      in lib.attrsets.mapAttrs' mapConfig hosts;
    };

    tap_network_addr = "${ip}/${toString prefixLength}";
    inherit tap_if_name tap_mac_address;

    services.openssh.enable = true;

    services.getty.autologinUser = user;
    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [ curl vim ];

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
