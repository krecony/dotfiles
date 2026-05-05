{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.gaming;
in
{
  options.gaming = {
    steam.enable = mkEnableOption "Enables steam";
    minecraft = {
      enable = mkEnableOption "Enables minecraft (polymc)";
      package = mkOption {
        type = types.package;
        default = pkgs.polymc;
      };
    };
    lutris.enable = mkEnableOption "enables lutris";
  };

  config = mkMerge [
    (mkIf cfg.minecraft.enable {
      nixpkgs.overlays = [ inputs.polymc.overlay ];
      settings.userPackages = [ cfg.minecraft.package ];
    })
    (mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
      core.nix.unfreePackages = [
        "steam"
        "steam-unwrapped"
      ];
    })
    (mkIf cfg.lutris.enable {
      hm.programs.lutris = {
        enable = true;
      };

      # workaround for https://github.com/NixOS/nixpkgs/issues/516392
      nixpkgs.overlays = [
        (_: prev: {
          openldap = prev.openldap.overrideAttrs {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          };
        })
      ];
    })
  ];
}
