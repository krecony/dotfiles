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
    # Compatibility only: retain zephyr's existing encrypted /boot layout.
    diskEncryption = mkEnableOption "legacy GRUB encrypted /boot support (deprecated)";
    bootloader = mkOption {
      type = types.enum [
        "systemd-boot"
        "lanzaboote"
        "grub"
        "none"
      ];
      default = if cfg.diskEncryption then "grub" else "systemd-boot";
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
      boot = {
        loader = {
          systemd-boot = {
            enable = mkDefault (cfg.bootloader == "systemd-boot");
            consoleMode = mkDefault "auto";
          };
          grub.enable = mkDefault (cfg.bootloader == "grub");
        };
      };
    }
    {
      assertions = [
        {
          assertion = !cfg.diskEncryption || cfg.bootloader == "grub";
          message = "Legacy encrypted /boot requires GRUB. Define new layouts in the host's disko.nix.";
        }
      ];
      warnings = optional cfg.diskEncryption "core.boot.diskEncryption is legacy encrypted-/boot support; do not use it for new hosts.";
    }
    (mkIf (cfg.bootloader == "lanzaboote") {
      boot.loader.systemd-boot.enable = mkForce false;
      boot.loader.efi.canTouchEfiVariables = mkDefault true;
      boot.lanzaboote = {
        enable = true;
        inherit (cfg) pkiBundle;
        configurationLimit = mkDefault 8;

				measuredBoot = {
					enable = true;
					pcrs = [ 4 7 ];
					autoCryptenroll.enable = false;
				};
      };
      environment.systemPackages = [ pkgs.sbctl ];
    })
    (mkIf (cfg.bootloader == "grub" && !cfg.diskEncryption) {
      boot.loader.grub = {
        device = mkDefault "nodev";
        efiSupport = mkDefault true;
        enableCryptodisk = mkDefault false;
      };
      boot.loader.efi.canTouchEfiVariables = mkDefault true;
    })
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
        consoleLogLevel = mkDefault 3;
        initrd.verbose = mkDefault false;
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
