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
    ./extra
  ];

  options.style = {
    displayServer = mkOption {
      type = types.enum [
        "wayland"
        "x11"
        "headless"
      ];
      default = "headless";
      description = "the display server to use";
    };

    desktopEnvironment = mkOption {
      type = types.nullOr (
        types.enum [
          "hyprland"
          "gnome"
        ]
      );
      default = null;
      description = "the desktop environment to use";
    };
  };

  config = {
    programs.xwayland.enable = cfg.displayServer == "wayland";
  };
}
