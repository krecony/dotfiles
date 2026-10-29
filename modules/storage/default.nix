{
  config,
  lib,
  mkImports,
  ...
}:
let
  cfg = config.storage;
  inherit (lib) mkEnableOption mkOption types;
  inherit (lib.custom) mkEnableByDefaultOption;

  partitionOptions = name: priority: {
    name = mkOption {
      type = types.str;
      default = name;
      description = "Disko partition name. Keep existing names when adopting an installed layout.";
    };
    label = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Existing GPT label, or null to use Disko's generated label.";
    };
    priority = mkOption {
      type = types.int;
      default = priority;
      description = "Partition creation order; smaller values come first.";
    };
  };
in
{
  imports = mkImports [
    ./disko.nix
    ./fde.nix
    ./impermanence.nix
  ];

  options.storage = {
    enable = mkEnableOption "the shared single-disk GPT/Btrfs layout";
    device = mkOption {
      type = types.str;
      default = "";
      description = "Runtime disk path, preferably /dev/disk/by-id/...; declaring it does not run Disko.";
    };
    diskName = mkOption {
      type = types.str;
      default = "system";
      description = "Disko disk name; retain existing names to preserve generated partition labels.";
    };
    espSize = mkOption {
      type = types.str;
      default = "2G";
      description = "EFI partition size for Disko provisioning.";
    };
    espMountOptions = mkOption {
      type = types.listOf types.str;
      default = [ "umask=0077" ];
      description = "Mount options for the unencrypted EFI partition.";
    };
    swapSize = mkOption {
      type = types.str;
      default = "16G";
      description = "Disko swapfile size; changing it does not resize an existing file.";
    };
    swapPriority = mkOption {
      type = types.nullOr types.int;
      default = 10;
      description = "Disk swap priority, or null for the kernel default.";
    };
    hardenMounts = mkEnableByDefaultOption "Apply nodev/nosuid to writable data mounts and restrict the ESP and /tmp.";
    partitions = {
      esp = mkOption {
        type = types.submodule { options = partitionOptions "ESP" 1; };
        default = { };
        description = "EFI partition identity and ordering.";
      };
      data = mkOption {
        type = types.submodule { options = partitionOptions "crypt" 2; };
        default = { };
        description = "Data partition identity and ordering.";
      };
    };
    btrfs = {
      varLayout = mkOption {
        type = types.enum [
          "separate"
          "logs"
        ];
        default = "separate";
        description = "Persist all of /var in @var, or only /var/log in @log.";
      };
      mountOptions = mkOption {
        type = types.listOf types.str;
        default = [
          "compress=zstd:1"
          "noatime"
        ];
        description = "Common Btrfs data-subvolume mount options.";
      };
      swapMountOptions = mkOption {
        type = types.listOf types.str;
        default = [ "noatime" ];
        description = "Mount options for @swap; Disko creates a Btrfs-compatible swapfile.";
      };
      extraFormatArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional mkfs.btrfs arguments, after the nixos filesystem label.";
      };
    };
    fde = {
      enable = mkEnableByDefaultOption "LUKS encryption of the data partition";
      encryptBoot = mkEnableOption "placing /boot inside LUKS for GRUB; the ESP remains unencrypted";
      name = mkOption {
        type = types.str;
        default = "cryptroot";
        description = "Name of the unlocked LUKS mapping.";
      };
      allowDiscards = mkEnableOption "passing discards through LUKS (exposes allocation patterns)";
      bypassWorkqueues = mkEnableOption "bypassing the dm-crypt workqueues";
      extraFormatArgs = mkOption {
        type = types.listOf types.str;
        default = [
          "--type"
          "luks2"
          "--pbkdf"
          "argon2id"
        ];
        description = "LUKS formatting arguments for provisioning; retain legacy GRUB settings when migrating configuration.";
      };
      tpm2 = {
        enable = mkEnableOption "unlocking with an already-enrolled TPM2 token; does not enroll or replace tokens";
        measurePcr15 = mkEnableOption "requesting the unlocked-volume measurement into PCR 15";
      };
    };
    impermanence = {
      enable = mkEnableOption "persisting host identity on the shared disposable-root layout";
      resetRoot = mkEnableOption "replacing @root with a blank snapshot on each boot";
    };
  };

  config.assertions = [
    {
      assertion = !cfg.enable || lib.hasPrefix "/dev/" cfg.device;
      message = "storage.device must be an absolute /dev/... disk path.";
    }
    {
      assertion = !cfg.enable || cfg.partitions.esp.name != cfg.partitions.data.name;
      message = "storage partition names must be distinct.";
    }
    {
      assertion =
        !cfg.enable || !cfg.fde.encryptBoot || (cfg.fde.enable && config.core.boot.bootloader == "grub");
      message = "storage.fde.encryptBoot requires FDE and the GRUB bootloader.";
    }
    {
      assertion = !cfg.enable || !cfg.fde.tpm2.enable || (cfg.fde.enable && config.boot.initrd.enable);
      message = "storage.fde.tpm2.enable requires FDE and an enabled initrd.";
    }
    {
      assertion = !cfg.enable || !cfg.fde.tpm2.measurePcr15 || cfg.fde.tpm2.enable;
      message = "storage.fde.tpm2.measurePcr15 requires TPM2 unlocking support.";
    }
    {
      assertion =
        !cfg.impermanence.enable || (cfg.enable && cfg.fde.enable && cfg.btrfs.varLayout == "separate");
      message = "storage.impermanence requires the enabled encrypted layout with a separate /var subvolume.";
    }
    {
      assertion = !cfg.impermanence.resetRoot || cfg.impermanence.enable;
      message = "storage.impermanence.resetRoot requires persistence to be enabled.";
    }
  ];
}
