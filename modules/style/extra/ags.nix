{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.style.extra.ags;
in
{
  options.style.extra.ags.enable = mkEnableOption "enables custom ags shell";

  config = mkIf cfg.enable {
    hm = {
      imports = [
        inputs.ags.homeManagerModules.ags
      ];

      services.ags = {
        enable = true;
        hyprlandIntegration = {
          enable = config.style.desktopEnvironment == "hyprland";
          autostart.enable = true;
          keybinds.enable = true;
        };
      };
    };

    assertions = [
      {
        assertion = !(cfg.enable && config.style.displayserver != "wayland");
        message = "ags only works on wayland";
      }
    ];
  };
}
