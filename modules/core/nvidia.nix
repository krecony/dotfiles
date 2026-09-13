{ config, lib, ... }:
let
  cfg = config.core.nvidia;
in
{
  options.core.nvidia = {
    enable = lib.mkEnableOption "NVIDIA open kernel driver with PRIME offload";
    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.intelBusId != "" && cfg.nvidiaBusId != "";
        message = "Set both PRIME bus IDs from this laptop's lspci output.";
      }
    ];
    core.nix.unfreePackages = [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
      package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = lib.mkDefault true;
      powerManagement.finegrained = lib.mkDefault true;
      prime = {
        inherit (cfg) intelBusId nvidiaBusId;
        offload.enable = true;
        offload.enableOffloadCmd = true;
      };
    };
    boot.kernelParams = [ "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];
  };
}
