{
  lib,
  pkgs,
  mkImports,
  config,
  ...
}:
with lib;
let
  cfg = config.preferences;

  mkApp =
    pkg:
    mkOption {
      type = types.nullOr types.package;
      default = pkg;
    };

  mkDir =
    dir:
    mkOption {
      type = types.str;
      default = dir;
    };
in
{
  imports = mkImports [
    ./mimeapps.nix
  ];

  options.preferences = {
    editor = mkOption {
      type = types.package;
      default = pkgs.neovim;
    };

    browser = mkApp pkgs.firefox;
    secondaryBrowser = mkApp null;
    pdf = mkApp pkgs.zathura;
    image = mkApp pkgs.imv;
    audio = mkApp pkgs.mpv;
    video = mkApp pkgs.mpv;
    terminal = mkApp pkgs.foot;
    terminalSwallowClassRegex = mkOption {
      type = types.str;
      default = "^(foot)";
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
    userDirs.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf (config.style.displayServer != "headless") {
      environment.sessionVariables.BROWSER = "${getExe cfg.browser}";

      settings.userPackages = [
        cfg.browser
        cfg.pdf
        cfg.image
        cfg.audio
        cfg.video
        cfg.terminal
      ]
      ++ (optionals (cfg.secondaryBrowser != null) [ cfg.secondaryBrowser ]);

      hm.xdg = {
        enable = true;

        userDirs = {
          inherit (cfg.userDirs) enable;
          createDirectories = false;
          setSessionVariables = true;
        }
        // cfg.userDirs;
      };
    })
    {
      environment = {
        systemPackages = [
          cfg.editor
        ];
        sessionVariables = {
          EDITOR = "${getExe cfg.editor}";
        };
      };
    }
  ];
}
