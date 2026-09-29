{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.gaming.minecraft;
in
{
  options.gaming.minecraft = {
    enable = mkEnableOption "Enables minecraft (prism)";
    mcsr = mkEnableOption "Installs waywall and other tools used for minecraft speedrunning";
  };

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
  };
}
