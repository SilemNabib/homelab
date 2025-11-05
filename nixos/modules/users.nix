{ config, pkgs, lib, meta, ... }:

let
  # Helper function to check if a file exists
  fileExists = path: builtins.pathExists path;
  
  # Determine host type from hostname (e.g., "beacon-0" -> "beacon")
  hostType = lib.head (lib.splitString "-" meta.hostname);
  
  # Paths to user configurations
  genericUserPath = ../users/${hostType}.nix;
  specificUserPath = ../users/${meta.hostname}.nix;
  defaultUserPath = ../users/default.nix;
  
  # Select user configuration: specific instance > generic type > default
  userConfig = 
    if fileExists specificUserPath then specificUserPath
    else if fileExists genericUserPath then genericUserPath
    else defaultUserPath;
in

{
  # Module for users and homes
  # This module automatically detects the user configuration by host type or instance
  # and loads it automatically
  
  imports = [ userConfig ];
}

