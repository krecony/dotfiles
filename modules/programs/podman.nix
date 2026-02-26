{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.podman;
in
{
  options.programs.podman.enable = mkOption {
    type = types.bool;
    default = elem "server" config.core.capabilities;
    example = false;
    description = "Enables podman on the device";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [
      podman-tui
      podman-compose
    ];
  };
}
