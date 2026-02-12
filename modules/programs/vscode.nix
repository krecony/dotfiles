{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.vs-code;
in
{
  options.programs.vs-code.enable = mkEnableOption "enables vscode";

  config = mkIf cfg.enable {
    hm.programs.vscode = {
      enable = lib.mkDefault true;
    };

    core.nix.unfreePackages = [
      "vscode"
    ];
  };
}
