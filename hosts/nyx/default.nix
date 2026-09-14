{ inputs, ... }:
{
  imports = [
    "${inputs.nixos-hardware}/lenovo/thinkpad/p14s/intel" # no gen6 configuration
    ./hardware-configuration.nix
    ./disko.nix
    ./settings.nix
  ];
  system.stateVersion = "26.05";
}
