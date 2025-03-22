{ pkgs, user, ... }: {
  imports = [
    ../modules/base-vm.nix
    ../modules/users.nix
    ../modules/services/etcd.nix
    ../modules/services/kube-apiserver.nix
    ../modules/services/kube-controller-manager.nix
    ../modules/services/kube-scheduler.nix
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

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         192.168.100.13(rw,fsid=0,no_subtree_check) 192.168.100.14(rw,fsid=0,no_subtree_check)
    /export/nginx  192.168.100.13(rw,nohide,insecure,no_subtree_check) 192.168.100.14(rw,nohide,insecure,no_subtree_check)
  '';

  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 6443 ] # kube
    ++ [ 2049 2375 2377 7946 4789 ]; # docker

  # for docker swarm see [here](https://docs.docker.com/engine/network/drivers/overlay/#create-an-overlay-network)
  networking.firewall.allowedUDPPorts = [ 7946 4789 ]; # service discovery

  environment.systemPackages = with pkgs; [
    curl
    vim
    etcd
    kubernetes
    lazydocker
    inetutils
    dig
    nfs-utils
  ];
}
