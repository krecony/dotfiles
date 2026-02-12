{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.lmms;
in
{
  options.programs.lmms = {
    enable = mkEnableOption "enables lmms, the digital audio workstation";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (
        _self: _super:
        let
          lmms-fix-pkgs = import inputs.lmms-nixpkgs { inherit system; };
        in
        {
          inherit (lmms-fix-pkgs) lmms;
        }
      )
    ];
    settings.userPackages = with pkgs; [ lmms ];

    hardware.audio.enableAudioProduction = true;
  };
}
