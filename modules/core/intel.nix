{ pkgs, ... }:
{
  boot = {
    kernelModules = [ "i915" ];
    kernelParams = [ "i915.fastboot=1" ];
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
    cpu.intel.updateMicrocode = true;
  };
}
