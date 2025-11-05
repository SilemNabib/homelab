{ config, pkgs, lib, meta, ... }:

{
  # Base configuration for Home Manager
  # The specific user and home configurations are loaded from nixos/users/
  # through the users.nix module
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit meta;
    };
  };
}

