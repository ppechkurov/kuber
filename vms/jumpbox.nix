{ pkgs, ... }: {
  imports = [ ../modules/base-vm.nix ../modules/users.nix ];

  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 1;
        memorySize = 512;
      };
    };
  };

  environment.systemPackages = with pkgs; [ openssl git kubectl ];
}
