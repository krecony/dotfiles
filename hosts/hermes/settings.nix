{
  lib,
  config,
  ...
}:
with lib;
{
  core = {
    user = "pi";
    flakePath = "/home/pi/dotfiles";
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

  users.users.${config.core.user}.initialHashedPassword =
    lib.mkForce "$y$j9T$LNwI1pBYkqt/2GlSfVGNd0$vSOxb4cWF6OMWl/lOSHshHWQQdaVjW5LxSAEQJfgZ.C";

  style = {
    displayServer = "headless";
    theme = "everforest";
  };
}
