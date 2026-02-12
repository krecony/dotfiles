{
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.lib) getExe getExe';
in
{
  hm.services.hypridle = {
    inherit (config.style.desktopEnvironment.Hyprland) enable;

    settings = {
      general = {
        lock_cmd = "pidof ${getExe pkgs.hyprlock} || ${getExe pkgs.hyprlock}";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "${getExe' pkgs.hyprland "hyprctl"} dispatch dpms on";
      };

      listener = [
        # lock after 3 minutes
        {
          timeout = 180;
          on-timeout = "${getExe' pkgs.systemd "loginctl"} lock-session";
        }
        # black out screen affter 5 minutes
        {
          timeout = 300;
          on-timeout = "${getExe pkgs.brightnessctl} -s set 0";
          on-resume = "${getExe pkgs.brightnessctl} -r";
        }
      ];
    };
  };
}
