{ config, pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";

    useSystemdActivation = true;

    secrets = {
      "protonvpn/amsterdam" = { };
      "protonvpn/warsaw" = { };
      "protonvpn/berlin-sc" = { };
      "protonvpn/miami" = { };
    };
  };

  environment.systemPackages = with pkgs; [
    sops
  ];
}
