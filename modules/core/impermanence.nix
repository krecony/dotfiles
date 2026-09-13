{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.core.impermanence;
in
{
  options.core.impermanence = {
    enable = lib.mkEnableOption "persist host identity on a disposable Btrfs root";
    resetRoot = lib.mkEnableOption "replace @root with a blank snapshot on each boot";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.resetRoot || cfg.enable;
          message = "Resetting root requires persistence to be enabled.";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            config.boot.initrd.systemd.enable
            && builtins.hasAttr "cryptroot" config.boot.initrd.luks.devices
            &&
              lib.all
                (
                  mountpoint:
                  let
                    fs = config.fileSystems.${mountpoint} or { };
                  in
                  (fs.fsType or "") == "btrfs" && (fs.device or "") == "/dev/mapper/cryptroot"
                )
                [
                  "/"
                  "/home"
                  "/nix"
                  "/var"
                  "/persist"
                ]
            && lib.elem "subvol=@root" config.fileSystems."/".options;
          message = "This reset profile requires systemd initrd, cryptroot, @root mounted at /, and persistent Btrfs mounts defined by the host Disko layout.";
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
      boot.initrd.systemd.services.reset-root = {
        description = "Restore blank Btrfs root before mounting sysroot";
        requiredBy = [ "sysroot.mount" ];
        before = [ "sysroot.mount" ];
        after = [ "systemd-cryptsetup@cryptroot.service" ];
        requires = [ "systemd-cryptsetup@cryptroot.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        path = [
          pkgs.btrfs-progs
          pkgs.coreutils
          pkgs.util-linux
        ];
        script = ''
          set -euo pipefail
          mkdir -p /run/root-reset
          mount -t btrfs -o subvolid=5 /dev/mapper/cryptroot /run/root-reset
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
