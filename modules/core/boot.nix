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
    bootloader = mkOption {
      type = types.enum [
        "systemd-boot"
        "lanzaboote"
        "grub"
        "none"
      ];
      default = "systemd-boot";
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
      };
    })
    (mkIf (cfg.bootloader == "lanzaboote") {
      boot.loader.systemd-boot.enable = mkForce false;
      boot.lanzaboote = {
        enable = true;
        inherit (cfg) pkiBundle;

        # measured boot limitation of systemd
        # FIXME: to be fixed upstream of lanzaboote in https://github.com/systemd/systemd/pull/43982
        configurationLimit = mkForce 4;

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
