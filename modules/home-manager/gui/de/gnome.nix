{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf osConfig.gui.de.gnome.enable {
    home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    # Add home dirs to sidebar
    xdg = {
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
        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.hm.gvariant.mkTuple [
              "xkb"
              "us+euro"
            ])
            (lib.hm.gvariant.mkTuple [
              "xkb"
              "us+alt-intl"
            ])
          ];
        };

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
          command = "flatpak run app.zen_browser.zen";
          name = "Launch Zen";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>c";
          command = "zeditor";
          name = "Launch Zed";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super>f";
          command = "nautilus";
          name = "Launch Files";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          binding = "<Super>t";
          command = "alacritty";
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
  };
}
