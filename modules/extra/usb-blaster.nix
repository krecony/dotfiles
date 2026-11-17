{ config, lib, ... }:
with lib;
let
  cfg = config.extra.usb-blaster;
in
{
  options.extra.usb-blaster.enable = mkEnableOption "enables Altera USB-Blaster I and II, for FPGA programming";

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      			# Altera USB-Blaster
      			SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
      			SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
      			SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"

      			# Altera USB-Blaster II
      			SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
      			SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"
      		'';
  };
}
