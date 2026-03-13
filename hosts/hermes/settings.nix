{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  core = {
    user = "hermes";
    flakePath = "/home/hermes/dotfiles";
    capabilities = [
      "basic"
      "server"
    ];

    intel.enable = false;
  };

  boot.loader = {
    grub.enable = mkForce false;
    systemd-boot.enable = mkForce false;
    generic-extlinux-compatible.enable = mkForce true;
  };

  users.users.${config.core.user} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID289L4Tnf7hkSj81IbYqfzldWV9vs09gYe4lxP7w7eD github.driven504@passinbox.com"
    ];
    initialHashedPassword = lib.mkForce "$y$j9T$LNwI1pBYkqt/2GlSfVGNd0$vSOxb4cWF6OMWl/lOSHshHWQQdaVjW5LxSAEQJfgZ.C";
    linger = true;
  };

  systemd.user.services.house-scraper = {
    description = "House scraper container";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm -f house-scraper";
      ExecStart = "${pkgs.podman}/bin/podman run --name house-scraper --replace --env-file /home/hermes/house/.env localhost/house-scraper:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop -t 30 house-scraper";
      ExecStopPost = "-${pkgs.podman}/bin/podman rm -f house-scraper";
    };
  };

  style = {
    displayServer = "headless";
    theme = "everforest";
  };

  security = {
    sops.enable = false;
    disableSUIDs = true;
  };

  network.tailscale.enable = true;
}
