{
  lib,
  config,
  mkImports,
  ...
}:
with lib;
let
  cfg = config.gaming;
in
{
  imports = mkImports [
    ./steam.nix
    ./minecraft
  ];

  options.gaming = {
    lutris.enable = mkEnableOption "enables lutris";
  };

  config = mkMerge [
    (mkIf cfg.lutris.enable {
      hm.programs.lutris = {
        enable = true;
      };
    })
  ];
}
