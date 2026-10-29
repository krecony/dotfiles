{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.apps.codex;
in
{
  options.apps.codex.enable = lib.mkEnableOption "Codex with MCP-NixOS";

  config = lib.mkIf cfg.enable {
    hm.home.packages = [
      pkgs.mcp-nixos
    ];

    hm.programs.codex = {
      enable = true;
      mutableSettings = true;

      settings.mcp_servers.nixos = {
        command = "${lib.getExe pkgs.mcp-nixos}";
        args = [ ];
      };
    };
  };
}
