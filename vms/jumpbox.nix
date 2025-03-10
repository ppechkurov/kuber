{ pkgs, lib, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 512;

        qemu = {
          networkingOptions = [
            "-netdev tap,id=nd0,ifname=tap1,script=no,downscript=no,br=br0"
            "-device virtio-net-pci,netdev=nd0,mac=52:54:98:76:54:02"
          ];
        };
      };
    };
  };

  networking.firewall.enable = false;
  # networking.networkmanager.enable = false;
  networking.useDHCP = true;

  networking.interfaces.eth1.ipv4.addresses = [{
    address = "192.168.100.10";
    prefixLength = 24;
  }];

  # networking.defaultGateway = {
  #   address = "192.168.100.1";
  #   interface = "eth1";
  # };

  networking.nameservers = [ "192.168.100.1" "8.8.8.8" ];

  networking.useNetworkd = true;

  # systemd.network = {
  #   enable = true;
  #   networks."30-eth0" = {
  #     enable = true;
  #     matchConfig.MACAddress = "52:54:98:76:54:02";
  #     linkConfig = {
  #       # or "routable" with IP addresses configured
  #       ActivationPolicy = "always-up";
  #       RequiredForOnline = "yes";
  #     };
  #     networkConfig = { Address = [ "192.168.100.10/24" ]; };
  #   };
  # };

  environment.systemPackages = with pkgs; [ openssl git kubectl ];
}
