{ ... }:
{
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitch = "hybrid-sleep";
        HandleLidSwitchExternalPower = "lock";
        HandlePowerKey = "hybrid-sleep";
        HandlePowerKeyLongPress = "reboot";
      };
    };
  };
}
