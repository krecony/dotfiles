{
  pkgs,
  user,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.core.audio;
in
{
  options.core.audio = {
    enable = mkOption {
      type = types.bool;
      default = elem "desktop" config.core.capabilities;
      example = false;
      description = "Enables audio on the device";
    };
    enableAudioProduction = mkEnableOption "Enables audio production features";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;
      jack.enable = cfg.enableAudioProduction;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    environment.systemPackages =
      with pkgs;
      [ pavucontrol ]
      ++ (
        if cfg.enableAudioProduction then
          [
            libjack2
            jack2
            qjackctl
            libjack2
            jack2
            qjackctl
            jack_capture
          ]
        else
          [ ]
      );

    users.users.${user}.extraGroups = [ "audio" ];

    musnix = {
      enable = cfg.enableAudioProduction;
      soundcardPciId = "00:1f.3";
    };

    environment.variables.PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
  };
}
