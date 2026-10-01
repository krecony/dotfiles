{
  pkgs ? import <nixpkgs> { },
}:
pkgs.gnomeExtensions.advanced-media-controller.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    # Spotify supplies mpris:length as uint64; get_int64() emits a GLib
    # critical for that type, which the extension's try/catch cannot catch.
    substituteInPlace "$out/share/gnome-shell/extensions/advanced-media-controller@sanjai.com/utils/mpris/MprisUtils.js" \
      --replace-fail 'return variant.get_int64();' 'switch (variant.get_type_string()) {
        case "x":
          return variant.get_int64();
        case "t":
          return variant.get_uint64();
        default:
          return null;
      }'
  '';
})
