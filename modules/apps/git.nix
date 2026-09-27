{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    lazygit
  ];

  hm = {
    services = {
      gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        pinentry.package = pkgs.pinentry-gnome3;
      };
    };
    home.packages = [ pkgs.gnupg ];

    programs.git = {
      enable = true;
      signing = {
        signByDefault = true;
        format = "openpgp";
        signer = lib.getExe pkgs.gnupg;
        key = "6A27D3624AF1B1133A3DA560D6D9B3E58A21AAE6";
      };
      settings = {
        user = {
          name = "krecony";
          email = "55319736+krecony@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
    };
  };
}
