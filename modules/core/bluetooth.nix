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
  options.core.bluetooth.enable = custom.mkBoolOption "enables bluetooth on the device" true;

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
