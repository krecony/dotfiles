{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.preferences;

  mkDefaultApp = pkg: {
    package = mkOption {
      type = types.package;
      default = pkg;
    };
    desktopFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If set to null a heuristic will try to get the desktop file
      '';
    };
  };

  mkDir =
    dir:
    mkOption {
      type = types.str;
      default = dir;
    };
in
{
  options.preferences = {
    editor.package = mkOption {
      type = types.package;
      default = pkgs.neovim;
    };

    browser = mkDefaultApp pkgs.brave;
    pdf = mkDefaultApp pkgs.zathura;
    image = mkDefaultApp pkgs.imv;
    audio = mkDefaultApp pkgs.mpv;
    video = mkDefaultApp pkgs.mpv;
    terminal = {
      package = mkOption {
        type = types.package;
        default = pkgs.foot;
      };
      swallowClassRegex = mkOption {
        type = types.str;
        default = "^(foot)";
      };
    };

    userDirs = {
      download = mkDir "$HOME/download";
      documents = mkDir "$HOME/docs";
      videos = mkDir "$HOME/vids";
      music = mkDir "$HOME/music";
      pictures = mkDir "$HOME/pics";
      desktop = mkDir "$HOME/other";
      publicShare = mkDir "$HOME/other";
      templates = mkDir "$HOME/other";
    };
    mimeApps.enable = mkOption {
      type = types.bool;
      default = true;
    };
    userDirs.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    environment = {
      systemPackages = [
        cfg.editor.package
      ];
      sessionVariables = {
        BROWSER = "${getExe cfg.browser.package}";
        EDITOR = "${getExe cfg.editor.package}";
      };
    };

    settings.userPackages = [
      cfg.browser.package
      cfg.pdf.package
      cfg.image.package
      cfg.audio.package
      cfg.video.package
      cfg.terminal.package
    ];

    hm.xdg = {
      enable = true;

      userDirs = {
        inherit (cfg.userDirs) enable;
        createDirectories = false;
      }
      // cfg.userDirs;

      mimeApps =
        let
          mkAssociations =
            assoc: name:
            custom.genAttrsSame assoc (
              pipe name [
                (n: cfg.${name}.package)
                custom.getDesktopFile

                (custom.ifNull cfg.${name}.desktopFile)
                (custom.ifNull "")
              ]
            );

          associations =
            with custom.associations;
            mergeAttrsList [
              (mkAssociations browser "browser")
              (mkAssociations pdf "pdf")
              (mkAssociations audio "audio")
              (mkAssociations image "image")
              (mkAssociations video "video")
            ];
        in
        {
          inherit (cfg.mimeApps) enable;
          defaultApplications = associations;
          associations.added = associations;
        };
    };
  };
}
