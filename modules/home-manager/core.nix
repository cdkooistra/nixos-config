{
  inputs,
  pkgs,
  ...
}:

{
  home = {
    username = "connor";
    homeDirectory = "/home/connor";
    stateVersion = "25.05";
    packages = [
      inputs.zen-browser.packages.${pkgs.system}.default
      pkgs.vscode
      pkgs.spotify
      pkgs.discord
      pkgs.obs-studio
      pkgs.anytype
      pkgs.slack
    ];
    sessionVariables = {
      EDITOR = "code --wait";
    };
  };

  programs = {
    # home-manager cli
    # this allows for rebuilding only hm config
    # instead of entire system config
    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        user = {
          name = "Connor Kooistra";
          email = "70811244+cdkooistra@users.noreply.github.com";
        };
      };
    };

    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    bash = {
      enable = true;
    };
  };
}
