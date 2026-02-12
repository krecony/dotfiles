{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.security.clamav;

  scan =
    paths:
    pkgs.writeShellScript "scan.sh" ''
      # Adapted from https://gist.github.com/Pavel-Novikov/0c7486b59f9237d339f562d30b05e56e
      set -euo pipefail
      umask 077

      export LOG="/var/log/clamav/scan.log"

      touch "$LOG"
      chmod 640 "$LOG"
      chown clamav:clamav "$LOG"

      export SUMMARY_FILE=$(mktemp)
      export FIFO_DIR=$(mktemp -d)
      export FIFO="$FIFO_DIR/log"

      export SCAN_STATUS
      export INFECTED_SUMMARY
      export XUSERS

      mkfifo "$FIFO"
      tail -f "$FIFO" | tee -a "$LOG" "$SUMMARY_FILE" &

      echo "------------ SCAN START ------------" > "$FIFO"
      echo "Running scan on $(date)" > "$FIFO"
      echo "Scanning ${concatStringsSep " " paths}" > "$FIFO"
      ${getExe' pkgs.clamav "clamdscan"} --infected --multiscan --fdpass --stdout ${concatStringsSep " " paths} > >(grep -vE 'WARNING|ERROR|^$' > "$FIFO")
      SCAN_STATUS=$?

      echo > "$FIFO"

      INFECTED_SUMMARY=$(cat "$SUMMARY_FILE" | grep "Infected files")

      rm "$SUMMARY_FILE"
      rm "$FIFO"
      rmdir "$FIFO_DIR"

      if [[ "$SCAN_STATUS" -ne "0" ]] ; then
        echo "Virus signature found - $INFECTED_SUMMARY" | ${getExe' pkgs.systemd "systemd-cat"} -t clamav -p emerg

        loginctl list-sessions --no-legend | while read -r _ uid user seat tty; do
          XDG_RUNTIME_DIR="/run/user/$uid"
          DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

          [[ -S "$XDG_RUNTIME_DIR/bus" ]] || continue

          ${getExe' pkgs.systemd "run0"} -u "$user" -- \
            /bin/sh -lc '
              export INFECTED_SUMMARY="'"$INFECTED_SUMMARY"'"
              export XDG_RUNTIME_DIR="'"$XDG_RUNTIME_DIR"'"
              export DBUS_SESSION_BUS_ADDRESS="'"$DBUS_SESSION_BUS_ADDRESS"'"

              ${getExe' pkgs.libnotify "notify-send"} \
                -u critical \
                -t 0 \
                -i security-high \
                -h string:category:security \
                -h string:x-canonical-private-synchronous:clamav-alert \
                -a clamav \
                "Virus signature(s) where found" \
                "$INFECTED_SUMMARY"
              '
          done
        fi
    '';

  virusEvent = pkgs.writeShellScript "virusEvent" ''
    ALERT="SIGNATURE FOUND: ''${CLAM_VIRUSEVENT_VIRUSNAME:-''${CLAM_VIRUSEVENT_SIGNATURE:-Unknown virus}} in ''${CLAM_VIRUSEVENT_FILENAME:-Unknown file}"
    echo "$ALERT" | ${getExe' pkgs.systemd "systemd-cat"} -t clamav -p emerg
  '';

  virusNotify = pkgs.writeShellScript "virusNotify" ''
    ${getExe' pkgs.systemd "journalctl"} -f -o json -t clamav -n0 | \
      while IFS= read -r line; do \
        priority=$(jq -r '.PRIORITY // empty' <<<"$line")
        msg=$(jq -r '.MESSAGE // empty' <<<"$line")

        if [[ "$priority" -le 1 ]]; then
          if [[ "$msg" == *"SIGNATURE FOUND"* ]] then
          ${getExe' pkgs.libnotify "notify-send"} \
            -u critical \
            -t 0 \
            -i security-high \
            -h string:category:security \
            -h string:x-canonical-private-synchronous:clamav-alert \
            -a clamav \
            "Virus signature was found!" \
            "$msg"
          fi
        fi
      done
  '';
in
{
  options.security.clamav = {
    enable = mkEnableOption "enables ClamAV the antivirus scanner";
    scan = {
      daily = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        directories = mkOption {
          type = with lib.types; listOf str;
          default = [
            "/home/*/download"
            "/home/*/.local/share"
            "/tmp"
            "/var/tmp"
          ];
        };
      };
      weekly = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        directories = mkOption {
          type = with lib.types; listOf str;
          default = [
            "/home"
            "/var/lib"
            "/tmp"
            "/etc"
            "/var/tmp"
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.clamav
    ];

    systemd =
      let
        mkClamScan = name: interval: paths: {
          services."clamdscan-${name}" = {
            description = "ClamAV ${name} virus scanner";
            after = [ "clamav-freshclam.service" ];
            wants = [ "clamav-freshclam.service" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${scan paths}";
              Slice = "system-clamav.slice";
              Nice = 5;
              IOWeight = 75;
            };
          };
          timers."clamdscan-${name}" = {
            description = "Timer for ClamAV ${name} virus scanner";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "${interval}";
              Unit = "clamdscan-${name}.service";
            };
          };
        };
      in
      mkMerge [
        (mkIf cfg.scan.daily.enable (mkClamScan "daily" "*-*-* 21:00:00" cfg.scan.daily.directories))
        (mkIf cfg.scan.weekly.enable (mkClamScan "weekly" "Sun 21:00:00" cfg.scan.weekly.directories))
      ];

    hm.systemd.user.services.clamav-notify = {
      Unit.Description = "Notifies the user on VirusEvent";
      Service = {
        ExecStart = "${virusNotify}";
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };

    services.clamav = {
      daemon = {
        enable = true;
        settings = {
          LogFileMaxSize = "50M";
          LogTime = true;
          LogRotate = true;
          ExtendedDetectionInfo = true;
          MaxThreads = 8;

          OnAccessIncludePath = [
            "/home"
            "/var/tmp"
          ];
          OnAccessPrevention = false;
          OnAccessExtraScanning = true;
          OnAccessExcludeUname = "clamav";
          VirusEvent = "${virusEvent}";
        };
      };

      # on-access scanning
      clamonacc.enable = true;

      # updating the malware database (freshclam)
      updater = {
        enable = true;
        settings = {
          LogFileMaxSize = "10M";
          Bytecode = true;
          LogTime = true;
        };
      };
    };
  };
}
