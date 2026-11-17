final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    copyous = final.callPackage ./copyous.nix { };
  };
  pianobooster = final.callPackage ./pianobooster.nix {
    inherit (prev) pianobooster;
  };
}
