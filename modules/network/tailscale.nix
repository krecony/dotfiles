{ config, lib, ... }:
with lib;
let
  cfg = config.network.tailscale;
in
{
  options.network.tailscale.enable = mkEnableOption "Enables tailscale";

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--netfilter-mode=nodivert" ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
  };
}
