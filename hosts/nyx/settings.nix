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
    boot = {
      bootloader = "lanzaboote";
      quietBoot = true;
    };
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
    ];
  };

  nixpkgs.overlays = [ inputs.mac-style-plymouth.overlays.default ];

  boot = {
    plymouth = {
      enable = true;
      theme = "mac-style";
      themePackages = [ pkgs.mac-style-plymouth ];
    };
  };
  stylix.targets.plymouth.enable = false;

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

  # fingerprint reader
  services.usbguard.rules = ''allow id 06cb:00f9 serial "a70dece416c2"'';
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
