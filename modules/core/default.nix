{
  lib,
  config,
  pkgs,
  mkImports,
  ...
}:
with lib;
let
  cfg = config.core;
in
{
  imports = mkImports [
    ./system.nix
    ./nix.nix
    ./sound.nix
    ./boot.nix
    ./bluetooth.nix
    ./sleep.nix
    ./intel.nix
    ./wayland.nix
  ];

  options.core = {
    user = mkOption {
      type = types.str;
      default = "";
      description = ''
        The username used throughout the system
        for example for home-manager
      '';
    };
    flakePath = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = "path to your nixos config";
    };
    shell = mkOption {
      type = types.enum [
        "zsh"
      ];
      default = "zsh";
      description = "system shell";
    };
  };

  config =
    let
      shellPackage = if cfg.shell == "zsh" then pkgs.zsh else pkgs.bash;
    in
    {
      assertions = [
        {
          assertion = cfg.user != "";
          message = "A username must be set";
        }
      ];

      users = {
        defaultUserShell = shellPackage;
        mutableUsers = false;
        users = {
          ${cfg.user} = {
            isNormalUser = true;
            useDefaultShell = true;
            initialHashedPassword = lib.mkDefault "";
            extraGroups = [
              "networkmanager"
              "wheel"
              "bluetooth"
            ];
          };
        };
      };
    };
}
