{ pkgs, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  tap_if_name = "tap2";
  tap_mac_address = "00:00:00:00:00:02";
  tap_network_addr = "192.168.100.12/24";

  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 2048;

        forwardPorts = [{
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }];
      };
    };
  };

  environment.systemPackages = with pkgs; [ curl vim ];
}
