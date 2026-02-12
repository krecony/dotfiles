{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.sql;
in
{
  options.programs.sql = {
    postgresql.enable = mkEnableOption "enables postresql";
    pgadmin.enable = mkEnableOption "enables pgadmin";
    mysql.enable = mkEnableOption "enables mysql";
  };
  config.services = {
    mysql = {
      inherit (cfg.mysql) enable;
      package = pkgs.mariadb;
    };

    postgresql = {
      inherit (cfg.postgresql) enable;
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
        # ipv4
        host  all      all     127.0.0.1/32   trust
        # ipv6
        host all       all     ::1/128        trust
      '';
      enableTCPIP = true;
      settings.port = 5432;
    };

    pgadmin = {
      inherit (cfg.pgadmin) enable;
      initialEmail = "admin@example.com";
      initialPasswordFile = "/var/secrets/pgadminpass";
      port = 5050;
      settings.authentication = ''
        # Allow local socket connections
        local   all   all                          trust

        # Allow IPv4 localhost
        host    all   all   127.0.0.1/32           trust

        # Allow IPv6 localhost
        host    all   all   ::1/128                trust
      '';
    };
  };
}
