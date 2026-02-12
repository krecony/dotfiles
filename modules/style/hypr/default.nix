{
  lib,
  pkgs,
  inputs,
  config,
  mkImports,
  ...
}:
with lib;
let
  cfg = config.style.desktopEnvironment.Hyprland;
in
{
  imports = mkImports [
    ./binds.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  config = mkIf cfg.enable {
    environment.etc."greetd/environments".text = ''
      Hyprland
    '';

    programs.hyprland.enable = true;

    settings.userPackages = with pkgs; [
      brightnessctl
      wl-clipboard
      wl-clip-persist
      cliphist
      grimblast
      grim
      slurp
    ];

    # wallpaper setter
    hm.services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ config.style.settings.wallpaper ];
        wallpaper = [ config.style.settings.wallpaper ];
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;
        systemd.variables = [ "--all" ];

        # https://github.com/KZDKM/Hyprspace/issues/186
        # buggy for now but i really like the concept
        # plugins = [
        #   inputs.hyprspace.packages.${pkgs.system}.Hyprspace
        # ];

        settings =
          let
            terminal = config.preferences.terminal.swallowClassRegex;
          in
          {
            windowrulev2 = [
              "float,class:^(org.pulseaudio.pavucontrol)$"
              "center,class:^(org.pulseaudio.pavucontrol)$"
              "size 50% 50%,class:^(org.pulseaudio.pavucontrol)$"
              "dimaround,class:^(org.pulseaudio.pavucontrol)$"

              "opacity 1.0 0.7,class:${terminal}"

              "float,class:${terminal},title:^(nmtui)$"
              "center,class:${terminal},title:^(nmtui)$"
              "dimaround,class:${terminal},title:^(nmtui)$"

              "size 70% 70%,title:^(.*)$,class:^(.*)$,floating:1"
            ];
            exec-once = [
              "${lib.getExe pkgs.wl-clip-persist} --clipboard both"
              "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch cliphist store"
            ];

            general = {
              gaps_in = 0;
              gaps_out = 0;
              resize_on_border = 1;
              border_size = 0;
            };
            monitor = [
              "eDP-1, 1920x1080@60, 0x0, 1.25"
              "HDMI-1-A, 1920x1080@60, 0x-1080, 1"
              ",preferred,auto,1"
            ];
            debug.disable_logs = false;
            xwayland.force_zero_scaling = true;
            input = {
              kb_layout = "pl";
              follow_mouse = 1;
              repeat_delay = 300;
              touchpad = {
                disable_while_typing = false;
                scroll_factor = 0.5;
                natural_scroll = true;
              };
            };
            decoration.blur = {
              enabled = true;
              size = 4;
              passes = 2;
              new_optimizations = true;
              ignore_opacity = true;
            };
            gestures = {
              workspace_swipe = true;
              workspace_swipe_forever = true;
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              force_default_wallpaper = 0;
              animate_manual_resizes = true;

              disable_autoreload = true;

              enable_swallow = true;
              swallow_regex = terminal;
              swallow_exception_regex = "^(pavucontrol)$";
            };
          };
      };
    };
  };
}
