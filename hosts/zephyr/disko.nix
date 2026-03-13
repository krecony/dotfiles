let
  opts = [
    "ssd"
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk = {
    nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            name = "esp";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/efi";
            };
          };
          luks = {
            size = "100%";
            label = "luks";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "@boot" = {
                    mountpoint = "/boot";
                    mountOptions = [
                      "ssd"
                      "compress=no"
                    ];
                  };
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
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = opts;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = opts;
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "compress=no"
                      "noatime"
                      "nodatacow"
                    ];
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
