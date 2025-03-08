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

        vms = let
          vm = hostname: user:
            (nixpkgs.lib.nixosSystem {
              modules = [ ./vms/${hostname}.nix ];
              specialArgs = { inherit hostname user; };
            }).config.system.build.vm;
        in {
          jumpbox = vm "jumpbox" "kuber";
          server = vm "server" "kuber";
        };
      });
}
