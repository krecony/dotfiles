{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.style.desktopEnvironment.gnome;

  extensions = with pkgs.gnomeExtensions; [
    appindicator # tray icons
    blur-my-shell # adds transparency and blur to gnome
    (pkgs.callPackage ./copyous.nix { inherit pkgs; })
    media-controls # adds mpris widget
    caffeine # provides idle-inhibit on demand
    tiling-shell # adds tiling support
  ];
in
{
  config = mkIf cfg.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      gnome = {
        core-os-services.enable = true;
        localsearch.enable = true;

        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    settings.userPackages = with pkgs; [
      baobab
      komikku
      resources
      gnome-calendar
      gnome-clocks
    ];

    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
      ];
      systemPackages = [ pkgs.nautilus ] ++ extensions;
    };

    services.udev.packages = [ pkgs.gnome-settings-daemon ];

    preferences.terminal.package = pkgs.gnome-console;

    hm.dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = map (x: x.extensionUuid) extensions;
        };
        "org/gnome/desktop/search-providers" = {
          disabled = [ ];
        };
        "org/gnome/shell/extensions/blur/blur-my-shell" = {
          brightness = 0.75;
          noise-amount = 0;
        };
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/shell/extensions/tiling/shell" = {
          inner-gaps = 0;
          outer-gaps = 0;
          enable-tiling-system = true;
        };
        "org/gnome/desktop/wm/keybindings".close = [ "<Super>q" ];
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          ];
          home = [ "<Shift><Super>f" ];
          screensaver = [ "<Shift><Super>l" ];
          www = [ "<Super>w" ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
          mkIf (config.preferences.secondaryBrowser != null)
            {
              binding = "<Shift><Super>w";
              command = getExe config.preferences.secondaryBrowser.package;
              name = "Launch second browser";
            };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>Return";
          command = getExe config.preferences.terminal.package;
          name = "Launch terminal";
        };
        "org/gnome/shell/extensions/tilingshell" = {
          focus-window-down = "<Super>j";
          focus-window-left = "<Super>h";
          focus-window-right = "<Super>l";
          focus-window-up = "<Super>k";
        };
        "org/gnome/shell/extensions/caffeine" = {

          toggle-shortcut = [ "<Shift><Super>c" ];
        };
      };
    };
  };
}
