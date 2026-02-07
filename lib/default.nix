{ lib, ... }:
{
  mkBoolOption =
    desc: bool:
    lib.mkOption {
      default = bool;
      example = !bool;
      description = desc;
      type = lib.types.bool;
    };

  forAllSystems = lib.genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
}
