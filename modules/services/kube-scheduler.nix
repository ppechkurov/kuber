{ pkgs, ... }: {
  systemd.services.kube-scheduler.enable = true;
  systemd.services.kube-scheduler = {
    description = "Kubernetes Scheduler";
    documentation = [ "https://github.com/kubernetes/kubernetes" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.kubernetes}/bin/kube-scheduler \
          --config=/etc/kubernetes/config/kube-scheduler.yaml \
          --v=2
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };
}

