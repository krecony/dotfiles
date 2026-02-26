{
  mkImports,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.style;
in
{
  imports = mkImports [
    ./style.nix
    ./fonts.nix

    ./hypr
    ./gnome
  ];

  options.style = {
    displayServer = mkOption {
      type = types.listOf (types.enum [
        "wayland"
        "x11"
        "headless"
      ]);
      default = "headless";
      description = "the display server to use";
    };

    desktopEnvironment = {
      Hyprland = {
        enable = mkEnableOption "enables Hyprland";
        default = true;
      };
      gnome = {
        enable = mkEnableOption "enables the gnome desktop environment";
        default = false;
      };
    };

    widgets = {
      ags = {
        enable = mkEnableOption "enables my ags shell";
      };
    };
  };

  config = {
    hm.services.ags = {
      inherit (cfg.widgets.ags) enable;
      hyprlandIntegration = {
        inherit (cfg.desktop.Hyprland) enable;
        autostart.enable = true;
        keybinds.enable = true;
      };
    };

    programs.xwayland.enable = cfg.displayServer == "wayland";

    assertions =
      let
        workOnWayland =
          list:
          let
            mkAssertion = attr: opt: {
              assertion = !(attr && cfg.displayServer == "x11");
              message = "${opt} only works on wayland!";
            };
          in
          map (x: mkAssertion (elemAt x 0) (elemAt x 1)) list;
      in
      workOnWayland [
        [
          cfg.widgets.ags.enable
          "ags shell"
        ]
        [
          cfg.desktopEnvironment.Hyprland.enable
          "Hyprland"
        ]
      ];
  };
}
