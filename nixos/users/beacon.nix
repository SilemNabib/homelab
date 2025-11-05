{ config, pkgs, lib, meta, ... }:

{
  # Configuration for users and homes for hosts type "beacon"
  # This file defines both the system users and their home-manager configurations
  
  # SOPS secrets for the user operator
  sops.secrets.operatorPassword = {
    sopsFile = ../secrets/users-passwords.yaml;
    key = "operator";
    path = "/run/secrets/operators-passwords";
  };

  # System user
  users.users.operator = {
    isNormalUser = true;
    description = "Homelab Operator";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.operatorPassword.path;
    openssh.authorizedKeys.keyFiles = [ ../keys/beacon-admin.pub ];
  };

  # Home Manager configuration for the user operator
  home-manager.users.operator = {
    home.stateVersion = "24.05";
    home.username = "operator";
    home.homeDirectory = "/home/operator";
    
    # Programs and tools for hosts beacon
    programs = {
      git = {
        enable = true;
      };
      
      # Custom zsh for the user
      zsh = {
        enable = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          ll = "ls -la";
          gs = "git status";
          gc = "git commit";
          gp = "git push";
          k = "kubectl";
          kctx = "kubectl config get-contexts";
          kns = "kubectl config set-context --current --namespace";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "kubectl" "docker" ];
          theme = "robbyrussell";
        };
      };
      
      # Tools to work with k3s
      kubectl = {
        enable = true;
        enableBashCompletion = true;
        enableZshCompletion = true;
      };
      
      # tmux configuration
      tmux = {
        enable = true;
        clock24 = true;
        keyMode = "vi";
        prefix = "C-a";
        baseIndex = 1;
        extraConfig = ''
          set -g mouse on
          bind | split-window -h
          bind - split-window -v
        '';
      };
    };
    
    # Additional packages for the user operator in hosts beacon
    home.packages = with pkgs; [
      # Kubernetes tools
      kubectl
      k9s
      helm
      kubernetes-helm
      
      # Development tools
      vim
      neovim
      tmux
      
      # Monitoring and debugging tools
      htop
      iotop
      ncdu
      jq
      yq-go
      
      # Network tools
      curl
      wget
      nmap
      tcpdump
    ];
  };
}

