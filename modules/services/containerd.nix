{ pkgs, ... }: {
  systemd.services.containerd.enable = true;
  systemd.services.containerd = {
    path = [ pkgs.iptables pkgs.runc ];
    description = "containerd container runtime";
    documentation = [ "https://containerd.io" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStartPre = "/run/current-system/sw/bin/modprobe overlay";
      ExecStart = "${pkgs.containerd}/bin/containerd";
      Restart = "always";
      RestartSec = 5;
      Deletage = "yes";
      KillMode = "process";
      OOMScoreAdjust = -999;
      LimitNOFILE = 1048576;
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
