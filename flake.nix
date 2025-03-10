{
  description = "Kubernetes the hard way flake";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; {
        devShells.default = mkShell {
          QEMU_KERNEL_PARAMS = "console=ttyS0";
          QEMU_OPTS = "-nographic -serial mon:stdio";
          packages = [ direnv minikube kubectl k9s ];
        };
        vm1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              networking.hostName = "vm1";
              networking.useDHCP = true; # Use DHCP on the virtual network
              networking.interfaces.eth0.useDHCP = true;

              # Enable SSH for easy access
              services.openssh.enable = true;

              # Add a user for testing
              users.users.test = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                password = "test";
              };
            })
          ];
        };
        vm2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              networking.hostName = "vm2";
              networking.useDHCP = true; # Use DHCP on the virtual network
              networking.interfaces.eth0.useDHCP = true;

              # Enable SSH for easy access
              services.openssh.enable = true;

              # Add a user for testing
              users.users.test = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                password = "test";
              };
            })
          ];
        };
        vms = let
          user = "kuber";
          network = "192.168.100";
          hosts = let
            declareHost = i: {
              ip = "${network}.1${i}";
              tap_if_name = "tap${i}";
              tap_mac_address = "52:54:00:00:00:0${i}";
            };
          in {
            jumpbox = declareHost "1";
            server = declareHost "2";
            node-0 = declareHost "3";
            node-1 = declareHost "4";
          };
          vm = hostname: hostconfig:
            (nixpkgs.lib.nixosSystem {
              modules = [ ./vms/${hostname}.nix ];
              specialArgs = { inherit hostname hostconfig user hosts; };
            }).config.system.build.vm;
        in builtins.mapAttrs vm hosts;
      });
}
