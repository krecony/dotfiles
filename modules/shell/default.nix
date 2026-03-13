{
  pkgs,
  mkImports,
  ...
}:
{
  imports = mkImports [
    ./zsh.nix
    ./starship.nix
  ];

  environment.systemPackages = with pkgs; [
    ripgrep
    bat
    eza
    jq
    btop
    tldr
    microfetch
    fzf
    unzip
    killall
    qrcp
    libqalculate
    gcc
    ffmpeg
    busybox
    inetutils
    wl-clipboard
  ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };
}
