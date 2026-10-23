final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    copyous = final.callPackage ./copyous.nix { };
    advanced-media-controller = final.callPackage ./advanced-media-controller.nix {
      inherit (prev.gnomeExtensions) advanced-media-controller;
    };
  };
  pianobooster = final.callPackage ./pianobooster.nix {
    inherit (prev) pianobooster;
  };
}
