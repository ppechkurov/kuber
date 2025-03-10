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
      let
        pkgs = import nixpkgs { inherit system; };
        run_kluster = pkgs.writeScriptBin "run_kluster" # bash
          ''
            #!/usr/bin/env bash
            QEMU_KERNEL_PARAMS="console=ttyS0";
            QEMU_OPTS="-nographic -serial mon:stdio";

            nix run .#vms.x86_64-linux.jumpbox &
            nix run .#vms.x86_64-linux.server &
            nix run .#vms.x86_64-linux.node-0 &
            nix run .#vms.x86_64-linux.node-1 &
          '';
      in with pkgs; {
        devShells.default = mkShell {
          QEMU_KERNEL_PARAMS = "console=ttyS0";
          QEMU_OPTS = "-nographic -serial mon:stdio";
          packages = [ direnv minikube kubectl k9s run_kluster ];
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
