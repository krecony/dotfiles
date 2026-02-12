{ pkgs, ... }:
{
  fonts = {
    packages =
      with pkgs;
      let
        saira-semi-condensed = stdenv.mkDerivation {
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
      [
        jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        hermit
        dejavu_fonts
        saira-semi-condensed
      ]
      ++ lib.filter lib.attrsets.isDerivation (lib.attrValues pkgs.nerd-fonts); # all nerd-fonts
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
        sansSerif = [ "SairaSemiCondensed" ];
        serif = [ "Dejavu Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
