{
  config,
  pkgs,
  ...
}:

{
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  # Add home dirs to sidebar
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_APPLICATIONS_DIR = "${config.home.homeDirectory}/Applications";
        XDG_CODE_DIR = "${config.home.homeDirectory}/Code";
      };
    };

    configFile."gtk-3.0/bookmarks" = {
      text = ''
        file://${config.home.homeDirectory}/Applications Applications
        file://${config.home.homeDirectory}/Code Code
        file://${config.home.homeDirectory}/Documents Documents
        file://${config.home.homeDirectory}/Downloads Downloads
        file://${config.home.homeDirectory}/Music Music
        file://${config.home.homeDirectory}/Pictures Pictures
        file://${config.home.homeDirectory}/Videos Videos
      '';
    };
  };

  # Handle dconfg settings
  dconf = {
    enable = true;
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        ];
      };

      "org/gnome/desktop/notifications/application/spotify" = {
        enable = false;
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>b";
        command = "zen";
        name = "Launch Zen";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>c";
        command = "code";
        name = "Launch VSCode";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<Super>f";
        command = "nautilus";
        name = "Launch Files";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        binding = "<Super>t";
        command = "kgx";
        name = "Launch Terminal";
      };

      "org/gnome/mutter/keybindings" = {
        switch-monitor = [ ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Super>q" ];
      };

      "org/gnome/desktop/interface" = {
        icon-theme = "Papirus";
      };

    };
  };
}
