{
  config,
  lib,
  mkImports,
  ...
}:
with lib;
let
  cfg = config.security;
in
{
  options.security = {
    disableSUIDs = mkOption {
      type = types.bool;
      default = false;
      description = ''
        disables SUID on executables that can be used for privelage escalation
      '';
    };
    replaceSudoWithRun0 = mkOption {
      type = types.bool;
      default = false;
      description = ''
        disables sudo (use run0 instead)
      '';
    };
    nix-mineral.enable = mkEnableOption "enable nix mineral";
  };

  imports = mkImports [
    ./sops.nix
    ./clamav.nix
  ];

  config = {
    nix-mineral = {
      inherit (cfg.nix-mineral) enable;
      preset = "compatibility";

      filesystems.enable = false;

      extras = {
        misc = {
          usbguard = {
            enable = true;
            gnome-integration = config.style.desktopEnvironment == "gnome";
          };
          ssh-hardening = true;
        };
        system.secure-chrony = true;
      };
    };

    security = mkIf cfg.disableSUIDs {
      wrappers = mkMerge [
        {
          sudoedit.setuid = lib.mkForce false;
          sg.setuid = lib.mkForce false;
          fusermount.setuid = lib.mkForce false;
          fusermount3.setuid = lib.mkForce false;
          mount.setuid = lib.mkForce false;
          umount.setuid = lib.mkForce false;
          pkexec.setuid = lib.mkForce false;
          newgrp.setuid = lib.mkForce false;
        }
        (mkIf (!config.virtualisation.podman.enable) {
          # for rootless podman
          newgidmap.setuid = lib.mkForce false;
          newuidmap.setuid = lib.mkForce false;
        })
      ];
    };
  };
}
