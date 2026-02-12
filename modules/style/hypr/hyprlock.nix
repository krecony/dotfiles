{
  config,
  lib,
  ...
}:
{
  hm.programs.hyprlock =
    with config.lib.stylix.colors;
    let
      hex-to-rgb =
        with lib.strings;
        x:
        let
          hex-to-dec =
            x:
            let
              y = charToInt x;
            in
            if y >= 97 then y - 87 else y - 48;
          merge-hex = x: y: lib.toString ((lib.elemAt x y) * 16 + (lib.elemAt x (y + 1)));
          s = map hex-to-dec (stringToCharacters (toLower x));
        in
        "rgb(${merge-hex s 0}, ${merge-hex s 2}, ${merge-hex s 4})";
    in
    {
      inherit (config.style.desktopEnvironment.Hyprland) enable;

      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };

        background = {
          monitor = "";
          color = hex-to-rgb base00;
        };

        input-field = [
          {
            monitor = "";
            size = "300, 50";
            outline_thickness = 3;
            dots_size = 0.33;
            dots_spacing = 0.15;
            outer_color = hex-to-rgb base00;
            inner_color = hex-to-rgb base00;
            font_color = hex-to-rgb base05;
            fade_on_empty = false;
            dots_center = false;
            placeholder_text = "";
            hide_input = false;
            rounding = 0;
            check_color = hex-to-rgb base00;
            fail_color = hex-to-rgb base08;
            fail_text = "dumbass";
            position = "20, 20";
            halign = "left";
            valign = "bottom";
          }
        ];

        label = [
          {
            monitor = "";
            position = "30, 70";
            text = "$TIME";
            font_size = 50;
            color = hex-to-rgb base05;
            halign = "left";
            valign = "bottom";
          }
          {
            monitor = "";
            text = "cmd[update:5000] echo \"$(cat /sys/class/power_supply/BAT1/capacity)%\"";
            text_align = "right";
            color = hex-to-rgb base05;
            position = "-40, 70";
            halign = "right";
            valign = "bottom";
          }
          {
            monitor = "";
            text = "$LAYOUT";
            text_align = "right";
            color = hex-to-rgb base05;
            position = "-40, 40";
            halign = "right";
            valign = "bottom";
          }
        ];
      };
    };
}
