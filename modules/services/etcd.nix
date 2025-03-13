{
  services.etcd = {
    enable = true;
    name = "controller";
    initialAdvertisePeerUrls = [ "http://127.0.0.1:2380" ];
    listenPeerUrls = [ "http://127.0.0.1:2380" ];
    listenClientUrls = [ "http://127.0.0.1:2379" ];
    advertiseClientUrls = [ "http://127.0.0.1:2379" ];
    initialClusterToken = "etcd-cluster-0";
    initialCluster = [ "controller=http://127.0.0.1:2380" ];
    initialClusterState = "new";
    dataDir = "/var/lib/etcd";
  };
}
