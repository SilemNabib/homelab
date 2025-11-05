{ config, lib, pkgs, meta, ... }:

let
  clusterServer = "beacon-0";
in
{
  # Configuration for k3s
  # This module can be enabled/disabled by host type or instance
  sops.secrets.k3s-token = {
    sopsFile = ../secrets/k3s-token.yaml;
    key = "token";
    path = "/run/secrets/k3s-token";
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s-token.path;
    extraFlags = toString ([
      "--write-kubeconfig-mode \"0644\""
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ] ++ (if meta.hostname == clusterServer then [] else [
      "--server https://${clusterServer}:6443"
    ]));
    clusterInit = (meta.hostname == clusterServer);
  };

  # Packages related to k3s
  environment.systemPackages = with pkgs; [
    k3s
  ];
}

