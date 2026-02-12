{
  lib,
  config,
  ...
}:
with lib;
{
  environment.variables = mkIf config.style.displayServer.wayland.enable {
    # make electron apps use wayland
    NIXOS_OZONE_WL = "1";
    # make anki use wayland
    ANKI_WAYLAND = "1";
    # make firefox use wayland
    MOZ_ENABLE_WAYLAND = "1";
    # make gtk use wayland
    GDK_BACKEND = "wayland";
    # prefer wayland on qt
    QT_QPA_PLATFORM = "wayland;xcb";

    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";

    _JAVA_AWT_WM_NONEREPARENTING = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}
