{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.storage.impermanence;
  mapper = "/dev/mapper/${config.storage.fde.name}";
  cryptsetupUnit = "systemd-cryptsetup@${utils.escapeSystemdPath config.storage.fde.name}.service";
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            config.boot.initrd.enable
            && builtins.hasAttr config.storage.fde.name config.boot.initrd.luks.devices
            &&
              lib.all
                (
                  mountpoint:
                  let
                    fs = config.fileSystems.${mountpoint} or { };
                  in
                  (fs.fsType or "") == "btrfs" && (fs.device or "") == mapper
                )
                [
                  "/"
                  "/home"
                  "/nix"
                  "/var"
                  "/persist"
                ]
            && lib.elem "subvol=@root" config.fileSystems."/".options;
          message = "storage.impermanence requires systemd initrd, the configured LUKS mapping, @root at /, and persistent Btrfs mounts.";
        }
      ];
      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/root"
          "/etc/ssh"
          "/etc/NetworkManager/system-connections"
        ];
        files = [ "/etc/machine-id" ];
      };
    })
    (lib.mkIf (cfg.enable && cfg.resetRoot) {
      # mounts /root with noexec, nodev, and nosuid
      systemd.units."root.mount".text = lib.mkForce ''
        [Unit]
        Before=local-fs.target
        DefaultDependencies=false

        [Mount]
        Options=bind,x-gvfs-hide,noexec,nodev,nosuid
        Type=none
        What=/persist/root
        Where=/root

        [Install]
        WantedBy=local-fs.target
      '';

      boot.initrd.systemd.services.reset-root = {
        description = "Restore blank Btrfs root before mounting sysroot";
        requiredBy = [ "sysroot.mount" ];
        before = [ "sysroot.mount" ];
        after = [ cryptsetupUnit ];
        requires = [ cryptsetupUnit ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [
          pkgs.btrfs-progs
          pkgs.coreutils
          pkgs.util-linux
        ];
        script = ''
          set -euo pipefail
          mkdir -p /run/root-reset
          mount -t btrfs -o subvolid=5 ${lib.escapeShellArg mapper} /run/root-reset
          trap 'umount /run/root-reset' EXIT
          cd /run/root-reset
          # Fail before changing root if the baseline is missing or writable.
          btrfs subvolume show @root-blank >/dev/null
          test "$(btrfs property get -ts @root-blank ro)" = "ro=true"
          # @root-next makes an interrupted previous attempt recoverable.
          if [ -e @root-next ]; then
            btrfs subvolume delete --recursive @root-next
          fi
          btrfs subvolume snapshot @root-blank @root-next
          if [ -e @root ]; then
            btrfs subvolume delete --recursive @root
          fi
          mv @root-next @root
          btrfs filesystem sync /run/root-reset
          cd /
        '';
      };
    })
  ];
}
