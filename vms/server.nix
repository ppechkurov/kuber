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
      };
    };
  };

  # etcd
  systemd.services.etcd = {
    enable = true;
    description = "etcd";
    documentation = [ "https://github.com/etcd-io/etcd" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = ''
        ${pkgs.etcd}/bin/etcd \
          --name controller \
          --initial-advertise-peer-urls http://127.0.0.1:2380 \
          --listen-peer-urls http://127.0.0.1:2380 \
          --listen-client-urls http://127.0.0.1:2379 \
          --advertise-client-urls http://127.0.0.1:2379 \
          --initial-cluster-token etcd-cluster-0 \
          --initial-cluster controller=http://127.0.0.1:2380 \
          --initial-cluster-state new \
          --data-dir=/var/lib/etcd
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = with pkgs; [ curl vim etcd kubernetes ];
}
