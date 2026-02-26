{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.core.boot;
  grubModules = [
    "part_gpt"
    "part_msdos"
    "fat"
    "btrfs"
    "cryptodisk"
    "luks"
    "pbkdf2"
    "gcry_sha256"
    "gcry_sha512"
    "normal"
    "configfile"
    "linux"
    "efi_gop"
    "efi_uga"
    "gfxterm"
    "gfxterm_background"
    "gettext"
  ];
  moduleString = concatStringsSep " " grubModules;
in
{
  options.core.boot = {
    diskEncryption = mkEnableOption "encrypts the disk and makes UEFI encrypt it";
    quietBoot = mkEnableOption "adds kernelParams that reduce logging to the screen";
  };

  config = mkMerge [
    {
      boot = {
        loader = {
          systemd-boot = {
            enable = mkDefault true;
            consoleMode = mkDefault "auto";
          };
          grub.enable = mkDefault false;
        };
      };
    }
    (mkIf cfg.diskEncryption {
      boot = {
        loader = {
          grub = {
            enable = mkForce true;
            device = mkForce "nodev";
            efiSupport = mkForce true;
            enableCryptodisk = mkForce true;
            extraGrubInstallArgs = mkForce [ "--modules=${moduleString}" ];
          };
          systemd-boot.enable = mkForce false;
          efi = {
            canTouchEfiVariables = mkForce true;
            efiSysMountPoint = mkDefault "/efi";
          };
        };
        initrd.systemd = {
          enable = mkDefault true;
          tpm2.enable = mkDefault true;
        };
      };
    })
    (mkIf cfg.quietBoot {
      boot = {
        kernelParams = mkForce [
          "logo.nologo"
          "fbcon=nodefer"
          "bgrt_disable"
          "vt.global_cursor_default=0"
          "quiet"
          "systemd.show_status=false"
          "rd.udev.log_level=3"
          "splash"
        ];
        consoleLogLevel = mkForce 3;
        initrd.verbose = mkForce false;
      };
    })
    (mkIf
      ((!config.services.displayManager.gdm.enable) && (config.style.displayServer != "headless"))
      {
        environment.systemPackages = [ pkgs.tuigreet ];
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${getExe pkgs.tuigreet} --time --cmd Hyprland";
              user = "greeter";
            };
          };
        };
      }
    )
  ];
}
