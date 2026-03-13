{
  config,
  lib,
  user,
  ...
}:
with lib;
let
  cfg = config.core.nix;
in
{
  options.core.nix = {
    unfreePackages = mkOption {
      default = [ ];
      type = types.listOf types.str;
      description = "Allows for unfree packages by their name";
    };
  };

  config = {
    nixpkgs.config = lib.mkIf (cfg.unfreePackages != [ ]) {
      allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) cfg.unfreePackages;
    };

    documentation = {
      enable = true;
      doc.enable = false;
      man.enable = true;
      dev.enable = false;
    };

    programs.nh = {
      enable = true;
      flake = config.core.flakePath;
      clean = {
        enable = true;
        extraArgs = "--keep 10 --keep-since 7d";
        dates = "weekly";
      };
    };

    nix = {
      extraOptions = ''
        keep-outputs = true
        warn-dirty = false
        keep-derivations = true
      '';

      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [
          "@wheel"
          "${user}"
        ];

        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        ];
      };
    };
    system = {
      autoUpgrade.enable = false; # maybe change later?
    };
  };
}
