{
  lib,
  config,
  pkgs,
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
      enable = mkEnableOption "Enables minecraft (prism)";
			mcsr = mkEnableOption "Installs waywall and other tools used for minecraft speedrunning";
    };
    lutris.enable = mkEnableOption "enables lutris";
  };

  config = mkMerge [
    (mkIf cfg.minecraft.enable {
      settings.userPackages = with pkgs; [ (prismlauncher.override {
				additionalLibs = [
					libxtst
					libxkbcommon
					libxt
				];
			}) ];
			# faster allocation
			environment.systemPackages = [ pkgs.jemalloc ]; 
    })
		(mkIf (cfg.minecraft.enable && cfg.minecraft.mcsr) {
      settings.userPackages = [ pkgs.waywall ];
			# hm.xdg.configFile."waywall/init.lua" = null; # https://github.com/arjuncgore/waywall_generic_config
		})
    (mkIf cfg.steam.enable {
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
    })
    (mkIf cfg.lutris.enable {
      hm.programs.lutris = {
        enable = true;
      };
    })
  ];
}
