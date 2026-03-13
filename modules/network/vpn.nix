{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.network.vpn;

  vpnScript = lib.readFile ./vpn.sh;

  serverOpts = _: {
    options = {
      publicKey = mkOption {
        type = types.str;
        default = "";
      };
      autostart = mkOption {
        type = types.bool;
        default = false;
      };
      endpoint = mkOption {
        type = types.str;
        default = "";
        example = "255.255.255.255:12345";
      };
      privateKeyFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/protonvpn/server.key";
      };
    };
  };
in
{
  options.network.vpn = {
    enable = mkEnableOption "enables the vpn";

    useOfficialApp = mkOption {
      type = lib.types.bool;
      default = true;
      description = "uses pkgs.protonvpn-gui";
    };

    disabledIPs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    dns = mkOption {
      type = types.listOf types.str;
      default = "1.1.1.1";
    };
    address = mkOption {
      type = types.listOf types.str;
      default = [ "1.1.1.1" ];
    };
    servers = mkOption {
      type = types.attrsOf (types.submodule serverOpts);
      default = { };
      example = {
        server1 = {
          autostart = true;
          pubKey = "11111111111111111111111111111111111111111111";
          endpoint = "255.255.255.255:12345";
        };
      };
      description = ''
        List of server definitions.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      networking.firewall.checkReversePath = false;
      systemd.services.NetworkManager-wait-online.enable = true;
    }
    # official app
    (mkIf cfg.useOfficialApp {
      environment.systemPackages = with pkgs; [
        wireguard-tools
        protonvpn-gui
      ];

      hm.systemd.user.services.protonvpn-autostart = {
        Unit = {
          Description = "Starts ProtonVPN";
          Requires = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          RemainAfterExit = true;
          Type = "simple";
          ExecStart = [
            "${lib.getExe' pkgs.protonvpn-gui "protonvpn-app"}"
          ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
    # custom solution
    (mkIf (!cfg.useOfficialApp) {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "vpn" vpnScript)
      ];

      networking = {
        wg-quick.interfaces =
          let
            disabled = map (ip: if hasInfix "/" ip then ip else "${ip}/32") cfg.disabledIPs;
            IPs = concatStringsSep " " disabled;
            tableID = "200";
            tailscaleRules = optionalString config.network.tailscale.enable ''
              ip rule add to 100.64.0.0/10 lookup 52 priority 90 || true
              ip -6 rule add to fd7a:115c:a1e0::/48 lookup 52 priority 90 || true
            '';
            tailscaleRulesCleanup = optionalString config.network.tailscale.enable ''
              ip rule del to 100.64.0.0/10 lookup 52 priority 90 || true
              ip -6 rule del to fd7a:115c:a1e0::/48 lookup 52 priority 90 || true
            '';

            mkInterface =
              name: values:
              nameValuePair name {
                inherit (values) autostart privateKeyFile;
                inherit (cfg) dns address;
                listenPort = 51820;
                mtu = 1280;

                peers = [
                  {
                    inherit (values) publicKey endpoint;
                    allowedIPs = [
                      "0.0.0.0/0"
                      "::/0"
                    ];
                  }
                ];

                preUp = ''
                  set -euo pipefail

                  gw=$(ip -4 route show default | ${getExe' pkgs.gawk "awk"} '/default/ {print $3; exit}') || gw=""
                  dev=$(ip -4 route show default | ${getExe' pkgs.gawk "awk"} '/default/ {print $5; exit}') || dev=""

                  if [ -n "$gw" ] && [ -n "$dev" ]; then
                    ip route flush table ${tableID} || true
                    ip route add default via "$gw" dev "$dev" table ${tableID}
                  else
                    echo "Error: no IPv4 default gateway found before VPN — cannot set exclusion table" >&2
                    exit 1
                  fi
                '';

                postUp = ''
                  set -euo pipefail

                  ${tailscaleRules}

                  for ip in ${IPs}; do
                    ip rule add to "$ip" lookup ${tableID} priority 100 || true
                  done
                '';

                postDown = ''
                  set -euo pipefail

                  ${tailscaleRulesCleanup}

                  for ip in ${IPs}; do
                    ip rule del to "$ip" lookup ${tableID} priority 100 || true
                  done

                  ip route flush table ${tableID} || true
                '';
              };
          in
          attrsets.mapAttrs' mkInterface cfg.servers;
      };
    })
  ]);
}
