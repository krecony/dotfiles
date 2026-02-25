{ pkgs, ... }:
{
  boot = {
    kernelModules = [ "i915" ];
    kernelParams = [
      "i915.enable_psr=0"
      "i915.enable_dc=0"
      "i915.enable_fbc=0"
    ];
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
