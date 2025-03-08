{ pkgs, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  tap_if_name = "tap1";
  tap_mac_address = "00:00:00:00:00:01";
  tap_network_addr = "192.168.100.11/24";

  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 512;

        forwardPorts = [{
          from = "host";
          host.port = 2221;
          guest.port = 22;
        }];
      };
    };
  };

  environment.systemPackages = with pkgs; [ openssl git kubectl ];
}
