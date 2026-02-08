{ config, pkgs, ... }:
{
  sops = {
    defaultSopsFile = "${config.core.flakePath}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  };

  environment.systemPackages = with pkgs; [
    sops
  ];
}
