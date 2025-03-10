{ pkgs, user, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrbYs5UgKJPx0a7f2YaIA0uSXjv13qSlIOjBM4x6B8i kuber@jumpbox"
  ];

  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 2048;

        qemu = {
          networkingOptions = [
            "-netdev tap,id=nd0,ifname=tap2,script=no,downscript=no,br=br0"
            "-device virtio-net-pci,netdev=nd0,mac=52:54:98:76:54:03"
          ];
        };
      };
    };
  };

  networking.firewall.enable = false;
  # networking.networkmanager.enable = false;
  networking.useDHCP = true;

  networking.interfaces.eth1.ipv4 = {
    addresses = [{
      address = "192.168.100.11";
      prefixLength = 24;
    }];
  };

  networking.nameservers = [ "192.168.100.1" "8.8.8.8" ];

  networking.useNetworkd = true;
  environment.systemPackages = with pkgs; [ curl vim ];
}
