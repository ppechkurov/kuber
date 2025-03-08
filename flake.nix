{
  description = "Kubernetes the hard way flake";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; {
        # Development environment output
        devShells.default = mkShell {
          # The Nix packages provided in the environment
          packages = [ direnv minikube kubectl k9s ];
        };
      });
}
