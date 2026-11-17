{ config, lib, ... }:
with lib;
let
  cfg = config.apps.tmux;
in
{
  options.apps.tmux.enable = mkEnableOption "enables tmux, the terminal multiplexer";

  config = mkIf cfg.enable {
    hm.programs.tmux = {
      enable = true;
      shell = lib.getExe config.programs.zsh.package;
      clock24 = true;
      historyLimit = 50000;
      mouse = true;
      extraConfig = ''
        set -g mode-keys vi
      '';
    };
  };
}
