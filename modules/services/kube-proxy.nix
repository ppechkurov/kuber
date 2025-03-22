{ pkgs, ... }: {
  systemd.services.kube-proxy.enable = true;
  systemd.services.kube-proxy = {
    path = [ pkgs.nftables pkgs.iptables ];
    description = "Kubernetes Kube Proxy";
    documentation = [ "https://github.com/kubernetes/kubernetes" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.kubernetes}/bin/kube-proxy \
          --config=/var/lib/kube-proxy/kube-proxy-config.yaml
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };
}
