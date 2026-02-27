{
  pkgs,
  mkImports,
  ...
}:
{
  imports = mkImports [
    ./vpn.nix
  ];
  # reduce SECLEVEL to connect to wifi
  systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgs.writeText "openssl.cnf" ''
    openssl_conf = openssl_init
    [openssl_init]
    ssl_conf = ssl_sect
    [ssl_sect]
    system_default = system_default_sect
    [system_default_sect]
    CipherString = DEFAULT@SECLEVEL=0
  '';

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;

    networkmanager = {
      enable = true;
      dns = "none";
      wifi.macAddress = "random";
    };

    firewall.enable = true;

    nameservers = [ "1.1.1.1" ];
  };
}
