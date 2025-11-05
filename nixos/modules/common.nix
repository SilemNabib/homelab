{ config, pkgs, lib, meta, ... }:

{
  # Define the version of NixOS this configuration is meant for.
  system.stateVersion = "24.05";

  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_CO.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "la-latin1";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Install essential packages system-wide
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    htop
    curl
    wget
    tmux
    neofetch
    tree
  ];

  # Enable Zsh as the default shell and customize the prompt
  programs.zsh.enable = true;
  programs.zsh.promptInit = ''
    PROMPT="%B%F{cyan}%n@%m%f%b %~ %# "
  '';

  # OpenSSH Server Configuration
  services.openssh = {
    enable = true;
    settings = {
      # TODO: Check if it's needed to disable password authentication
      # PasswordAuthentication = false;
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  /*
  TODO: Check default firewall settings (open ports, etc)
  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 80 443 ];
  };
  */
  networking.firewall.enable = false;

  # Useful shell aliases
  environment.shellAliases = {
    ll = "ls -la";
    gs = "git status";
    gc = "git commit";
    gp = "git push";
  };
}