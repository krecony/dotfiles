{ lib, config, ... }:
with lib;
{
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
}
