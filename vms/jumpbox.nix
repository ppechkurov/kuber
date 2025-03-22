{ pkgs, user, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/8sFXfWRrIE+n4TtvawXjd1QKIYadM2OR9PGOxHKrP petrp@home"
  ];

  virtualisation = {
    docker = { enable = true; };
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 512;
        forwardPorts = [{
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    openssl
    git
    kubectl
    envsubst
    lazydocker
    inetutils
    dig
  ];
}
