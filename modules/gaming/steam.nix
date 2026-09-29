{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.gaming.steam;
in
{
  options.gaming.steam.enable = mkEnableOption "Enables steam";

  config = mkIf cfg.enable {
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      extraPackages = with pkgs; [
        mangohud
        gamemode
      ];
    };
    core.nix.unfreePackages = [
      "steam"
      "steam-unwrapped"
    ];
  };
}
