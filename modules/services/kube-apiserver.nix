{
  services.kubernetes = {
    masterAddress = "server.kubernetes.local";
    apiserver = {
      enable = true;
      advertiseAddress = "192.168.100.12";
      allowPrivileged = true;
      clientCaFile = "/var/lib/kubernetes/ca.crt";
      serviceAccountKeyFile = "/var/lib/kubernetes/service-accounts.crt";
      serviceAccountSigningKeyFile = "/var/lib/kubernetes/service-accounts.key";
    };
  };
}
