{
  pkgs,
  ...
}:

{
  imports = [
    ./apps
    ./desktops
    ./dev.nix
    ./zed.nix
    ./utils.nix
    ../../../config/ssh.nix
  ];

  # default user settings
  home = {
    username = "connor";
    homeDirectory = "/home/connor";
    stateVersion = "25.05";
    packages = with pkgs; [ vscode ];
    # sessionVariables = {
    #   EDITOR = "code --wait";
    # };
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
        pull.rebase = false;
      };
    };

    alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "#282c34";
            foreground = "#abb2bf";
          };
          cursor = {
            text = "#282c34";
            cursor = "#abb2bf";
          };
          selection = {
            text = "CellForeground";
            background = "#3e4451";
          };
          normal = {
            black = "#282c34";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#e5c07b";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
            white = "#abb2bf";
          };
          bright = {
            black = "#5c6370";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#e5c07b";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
            white = "#ffffff";
          };
        };
      };
    };
  };
}
