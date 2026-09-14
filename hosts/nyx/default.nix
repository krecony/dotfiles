{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel
    ./hardware-configuration.nix
    ./disko.nix
    ./settings.nix
  ];
  system.stateVersion = "26.05";
}
