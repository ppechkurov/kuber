{ pkgs, ... }: {
  # services.kubernetes = {
  #   controllerManager = {
  #     enable = true;
  #     bindAddress = "0.0.0.0";
  #     clusterCidr = "10.200.0.0/16";
  #     rootCaFile = "/var/lib/kubernetes/ca.crt";
  #     serviceAccountKeyFile = "/var/lib/kubernetes/ca.crt";
  #     verbosity = 2;
  #   };
  # };
  systemd.services.kube-controller-manager.enable = true;
  systemd.services.kube-controller-manager = {
    description = "Kubernetes Controller Manager";
    documentation = [ "https://github.com/kubernetes/kubernetes" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.kubernetes}/bin/kube-controller-manager \
          --bind-address=0.0.0.0 \
          --cluster-cidr=10.200.0.0/16 \
          --cluster-name=kubernetes \
          --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \
          --cluster-signing-key-file=/var/lib/kubernetes/ca.key \
          --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
          --root-ca-file=/var/lib/kubernetes/ca.crt \
          --service-account-private-key-file=/var/lib/kubernetes/service-accounts.key \
          --service-cluster-ip-range=10.32.0.0/24 \
          --use-service-account-credentials=true \
          --v=2
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };
}

