{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
{
  core = {
    user = "krecony";
    flakePath = "/home/krecony/dotfiles";
    intel.enable = false;
    boot.bootloader = "lanzaboote";
    impermanence = {
      enable = true;
      resetRoot = true;
    };
    nvidia = {
      enable = true;
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
    nix.unfreePackages = [
      "obsidian"
      "spotify"
      "espresso"
    ];
  };

  gaming.minecraft = {
    enable = true;
    mcsr = true;
  };

  preferences = {
    editor = inputs.nvim.packages.${system}.default;
    pdf = pkgs.papers;
    video = pkgs.showtime;
    image = pkgs.loupe;
    browser = pkgs.mullvad-browser;
    secondaryBrowser = pkgs.firefox;
  };

  apps = {
    vscode.enable = true;
    nix-locate.enable = true;
    podman.enable = true;
  };

  style = {
    desktopEnvironment = "gnome";
    displayServer = "wayland";
    theme = "everforest";
  };

  settings.userPackages = with pkgs; [
    proton-pass
    protonmail-desktop

    libreoffice-qt
    obsidian
    spotify

    espresso
  ];

  hardware.intelgpu.loadInInitrd = false;
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  users.users.${config.core.user} = {
    initialHashedPassword = lib.mkForce "$y$j9T$Mecu6dd12rJtcZO7K3Dnb1$A2bSTBvYuwjLw4guSKVXIlhwoBvuvGZmxV6mygZ5rT.";
  };
  hardening.sops.enable = false;
  services.openssh.enable = lib.mkForce false;

  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = lib.mkForce false;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKey = "suspend";
  };
  systemd.sleep.settings.Sleep = {
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  networking.firewall.checkReversePath = false;
  services.fprintd.enable = true;

  services.usbguard.rules = lib.concatStringsSep "\n" [
    ''allow id 06cb:00f9 serial "a70dece416c2"'' # fingerprint reader
    ''allow id 30c9:00f4 serial "01.00.00"'' # camera
    ''allow id 2ce3:9563 serial ""'' # smartcard reader
  ];
  # reduce time available to auth sudo with fingerprint
  security.pam.services.sudo.rules.auth.fprintd.settings.timeout = 10;

  environment.systemPackages = with pkgs; [
    proton-vpn
    sbctl
    cryptsetup
    btrfs-progs
    nvme-cli
    pciutils
    usbutils
    tpm2-tools
    alsa-utils
    mokutil
  ];

}
