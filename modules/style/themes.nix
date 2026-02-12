pkgs: {
  everforest = {
    wallpaper = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Apeiros-46B/everforest-walls/refs/heads/main/nature/fog_forest_alt_1.png";
      sha256 = "sha256-IeQzvScaS107R+639JzH/Jaxo4Vp0G+wpAm3ufoYHbY=";
    };
    scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    polarity = "dark";
    cursor = {
      normal = {
        size = 24;
        name = "Bibata-Modern-Classic";
        package = pkgs.runCommand "moveUp" { } ''
          mkdir -p $out/share/icons
          ln -s ${
            pkgs.fetchzip {
              url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.6/Bibata-Modern-Classic.tar.xz";
              hash = "sha256-jpEuovyLr9HBDsShJo1efRxd21Fxi7HIjXtPJmLQaCU=";
            }
          } $out/share/icons/Bibata-Modern-Classic
        '';
      };
      hypr = rec {
        size = 24;
        name = "Bibata-Modern-Classic-Hyprland";

        # Because the hyprcursor has the same name as the normal one,
        # things go wrong so we change the manifest file :)
        package = pkgs.stdenv.mkDerivation {
          name = "${name}-patched";
          nativeBuildInputs = [ pkgs.coreutils ];

          src = pkgs.fetchzip {
            url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/1.0/hypr_Bibata-Modern-Classic.tar.gz";
            hash = "sha256-Uv+96EieGBq6cJNWjoJEHPy/MshbHts+OBow7rWgBSM=";
            stripRoot = true;
          };

          buildPhase = ''
            sed -i "s/^name = .*/name = ${name}/" manifest.hl
          '';

          installPhase = ''
            mkdir -p $out
            cp -r . $out/
          '';
        };
      };
    };
    autoEnable = true;
    targets = {
      hm = [
        "vim"
        "firefox"
        "neovim"
        "hyprlock"
        "hyprland"
        "starship"
      ];
    };
  };
}
