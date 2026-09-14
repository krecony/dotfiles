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
  gaming.lutris.enable = true;

  hardening = {
    disableSUIDs = true;
    nix-mineral.enable = true;
  };

  powerManagement.enable = true;

  core = {
    user = "krecony";
    flakePath = "/home/krecony/dotfiles";
    boot = {
      encryptedBootPartition = true;
      quietBoot = true;
    };

    nix.unfreePackages = [
      "github-copilot-cli"
      "obsidian"
      "spotify"
      "pycharm"
      "idea"
      "cursor"
    ];
  };

  preferences = {
    editor = inputs.nvim.packages.${system}.default;
    pdf = pkgs.papers;
    video = pkgs.showtime;
    image = pkgs.loupe;
    browser = pkgs.mullvad-browser;
    secondaryBrowser = pkgs.firefox;
  };

  net = {
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

  apps = {
    vscode.enable = true;
    nix-locate.enable = true;
  };

  settings = {
    userPackages = with pkgs; [
      proton-pass
      protonmail-desktop

      scenebuilder

      code-cursor

      libreoffice-qt
      obsidian
      # anki
      spotify

      # FIXME: wait for vesktop's electron version to be bumped
      # vesktop # discord client

      jetbrains.pycharm
      jetbrains.idea

      github-copilot-cli

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

  apps.podman.enable = true;

  # FIXME: workaround for https://github.com/NixOS/nixpkgs/issues/536623 until it gets fixed
  nixpkgs.overlays = [
    (final: _: {
      pnpm_10_29_2 = final.pnpm_10;
    })
  ];
}
