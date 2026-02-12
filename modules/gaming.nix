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
      settings.nix.unfreePackages = [
        "steam"
        "steam-unwrapped"
      ];
    })
  ];
}
