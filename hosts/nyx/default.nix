{ inputs, lib, modulesPath, config, ... }:
{
  imports = [
    "${inputs.nixos-hardware}/lenovo/thinkpad/p14s/intel" # no gen6 configuration
		(modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix
    ./settings.nix
  ];

  system.stateVersion = "26.05";
  hm.home.stateVersion = "25.05";

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
