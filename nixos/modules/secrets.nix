{ config, pkgs, lib, meta, ... }:

{
  # Base configuration for SOPS for secrets
  # This module can be extended by host type or instance
  
  sops = {
    defaultSopsFile = ../secrets/general-secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}

