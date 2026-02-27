{
  lib,
  config,
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
  };

  style = {
    displayServer = "headless";
    theme = "everforest";
  };

  security.nix-mineral.enable = true;
  nix-mineral.extras.misc.usbguard.enable = mkForce false;

  network.tailscale.enable = true;
}
