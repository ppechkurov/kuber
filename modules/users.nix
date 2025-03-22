{ user, ... }: {
  users.users = {
    root = { initialPassword = "root"; };

    ${user} = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "kubernetes" "docker" ]; # Enable ‘sudo’ for the user.
      initialPassword = "${user}";
    };
  };
}
