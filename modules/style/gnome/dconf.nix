{
  extensions,
  colors,
  lib,
  ...
}:
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
  # disable accessibility menu on the login screen
  "org/gnome/desktop/a11y".always-show-universal-access-status = false;
  "org/gnome/shell".always-show-log-out = true;

  "org/gnome/shell/extensions/advanced-media-controller" = {
    enable-lyrics = false;
    hide-default-player = true;
    panel-index = 15;
    panel-label-width = 230;
    panel-position = "left";
    popup-width = 280;
    show-artist = false;
  };
  "org/gnome/shell/extensions/paperwm" = {
    horizontal-margin = 0;
    open-window-position = 0;
    restore-attach-modal-dialogs = "true";
    restore-edge-tiling = "true";
    restore-workspaces-only-on-primary = "true";
    selection-border-radius-top = 0;
    selection-border-size = 0;
    show-window-position-bar = false;
    show-workspace-indicator = false;
    use-default-background = true;
    vertical-margin = 0;
    vertical-margin-bottom = 0;
    window-gap = 0;
  };
  "org/gnome/shell/extensions/copyous" = {
    clipboard-margin-bottom = 0;
    clipboard-margin-left = 0;
    clipboard-margin-right = 0;
    clipboard-margin-top = 0;
    clipboard-position-vertical = "bottom";
    disable-hljs-dialog = true;
    database-backend = "json";
  };
  "org/gnome/shell/extensions/copyous/character-item".show-unicode = true;
  "org/gnome/shell/extensions/copyous/text-item" = {
    show-text-info = true;
    text-count-mode = "words";
  };
  "org/gnome/shell/extensions/copyous/theme" =
    with lib.custom;
    with colors;
    {
      custom-bg-color = hex-to-rgb base00;
      custom-card-bg-color = hex-to-rgb base01;
      custom-fg-color = hex-to-rgb base05;
      custom-search-bg-color = hex-to-rgb base01;
      theme = "custom";
    };
}
