{ pkgs, ... }: {
  # services.kubernetes = {
  #   # roles = [ "master" "node" ];
  #   masterAddress = "server.kubernetes.local";
  #   # apiserverAddress = "https://server.kubernetes.local:6443";
  #   apiserver = {
  #     enable = true;
  #     advertiseAddress = "192.168.100.12";
  #     allowPrivileged = true;
  #     clientCaFile = "/var/lib/kubernetes/ca.crt";
  #     etcd.servers = [ "http://127.0.0.1:2379" ];
  #     serviceAccountKeyFile = "/var/lib/kubernetes/service-accounts.crt";
  #     serviceAccountSigningKeyFile = "/var/lib/kubernetes/service-accounts.key";
  #     serviceAccountIssuer = "https://server.kubernetes.local:6443";
  #     serviceClusterIpRange = "10.32.0.0/24";
  #     tlsCertFile = "/var/lib/kubernetes/kube-api-server.crt";
  #     tlsKeyFile = "/var/lib/kubernetes/kube-api-server.key";
  #     verbosity = 2;
  #   };
  # };

  systemd.services.kube-apiserver.enable = true;
  systemd.services.kube-apiserver = {
    description = "Kubernetes API Server";
    documentation = [ "https://github.com/kubernetes/kubernetes" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.kubernetes}/bin/kube-apiserver \
          --allow-privileged=true \
          --apiserver-count=1 \
          --audit-log-maxage=30 \
          --audit-log-maxbackup=3 \
          --audit-log-maxsize=100 \
          --audit-log-path=/var/log/audit.log \
          --authorization-mode=Node,RBAC \
          --bind-address=0.0.0.0 \
          --client-ca-file=/var/lib/kubernetes/ca.crt \
          --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
          --etcd-servers=http://127.0.0.1:2379 \
          --event-ttl=1h \
          --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
          --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \
          --kubelet-client-certificate=/var/lib/kubernetes/kube-api-server.crt \
          --kubelet-client-key=/var/lib/kubernetes/kube-api-server.key \
          --runtime-config='api/all=true' \
          --service-account-key-file=/var/lib/kubernetes/service-accounts.crt \
          --service-account-signing-key-file=/var/lib/kubernetes/service-accounts.key \
          --service-account-issuer=https://server.kubernetes.local:6443 \
          --service-cluster-ip-range=10.32.0.0/24 \
          --service-node-port-range=30000-32767 \
          --tls-cert-file=/var/lib/kubernetes/kube-api-server.crt \
          --tls-private-key-file=/var/lib/kubernetes/kube-api-server.key \
          --v=2
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
