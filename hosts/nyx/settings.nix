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
      bootloader = "systemd-boot"; # change to lanzaboote after creating keys
      quietBoot = false;
    };
    impermanence = {
      enable = true;
      resetRoot = true; # enable after verifying all persistent mounts
    };
    nvidia = {
      enable = true; # enable after setting both measured PCI bus IDs
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };
  # Let kernel PCI probing choose i915/xe; do not inherit a forced i915 initrd load.
  hardware.intelgpu.loadInInitrd = false;
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  style = {
    desktopEnvironment = "gnome";
    displayServer = "wayland";
    theme = "everforest";
  };
  preferences.browser = pkgs.firefox;
  # The reviewed Home Manager pin is from the 25.05 era. Revisit only for a fresh aligned install.
  hm.home.stateVersion = "25.05";

  # Provision before nixos-install; this survives reset and works with mutableUsers=false.
  users.users.${config.core.user} = {
    initialHashedPassword = lib.mkForce "$y$j9T$Mecu6dd12rJtcZO7K3Dnb1$A2bSTBvYuwjLw4guSKVXIlhwoBvuvGZmxV6mygZ5rT.";
  };
  hardening.sops.enable = false; # provision the age identity before enabling SOPS/VPN
  services.openssh.enable = lib.mkForce false; # opt in if remote access is required
  # services.fwupd.enable = true;
  # services.power-profiles-daemon.enable = true;
  # services.tlp.enable = lib.mkForce false;

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
  environment.systemPackages = with pkgs; [
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

  preferences.editor = inputs.nvim.packages.${system}.default;
	apps.nix-locate.enable = true;
}
