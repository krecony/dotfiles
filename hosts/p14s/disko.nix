{ config, lib, ... }:
let
  disk = config.disko.devices.disk.system;
  opts = [
    "compress=zstd:1"
    "noatime"
  ];
in
{
  assertions = [
    {
      assertion =
        lib.hasPrefix "/dev/disk/by-id/" disk.device
        && !(lib.hasInfix "REPLACE" disk.device)
        && builtins.match ".*-part[0-9]+" disk.device == null;
      message = "Set disko.devices.disk.system.device to the verified whole NVMe disk by-id path.";
    }
    {
      assertion = !config.core.boot.diskEncryption;
      message = "The plaintext ESP layout cannot use legacy encrypted /boot support.";
    }
  ];
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = false; # enable after the first successful Secure Boot
  boot.loader.efi = {
    efiSysMountPoint = "/boot";
    canTouchEfiVariables = lib.mkDefault true;
  };

  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/REPLACE_WITH_LAPTOP_NVME_ID";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        crypt = {
          priority = 2;
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            askPassword = true;
            extraFormatArgs = [
              "--type"
              "luks2"
              "--pbkdf"
              "argon2id"
            ];
            settings = {
              allowDiscards = false; # opt in to TRIM through LUKS if desired
              crypttabExtraOpts = lib.optionals config.boot.initrd.systemd.tpm2.enable [ "tpm2-device=auto" ];
            };
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "nixos"
              ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = opts;
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = opts;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = opts;
                };
                "@var" = {
                  mountpoint = "/var";
                  mountOptions = opts;
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = opts;
                };
              };
              # Run after Disko creates the empty subvolumes, before installation.
              # Also create this when reset is disabled, so it can be enabled later.
              postCreateHook = ''
                (
                  set -eu
                  snapshot_mount=$(mktemp -d)
                  mount -o subvolid=5 /dev/mapper/cryptroot "$snapshot_mount"
                  trap 'umount "$snapshot_mount"; rmdir "$snapshot_mount"' EXIT
                  if [ ! -e "$snapshot_mount/@root-blank" ]; then
                    btrfs subvolume snapshot -r "$snapshot_mount/@root" "$snapshot_mount/@root-blank"
                  fi
                )
              '';
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
}
