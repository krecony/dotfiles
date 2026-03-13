{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  extensions = with pkgs.gnomeExtensions; [
    appindicator # tray icons
    blur-my-shell # adds transparency and blur to gnome
    (pkgs.callPackage ./copyous.nix { inherit pkgs; }) # clipboard
    media-controls # adds mpris widget
    caffeine # provides idle-inhibit on demand
    tiling-shell # adds tiling support
  ];
in
{
  config = mkIf (config.style.desktopEnvironment == "gnome") {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      gnome = {
        core-os-services.enable = true;
        localsearch.enable = true;
        gnome-keyring.enable = true;

        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    security.pam.services.login.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

    settings.userPackages = with pkgs; [
      baobab
      komikku
      resources
      gnome-calendar
      gnome-clocks
      gnome-disk-utility
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
      settings = mkMerge [
        {
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
        }
        (import ./binds.nix { inherit config lib; })
      ];
    };
  };
}
