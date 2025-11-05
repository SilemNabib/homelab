{
  description = "Homelab by Silem - 2.0v";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://cache.nixos.org/" ];
    extra-trusted-public-keys = [];
  };

  inputs = {
    # Lib: Oficial NixOS Repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Lib: Disko - NixOS module for managing disks and filesystems
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lib: Flake Parts - Helper library for sort Nix flakes
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Lib: SOPS Nix - Nix integration for Mozilla SOPS (Secrets OPerationS)
    sops-nix.url = "github:Mic92/sops-nix";

    # Lib: Home Manager - Manage a user environment using Nix
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, disko, flake-parts, sops-nix, home-manager, ... }:
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
          # Define all host instances by type
          # Each host type (e.g., "beacon", "nas") maps to a list of instance names
          hosts = {
            beacon = [ "beacon-0" ];
            # nas = [ "nas-0" "nas-1" ];
          };

          # Helper function to check if a file exists
          fileExists = path: builtins.pathExists path;

          # hostType: the type of host (e.g., "beacon", "nas") - this is the key from the hosts dict
          # name: the instance name (e.g., "beacon-0", "nas-1")
          mkHost = hostType: name: let
            genericHardwarePath = ./nixos/hosts/${hostType}/hardware/${hostType}.nix;
            specificHardwarePath = ./nixos/hosts/${hostType}/hardware/${name}.nix;
            hardwareModule =
              if fileExists specificHardwarePath then specificHardwarePath 
              else if fileExists genericHardwarePath then genericHardwarePath
              else null;
            system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = {
              meta = { hostname = name; };
            };
            
            modules = [
              disko.nixosModules.disko
              sops-nix.nixosModule.sops
              home-manager.nixosModules.home-manager
              ./nixos/hosts/${hostType}/disko.nix
              ./nixos/hosts/${hostType}/configuration.nix
              ./nixos/modules/common.nix
            ] ++ nixpkgs.lib.optional (hardwareModule != null) hardwareModule;
          };
          in
          # For each host type and each instance, create a NixOS configuration
          builtins.listToAttrs (
            builtins.concatMap
              (hostType:
                map (name: {
                  name = name;
                  value = mkHost hostType name;
                }) hosts.${hostType}
              )
              (builtins.attrNames hosts)
          );
        
        # Set default package to the first instance NixOS configuration 
        # if the user runs `nix build` without any arguments
        defaultPackage.x86_64-linux =
          let
            firstType = builtins.head (builtins.attrNames hosts);
            firstInstance = builtins.head (hosts.${firstType});
          in
            self.nixosConfigurations.${firstInstance}.config.system.build.toplevel;
      };
    };
}