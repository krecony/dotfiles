{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.core.boot;
in
{
  options.core.boot = {
    encryptedBootPartition = mkEnableOption "legacy GRUB encrypted /boot support (deprecated)";
    bootloader = mkOption {
      type = types.enum [
        "systemd-boot"
        "lanzaboote"
        "grub"
        "none"
      ];
      default = if cfg.encryptedBootPartition then "grub" else "systemd-boot";
      description = "Bootloader selection; disk encryption is configured separately.";
    };
    pkiBundle = mkOption {
      type = types.str;
      default = "/var/lib/sbctl";
      description = "Runtime directory containing Secure Boot keys; never a Nix store path.";
    };
    quietBoot = mkEnableOption "adds kernelParams that reduce logging to the screen";
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.encryptedBootPartition || cfg.bootloader == "grub";
          message = "Legacy encrypted /boot requires GRUB. Define new layouts in the host's disko.nix.";
        }
      ];
      warnings = optional cfg.encryptedBootPartition "core.boot.diskEncryption is legacy encrypted-/boot support; do not use it for new hosts.";
    }
    {
      boot = {
        initrd.systemd.enable = mkDefault true;
        loader = {
          systemd-boot = {
            enable = mkDefault (cfg.bootloader == "systemd-boot");
            consoleMode = mkDefault "max";
            editor = mkDefault false;
            configurationLimit = mkDefault null;
          };
          grub = {
            enable = mkDefault (cfg.bootloader == "grub");
            device = mkDefault "nodev";
            efiSupport = mkDefault true;
            enableCryptodisk = mkDefault false;
          };
          efi = {
            canTouchEfiVariables = mkDefault true;
            efiSysMountPoint = mkDefault "/boot";
          };
        };
      };
    }
    (mkIf cfg.quietBoot {
      boot = {
        loader.timeout = 0;
        kernelParams = [
          "logo.nologo"
          "fbcon=nodefer"
          "bgrt_disable"
          "vt.global_cursor_default=0"
          "quiet"
          "systemd.show_status=false"
          "rd.udev.log_level=3"
          "splash"
        ];
        consoleLogLevel = 3;
        initrd.verbose = mkDefault false;
      };
    })
    (mkIf (cfg.bootloader == "lanzaboote") {
      boot.loader.systemd-boot.enable = mkForce false;
      boot.lanzaboote = {
        enable = true;
        inherit (cfg) pkiBundle;

        # measured boot limitation
        configurationLimit = mkForce 8;

        measuredBoot = {
          enable = true;
          pcrs = [
            4
            7
          ];
          autoCryptenroll.enable = false;
        };
      };
      environment.systemPackages = [ pkgs.sbctl ];
    })
    (mkIf cfg.encryptedBootPartition {
      boot =
        let
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
          loader = {
            grub = {
              enable = mkForce true;
              device = mkForce "nodev";
              efiSupport = mkForce true;
              enableCryptodisk = mkForce true;
              extraGrubInstallArgs = mkForce [ "--modules=${moduleString}" ];
            };
            systemd-boot.enable = mkForce false;
            efi.efiSysMountPoint = mkForce "/efi";
          };
          initrd.systemd = {
            enable = mkForce true;
            tpm2.enable = mkForce true;
          };
        };
    })
    (mkIf ((!config.services.displayManager.gdm.enable) && (config.style.displayServer != "headless")) {
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
    })
  ];
}
