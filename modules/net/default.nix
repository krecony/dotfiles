{
  mkImports,
  ...
}:
{
  imports = mkImports [
    ./vpn.nix
    ./tailscale.nix
  ];

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;

    networkmanager = {
      enable = true;
      dns = "none";
      wifi.macAddress = "random";
      wifi.powersave = false;
    };

    firewall.enable = true;

    nameservers = [ "1.1.1.1" ];
  };
}
