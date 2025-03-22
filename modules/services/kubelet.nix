{ pkgs, ... }: {
  systemd.services.kubelet.enable = true;
  systemd.services.kubelet = {
    path = [ pkgs.mount pkgs.iptables pkgs.cni pkgs.cni-plugins ];
    description = "Kubernetes Kubelet";
    documentation = [ "https://github.com/kubernetes/kubernetes" ];
    after = [ "containerd.service" ];
    requires = [ "containerd.service" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.kubernetes}/bin/kubelet \
          --config=/var/lib/kubelet/kubelet-config.yaml \
          --kubeconfig=/var/lib/kubelet/kubeconfig \
          --register-node=true \
          --v=2
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };
}
