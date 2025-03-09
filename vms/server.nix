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

  environment.systemPackages = with pkgs; [ curl vim ];
}
