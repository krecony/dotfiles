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

  mkImports =
    imports:
    let
      split = lib.partition lib.isPath imports;
      paths = split.right;
      others = split.wrong;
    in
    (lib.map mkImport paths) ++ others;
in
{
  imports = mkImports [
    ./preferences.nix
    ./gaming.nix

    ./network
    ./programs
    ./security
    ./shell
    ./style
    ./core
  ];
}
