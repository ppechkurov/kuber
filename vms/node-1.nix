{ pkgs, user, ... }: {
  imports = [
    ../modules/base-vm.nix
    ../modules/users.nix
    ../modules/services/containerd.nix
    ../modules/services/kubelet.nix
    ../modules/services/kube-proxy.nix
  ];

  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrbYs5UgKJPx0a7f2YaIA0uSXjv13qSlIOjBM4x6B8i kuber@jumpbox"
  ];

  virtualisation = {
    docker = { enable = true; };
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 2048;
      };
    };
  };

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    curl
    vim
    runc
    containerd
    cri-tools
    kubernetes
    socat
    ipset
    cni
    cni-plugins
    lazydocker
  ];
}
