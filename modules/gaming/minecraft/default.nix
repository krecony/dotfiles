{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
#	a lot of stuff copied from uku's config (https://git.uku3lig.net/uku/flake/src/branch/main/programs/mcsr/)
let
  cfg = config.gaming.minecraft;
  mcsrPkgs = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system};

  mkStrOpt =
    s:
    mkOption {
      type = types.str;
      default = s;
    };

  remapOpts = { ... }: {
    options = {
      from = mkOption {
        type = types.str;
        description = "the key to map from";
      };
      to = mkOption {
        type = types.str;
        description = "the key to map to";
      };
    };
  };
in
{
  options.gaming.minecraft = {
    enable = mkEnableOption "Enables minecraft (prism)";
    mcsr = {
      enable = mkEnableOption "Installs waywall and other tools used for minecraft speedrunning";
      width = mkOption {
        type = types.int;
        default = 1920;
      };
      height = mkOption {
        type = types.int;
        default = 1080;
      };

      keys = {
        thin = mkStrOpt "G";
        wide = mkStrOpt "H";
        tall = mkStrOpt "Y";
        ninjabrain = mkStrOpt "Ctrl-Shift-N";
        fullscreen = mkStrOpt "Ctrl-Shift-F";
      };

      remaps = mkOption {
        type = types.listOf (types.submodule remapOpts);
      };

      sensitivity = {
        normal = mkOption {
          type = types.float;
          default = 8.77960496;
        };
        tall = mkOption {
          type = types.float;
          default = 0.5922669;
        };
      };
    };
  };

  imports = [ inputs.mcsr-nixos.nixosModules.waywall ];

  config = mkIf cfg.enable {
    settings.userPackages = with pkgs; [
      (prismlauncher.override {
        additionalLibs = [
          libxtst
          libxkbcommon
          libxt
        ];
      })
    ];

    hm.home.file = mkIf cfg.mcsr.enable {
      ".config/waywall/init.lua".source = config.programs.waywall.config.finalFile;
    };

    programs.waywall = mkIf cfg.mcsr.enable {
      enable = true;
      config = {
        enableWaywork = true;
        programs = [ mcsrPkgs.ninjabrain-bot ];
        files.eye_overlay = ./eye-overlay.png;
        text =
          let
            remaps =
              if cfg.mcsr.remaps != [ ] then
                concatStringsSep " " (map (r: ''["${r.from}"] = "${r.to}",'') cfg.mcsr.remaps)

              else
                "";
          in
          ''
            	local resolution = { w = ${toString cfg.mcsr.width}, h = ${toString cfg.mcsr.height} }
            	local thin_key = "${toString cfg.mcsr.keys.thin}"
            	local wide_key = "${toString cfg.mcsr.keys.wide}"
            	local tall_key = "${toString cfg.mcsr.keys.tall}"
            	local nb_key = "${toString cfg.mcsr.keys.ninjabrain}"
            	local fs_key = "${toString cfg.mcsr.keys.fullscreen}"

            	local normal_sens = ${toString cfg.mcsr.sensitivity.normal}
            	local tall_sens = ${toString cfg.mcsr.sensitivity.tall}

            	local remaps = { ${remaps} }
          ''
          + builtins.readFile ./waywall.lua;

      };
    };
  };
}
