{
  description = "Homelab by Silem - 1.0v";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://cache.nixos.org/" ];
    extra-trusted-public-keys = [];
  };

  inputs = {
    # Oficial NixOS Repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Disko - NixOS module for managing disks and filesystems
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Parts - Helper library for sort Nix flakes
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, disko, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      # Define supported systems
      systems = [ "x86_64-linux" ];

      perSystem = { system, pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ git nixfmt ];
        };
      };

      flake = {
        nixosConfigurations = let
          nodes = [ "beacon-0" ];

          mkHost = name: nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = {
              meta = { hostname = name; };
            };
            
            modules = [
              disko.nixosModules.disko
              ./nixos/hosts/${name}/hardware-configuration.nix
              ./nixos/hosts/${name}/disko.nix
              ./nixos/hosts/${name}/configuration.nix
              ./nixos/modules/common.nix
            ];
          };
          in
          # For each node, create a NixOS configuration
          builtins.listToAttrs (map (name: {
            name = name;
            value = mkHost name;
          }) nodes);
        
        # Set default package to the beacon-0 NixOS configuration if the user runs `nix build` without any arguments
        defaultPackage.x86_64-linux =
          self.nixosConfigurations.beacon-0.config.system.build.toplevel;
      };
    };
}