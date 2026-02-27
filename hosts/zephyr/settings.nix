{
  lib,
  inputs,
  pkgs,
  system,
  config,
  ...
}:
{
  gaming.steam.enable = true;

  security = {
    disableSUIDs = true;
    nix-mineral.enable = true;
  };

  powerManagement.enable = true;

  core = {
    user = "krecony";
    flakePath = "/home/krecony/dotfiles";
    capabilities = [
      "basic"
      "desktop"
      "development"
      "gaming"
    ];
    boot = {
      diskEncryption = true;
      quietBoot = true;
    };

    nix.unfreePackages = [
      "obsidian"
      "spotify"
      "pycharm"
      "idea"
    ];
  };

  preferences = {
    editor.package = inputs.nixvim.packages.${system}.default;
    pdf.package = pkgs.papers;
    video.package = pkgs.showtime;
    image.package = pkgs.loupe;
    browser.package = pkgs.mullvad-browser;
    secondaryBrowser.package = pkgs.librewolf;
  };

  network = {
    tailscale.enable = true;
    vpn = {
      enable = true;
      useOfficialApp = false;
      disabledIPs = [
        # nixos.wiki gets mad
        "172.67.75.217"
        "104.26.14.206"
        "104.26.15.206"
        "150.171.22.12"
      ];
      dns = [ "10.2.0.1" ];
      address = [ "10.2.0.2/32" ];
      servers = {
        amsterdam = {
          autostart = true;
          publicKey = "z/HHgg+ySsoW70+qihG2a++gxQBOXOFSCvscpcyEpg8=";
          endpoint = "169.150.196.132:51820";
          privateKeyFile = config.sops.secrets."protonvpn/amsterdam".path;
        };
        warsaw = {
          publicKey = "wpfRQRhJirL++QclFH6SDhc+TuJJB4UxbCABy7A1tS4=";
          endpoint = "79.127.186.193:51820";
          privateKeyFile = config.sops.secrets."protonvpn/warsaw".path;
        };
        berlin = {
          publicKey = "gW9yJRNQgnWPUB0qbRjRGrnvbYOhPqypmp1cW961XEM=";
          endpoint = "62.169.136.58:51820";
          privateKeyFile = config.sops.secrets."protonvpn/berlin-sc".path;
        };
        miami = {
          publicKey = "9JeNQPhigBfmRY0aAtRuqBklf8HVhTAyXZcv0I5vZBg=";
          endpoint = "146.70.51.210:51820";
          privateKeyFile = config.sops.secrets."protonvpn/miami".path;
        };
      };
    };
  };

  programs.vs-code.enable = true;

  settings = {
    userPackages = with pkgs; [
      proton-pass
      protonmail-desktop

      scenebuilder

      libreoffice-qt
      obsidian
      # anki
      spotify
      vesktop # discord client

      jetbrains.pycharm
      jetbrains.idea

      # pdf edditing with math
      # xournalpp
      # texliveFull

      # nice latex alternative
      typst
    ];
  };

  style = {
    theme = "everforest";
    desktopEnvironment = "gnome";
    displayServer = "wayland";
    widgets.ags.enable = false;
  };

  environment.systemPackages = with pkgs; [
    sof-firmware
    alsa-utils
  ];

  users.users.${config.core.user}.initialHashedPassword =
    lib.mkForce "$y$j9T$Bt8F5jl2GFtzJRZLtqsN61$ZkOYbAW3JjtERpj9CqnXCedKw8/c6l6IrJO180T7tsC";

  # huawei laptop go brrrr
  hm.systemd.user.services.alsa-fixes = {
    Unit.Description = "Enable Speakers";
    Service = {
      RemainAfterExit = true;
      Type = "oneshot";
      ExecStart = [
        "${lib.getExe' pkgs.alsa-utils "amixer"} -c 0 cset 'numid=69' 1"
        "${lib.getExe' pkgs.alsa-utils "amixer"} -c 0 cset 'numid=70' 1"
        "${lib.getExe' pkgs.alsa-utils "amixer"} -c 0 cset 'numid=71' 1"
        "${lib.getExe' pkgs.alsa-utils "amixer"} -c 0 cset 'numid=72' 1"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.podman.enable = true;
}
