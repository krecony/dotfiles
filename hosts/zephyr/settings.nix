{
  lib,
  inputs,
  pkgs,
  system,
  config,
  ...
}:
{
  hardware = {
    enableRedistributableFirmware = true;
    audio = {
      enable = true;
      enableAudioProduction = true;
    };
  };

  hardening = {
    disableSUIDs = true;
    nix-mineral.enable = true;
  };

  powerManagement.enable = true;

  core = {
    user = "krecony";
    flakePath = "/home/krecony/dotfiles/";
  };

  preferences = {
    editor.package = inputs.nixvim.packages.${system}.default;
    pdf.package = pkgs.papers;
    video.package = pkgs.showtime;
    image.package = pkgs.loupe;
    browser.package = pkgs.mullvad-browser;
  };

  networking.vpn = {
    enable = false; # temporarily until i get sops working
    useOfficialApp = false;
    disabledIPs = [
      # nixos.wiki gets mad
      "172.67.75.217"
      "104.26.14.206"
      "104.26.15.206"
    ];
    dns = [ "10.2.0.1" ];
    address = [ "10.2.0.2/32" ];
    privateKeyDir = "/root/protonvpn-keys";
    servers = {
      warsaw = {
        publicKey = "wpfRQRhJirL++QclFH6SDhc+TuJJB4UxbCABy7A1tS4=";
        endpoint = "79.127.186.193:51820";
      };
      amsterdam = {
        autostart = true;
        publicKey = "afmlPt2O8Y+u4ykaOpMoO6q1JkbArZsaoFcpNXudXCg=";
        endpoint = "46.29.25.3:51820";
      };
    };
  };

  settings = {
    boot = {
      diskEncryption = true;
      quietBoot = true;
    };

    userPackages = with pkgs; [
      lmms
      brave

      scenebuilder

      libreoffice-qt
      obsidian
      anki
      spotify
      vesktop # discord client

      jetbrains.pycharm
      jetbrains.idea

      # pdf edditing with math
      xournalpp
      texliveFull

      # nice latex alternative
      typst
    ];

    nix.unfreePackages = [
      "obsidian"
      "spotify"
      "pycharm"
      "idea"
    ];
  };

  style = {
    theme = "everforest";
    desktopEnvironment.gnome.enable = true;
    displayServer.wayland.enable = true;
    widgets.ags.enable = false;
  };

  environment.systemPackages = with pkgs; [
    sof-firmware
    alsa-utils
  ];

  nixpkgs.overlays = [
    (
      _self: _super:
      let
        lmms-fix-pkgs = import inputs.lmms-nixpkgs { inherit system; };
      in
      {
        inherit (lmms-fix-pkgs) lmms;
      }
    )
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

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
