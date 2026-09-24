{
  config,
  lib,
  mkImports,
  inputs,
  ...
}:
with lib;
let
  cfg = config.hardening;
in
{
  options.hardening = {
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
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  config = {
    nix-mineral = {
      inherit (cfg.nix-mineral) enable;
      preset = "compatibility";

      filesystems.enable = false;

      extras = {
        misc.ssh-hardening = true;
        system.secure-chrony = true;
      };
    };

    services.usbguard = {
      enable = true;
      implicitPolicyTarget = "block"; # block devices that don't match policy
      presentDevicePolicy = "apply-policy"; # apply policy to devices present before start of daemon
      insertedDevicePolicy = "apply-policy"; # apply policy to devices conncted after start of daemon
      presentControllerPolicy = "keep"; # keep usb controllers present before start of daemon
      dbus.enable = true;
      IPCAllowedUsers = [ "root" ];
      IPCAllowedGroups = [ ];
    };

    services.jitterentropy-rngd.enable = mkForce false;

    security = {
      wrappers = mkIf cfg.disableSUIDs (mkMerge [
        {
          sudoedit.setuid = lib.mkForce false;
          sg.setuid = lib.mkForce false;
          mount.setuid = lib.mkForce false;
          umount.setuid = lib.mkForce false;
          pkexec.setuid = lib.mkForce false;
          newgrp.setuid = lib.mkForce false;
        }
        (mkIf config.programs.fuse.enable {
          # these wrappers only exist (with a source) when fuse is enabled,
          # so only override their setuid bit then to avoid a sourceless wrapper
          fusermount.setuid = lib.mkForce false;
          fusermount3.setuid = lib.mkForce false;
        })
        (mkIf (!config.virtualisation.podman.enable) {
          # for rootless podman
          newgidmap.setuid = lib.mkForce false;
          newuidmap.setuid = lib.mkForce false;
        })
      ]);
    };
  };
}
