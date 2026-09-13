{ lib, ... }:
{
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitchDocked = lib.mkDefault "ignore";
        HandleLidSwitch = lib.mkDefault "hybrid-sleep";
        HandleLidSwitchExternalPower = lib.mkDefault "lock";
        HandlePowerKey = lib.mkDefault "hybrid-sleep";
        HandlePowerKeyLongPress = lib.mkDefault "reboot";
      };
    };
  };
}
