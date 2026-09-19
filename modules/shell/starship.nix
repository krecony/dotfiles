{ ... }:
{
  hm.programs.starship = {
    enable = true;

    settings = {
      format = ''$username$hostname$directory$git_branch$git_commit$git_state$git_status$nix_shell$jobs$line_break$python''${env_var.CONTAINER_ID}$character'';
      right_format = "$cmd_duration";

      # makes right_format be on the first line of prompt
      fill.symbol = " ";

      directory = {
        style = "fg:blue";
      };
      character = {
        success_symbol = "[❯](fg:purple)";
        error_symbol = "[❯](fg:red)";
        vimcmd_symbol = "[❮](fg:green)";
      };
      git_branch = {
        format = "[$branch]($style)";
        style = "fg:bright-black";
      };
      git_commit = {
        only_detached = true;
        tag_disabled = false;
        style = "fg:bright-black";
      };
      git_status = {
        # Both groups disappear completely when their variables are empty.
        format = "([*$conflicted$untracked$modified$staged$renamed$deleted$typechanged](fg:purple) )([$ahead_behind$stashed]($style) )";
        style = "fg:cyan";

        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        typechanged = "​";
        stashed = "≡";
      };
      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "fg:bright-black";
      };
      cmd_duration = {
        format = "[took $duration]($style) ";
        style = "fg:yellow";
      };
      python = {
        format = "[$virtualenv]($style) ";
        style = "fg:bright-black";
      };
			env_var.CONTAINER_ID = {
				variable = "CONTAINER_ID";
				description = "Displays name of the activated distrobox container";
				format = "[$env_value ]($style)";
				style = "bold green";
			};
    };
  };
}
