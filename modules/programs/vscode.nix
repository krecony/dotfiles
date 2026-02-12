{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.vscode;
in
{
  options.programs.vscode.enable = mkEnableOption "enables vscode";

  config = mkIf cfg.enable {
    hm.programs.vscode = {
      enable = lib.mkDefault true;
    };

    settings.nix.unfreePackages = [
      "vscode"
    ];
  };
}
