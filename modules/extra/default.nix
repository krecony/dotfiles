{ mkImports, ... }: {
  imports = mkImports [
    ./usb-blaster.nix
  ];
}
