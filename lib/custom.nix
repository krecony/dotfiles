lib: rec {
  mkBoolOption =
    desc: bool:
    lib.mkOption {
      default = bool;
      example = !bool;
      description = desc;
      type = lib.types.bool;
    };

  mkEnableByDefaultOption = desc: mkBoolOption desc true;

  forAllSystems = lib.genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  ifNull = new: old: if old == null then new else old;

  genAttrsSame = names: value: lib.genAttrs names (_: value);

  # turns a hex color (without hashtag) into an rgb one
  # e.g. 123456 -> rgb(18, 52, 86)
  hex-to-rgb =
    with lib.strings;
    x:
    let
      hex-to-dec =
        x:
        let
          y = charToInt x;
        in
        if y >= 97 then y - 87 else y - 48;
      merge-hex = x: y: lib.toString ((lib.elemAt x y) * 16 + (lib.elemAt x (y + 1)));
      s = map hex-to-dec (stringToCharacters (toLower x));
    in
    "rgb(${merge-hex s 0}, ${merge-hex s 2}, ${merge-hex s 4})";
}
