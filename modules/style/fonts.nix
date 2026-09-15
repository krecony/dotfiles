{
  pkgs,
  lib,
  ...
}:
let
  saira-semi-condensed = pkgs.stdenv.mkDerivation {
    pname = "saira-semi-condensed";
    version = "1.0";

    src = pkgs.fetchzip {
      url = "https://www.omnibus-type.com/wp-content/uploads/Saira-Semi-Condensed.zip";
      hash = "sha256-5FH9O5rINVC8/aA4xC/SsefPBwGfqzmu/+K7A89G+JU=";
    };

    installPhase = ''
      runHook preInstall

      install -m444 -Dt $out/share/fonts/truetype ttf/*.ttf

      runHook postInstall
    '';

    meta = {
      homepage = "https://www.omnibus-type.com/fonts/saira-semi-condensed/";
      license = pkgs.lib.licenses.ofl;
    };
  };
in
{
  stylix.fonts = with pkgs; {
    serif = {
      name = "Dejavu Serif";
      package = dejavu_fonts;
    };

    sansSerif = {
      name = "SairaSemiCondensed";
      package = saira-semi-condensed;
    };

    monospace = {
      name = "JetBrainsMono";
      package = jetbrains-mono;
    };

    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  fonts = {
    # some extra fonts
    packages =
      with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        hermit
      ]
      ++ lib.filter lib.attrsets.isDerivation (lib.attrValues pkgs.nerd-fonts); # all nerd-fonts
  };
}
