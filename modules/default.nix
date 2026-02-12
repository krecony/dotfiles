{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  mkImport =
    path:
    import path {
      inherit
        config
        lib
        pkgs
        inputs
        system
        mkImports
        ;
      inherit (config.core) user;
      inherit (config.lib.stylix) colors;
    };

  mkImports = paths: lib.map mkImport paths;
in
{
  imports = mkImports [
    ./core.nix
    ./preferences.nix
    ./gaming.nix

    ./networking
    ./programs
    ./security
    ./shell
    ./style
    ./system
  ];
}
