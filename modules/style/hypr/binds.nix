{
  lib,
  pkgs,
  config,
  ...
}:
let
  mod = "SUPER";
  modshift = "SUPER SHIFT";
in
{
  hm.wayland.windowManager.hyprland.settings = {
    bind = [
      "${mod},RETURN,exec,${lib.getExe config.preferences.terminal.package}"
      "${mod},Q,killactive"

      "${mod},H,movefocus,l"
      "${mod},L,movefocus,r"
      "${mod},K,movefocus,u"
      "${mod},J,movefocus,d"
      "${mod},P,exec,${lib.getExe pkgs.pavucontrol}"

      "${mod},V,togglefloating,"
      "${mod},F,fullscreen,"
      "${mod},W,exec,${lib.getExe config.preferences.browser.package}"
      "${modshift},L,exec,${lib.getExe pkgs.hyprlock}"

      ",Print,exec,${lib.getExe pkgs.grimblast} --freeze copysave screen ${config.preferences.userDirs.pictures}/$(date +ScreenShot-%F-%R:%S).png"
      "${mod},Print,exec,${lib.getExe pkgs.grimblast} --freeze copysave area ${config.preferences.userDirs.pictures}/$(date +ScreenShot-%F-%R:%S).png"
      "${modshift},Print,exec,${lib.getExe pkgs.grimblast} --freeze copysave active ${config.preferences.userDirs.pictures}/$(date +ScreenShot-%F-%R:%S).png"

      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ]
    ++ (lib.concatLists (
      lib.genList (
        x:
        let
          ws =
            let
              c = (x + 1) / 10;
            in
            lib.toString (x + 1 - (c * 10));
        in
        [
          "${mod}, ${ws}, workspace, ${toString (x + 1)}"
          "${modshift}, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      ) 10
    ));

    bindm = [
      "${mod},mouse:272,movewindow"
      "${mod},mouse:273,resizewindow"
    ];
    binde = [
      ",XF86MonBrightnessUp,exec,${lib.getExe pkgs.brightnessctl} set +10%"
      ",XF86MonBrightnessDown,exec,${lib.getExe pkgs.brightnessctl} set 10%-"
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];
  };
}
