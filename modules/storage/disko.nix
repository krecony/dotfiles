{ config, lib, ... }:
let
  cfg = config.storage;
  espMountPoint = if cfg.fde.encryptBoot then "/efi" else "/boot";
  varMountPoint = if cfg.btrfs.varLayout == "separate" then "/var" else "/var/log";
  varSubvolume = if cfg.btrfs.varLayout == "separate" then "@var" else "@log";
  dataSubvolume = mountpoint: {
    inherit mountpoint;
    inherit (cfg.btrfs) mountOptions;
  };
  btrfs = {
    type = "btrfs";
    extraArgs = [
      "-L"
      "nixos"
    ]
    ++ cfg.btrfs.extraFormatArgs;
    subvolumes = {
      "@root" = dataSubvolume "/";
      "@home" = dataSubvolume "/home";
      "@nix" = dataSubvolume "/nix";
      "@persist" = dataSubvolume "/persist";
      ${varSubvolume} = dataSubvolume varMountPoint;
      "@swap" = {
        mountpoint = "/swap";
        mountOptions = cfg.btrfs.swapMountOptions;
        swap.swapfile = {
          size = cfg.swapSize;
          priority = cfg.swapPriority;
        };
      };
      "@boot" = lib.mkIf cfg.fde.encryptBoot {
        mountpoint = "/boot";
        mountOptions = [
          "ssd"
          "compress=no"
        ];
      };
    };
    # Create the baseline during provisioning even if resetRoot is disabled.
    postCreateHook = lib.mkIf cfg.impermanence.enable ''
      (
        set -eu
        snapshot_mount=$(mktemp -d)
        mount -o subvolid=5 ${lib.escapeShellArg "/dev/mapper/${cfg.fde.name}"} "$snapshot_mount"
        trap 'umount "$snapshot_mount"; rmdir "$snapshot_mount"' EXIT
        if [ ! -e "$snapshot_mount/@root-blank" ]; then
          btrfs subvolume snapshot -r "$snapshot_mount/@root" "$snapshot_mount/@root-blank"
        fi
      )
    '';
  };
  dataContent =
    if cfg.fde.enable then
      {
        type = "luks";
        inherit (cfg.fde) name extraFormatArgs;
        askPassword = true;
        settings = {
          inherit (cfg.fde) allowDiscards bypassWorkqueues;
          crypttabExtraOpts = lib.mkIf cfg.fde.tpm2.enable (
            [ "tpm2-device=auto" ] ++ lib.optional cfg.fde.tpm2.measurePcr15 "tpm2-measure-pcr=yes"
          );
        };
        content = btrfs;
      }
    else
      btrfs;
in
{
  config = lib.mkIf cfg.enable {
    boot.loader.efi.efiSysMountPoint = espMountPoint;

    disko.devices.disk.${cfg.diskName} = {
      type = "disk";
      inherit (cfg) device;
      content = {
        type = "gpt";
        partitions = {
          ${cfg.partitions.esp.name} = {
            inherit (cfg.partitions.esp) priority;
            label = lib.mkIf (cfg.partitions.esp.label != null) cfg.partitions.esp.label;
            size = cfg.espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = espMountPoint;
              mountOptions = cfg.espMountOptions;
            };
          };
          ${cfg.partitions.data.name} = {
            inherit (cfg.partitions.data) priority;
            label = lib.mkIf (cfg.partitions.data.label != null) cfg.partitions.data.label;
            size = "100%";
            content = dataContent;
          };
        };
      };
    };

    fileSystems = lib.mkMerge [
      (lib.custom.genAttrsSame
        (
          if cfg.btrfs.varLayout == "separate" then
            [
              "/persist"
              "/var"
              "/home"
              "/nix"
            ]
          else
            [
              "/persist"
              "/var/log"
            ]
        )
        {
          neededForBoot = true;
        }
      )
      (lib.mkIf cfg.hardenMounts (
        lib.mkMerge [
          (lib.custom.genAttrsSame [ varMountPoint "/persist" "/swap" "/home" ] {
            options = lib.mkAfter [
              "nodev"
              "nosuid"
            ];
          })
          {
            ${espMountPoint}.options = lib.mkAfter [
              "noexec"
              "nodev"
              "nosuid"
            ];
            "/tmp" = {
              device = "/tmp";
              fsType = "none";
              options = [
                "bind"
                "nodev"
                "nosuid"
              ];
            };
          }
        ]
      ))
    ];
  };
}
