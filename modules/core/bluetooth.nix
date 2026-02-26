{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.core.bluetooth;
in
{
  options.core.bluetooth.enable = mkOption {
    type = types.bool;
    default = elem "desktop" config.core.capabilities;
    example = false;
    description = "Enables bluetooth on the device";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    environment.systemPackages = with pkgs; [ bluez ];

    users.users.${config.core.user}.extraGroups = [ "bluetooth" ];
  };
}
