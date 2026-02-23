{
  lib,
  pkgs,
  ...
}:
{
  time = {
    timeZone = "Europe/Warsaw";
    hardwareClockInLocalTime = false;
  };

  i18n =
    let
      en = "en_GB.UTF-8";
      pl = "pl_PL.UTF-8";
    in
    {
      defaultLocale = en;
      extraLocaleSettings = {
        LANG = en;
        LC_ADDRESS = pl;
        LC_IDENTIFICATION = pl;
        LC_MEASUREMENT = pl;
        LC_MONETARY = pl;
        LC_NAME = pl;
        LC_NUMERIC = pl;
        LC_PAPER = pl;
        LC_TELEPHONE = pl;
        LC_TIME = pl;
      };
    };

  console.keyMap = "pl2";

  services.upower.enable = true;

  environment = {
    systemPackages = with pkgs; [
      git
      appimage-run
    ];
  };

  boot.binfmt.registrations = lib.genAttrs [ "appimage" "AppImage" ] (ext: {
    recognitionType = "extension";
    magicOrExtension = ext;
    interpreter = "${lib.getExe' pkgs.appimage-run "appimage-run"}";
  });

  programs = {
    java = {
      enable = true;
      package = pkgs.openjdk25;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        libXcomposite
        libXtst
        libXrandr
        libXext
        libX11
        libXfixes
        libGL
        libva
        pipewire
        libxcb
        libXdamage
        libxshmfence
        libXxf86vm
        libelf

        libXinerama
        libXcursor
        libXrender
        libXScrnSaver
        libXi
        libSM
        libICE
        libXft

        glib
        gtk2
      ];
    };
  };

  services = {
    openssh.enable = true;
  };
}
