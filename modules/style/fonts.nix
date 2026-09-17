{
  pkgs,
  lib,
  ...
}:
{
  stylix.fonts = with pkgs; {
    serif = {
      name = "Dejavu Serif";
      package = dejavu_fonts;
    };

    sansSerif = {
      name = "Inter";
      package = inter;
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
