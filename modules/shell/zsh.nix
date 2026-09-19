{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  histFile = "$HOME/.cache/.zsh_history";
  histSize = 100000000;
  eza = getExe pkgs.eza;
  bat = getExe pkgs.bat;
  grep = getExe' pkgs.ripgrep "rg";
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
  realpath = getExe' pkgs.toybox "realpath";
  dirname = getExe' pkgs.toybox "dirname";
in
{
  programs.zsh.enable = true;
  hm.programs.zsh = {
    enable = true;
    enableCompletion = true;

    dotDir = config.hm.xdg.configHome + "/zsh";

    history = {
      size = histSize;
      save = histSize;
      ignoreAllDups = true;
      ignoreDups = true;
      path = histFile;
    };

    shellAliases = {
      l = "${eza} -la --color=always";
      ll = "${eza} -la --color=always";
      ls = "${eza} --git --group-directories-first -s extension --color=always";
      la = "${eza} -lah --tree --group-directories-first --color=always";
      lt = "${eza} --icons --tree --group-directories-first --color=always";
      cat = "${bat} -pp";
      kys = "shutdown now";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    };
    initContent =
      /* bash */ ''
        export ZSH_AUTOSUGGEST_STRATEGY=history

        source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
        autoload -Uz compinit && compinit || true

        eval "$(${lib.getExe pkgs.fzf} --zsh)"
        eval "$(${getExe pkgs.direnv} hook zsh)"


        # style fzf
        zstyle ':fzf-tab:*' fzf-flags \
          '--ansi' \
          '--height=80%' \
          '--layout=reverse' \
          '--border=rounded' \
          '--preview-window=border-rounded'

        zstyle ':fzf-tab:*' fzf-preview '
          if [[ -d $realpath ]]; then
            ${eza} --color=always --icons --oneline $realpath 2>/dev/null
          elif [[ -f $realpath ]]; then
            if ${grep} -Iq . "$realpath"; then
              ${bat} -n -P --color=always "$realpath"
            else
              print -P "%F{yellow}<BINARY%f %F{cyan}$(file -b $realpath)%f%F{yellow}%f>"
            fi
          fi'


        # Edit line in vim with ctrl-e:
        autoload edit-command-line; zle -N edit-command-line
        bindkey '^e' edit-command-line

        cpfile () {
          ${bat} -pp $1 | ${wl-copy}
        }

        store () {
          ${realpath} $(where "$1")
        }

        goto () {
          cd $(${dirname} $(store "$1"))
        }

        zsh-defer source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        zsh-defer source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        zsh-defer source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zsh-defer source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
        zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        zsh-defer source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
      ''
      + (
        if config.hm.programs.starship.enable then
          ''
            eval "$(${lib.getExe config.hm.programs.starship.package} init zsh)"
          ''
        else
          ""
      );

  };
}
