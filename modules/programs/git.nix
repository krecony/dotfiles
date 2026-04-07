{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    lazygit
  ];

  hm.programs.git = {
    enable = true;
    settings = {
      user = {
        name = "krecony";
        email = "55319736+krecony@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
    signing.format = "openpgp";
  };
}
