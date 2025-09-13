{ systemOptions, lib, config, pkgs, inputs, ... }:

{
  dconf = {
    enable = true; 
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ 
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" 
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" 
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/" 
          ];
      };

      "custom-keybindings/custom0" = {
        binding = "<Super>b";
        command = "zen";
        name = "Launch Zen";
      };

      "custom-keybindings/custom1" = {
        binding = "<Super>c";
        command = "code";
        name = "Launch VSCode";
      };

      "custom-keybindings/custom2" = {
        binding = "<Super>f";
        command = "nautilus";
        name = "Launch Files";
      };

      "org/gnome/mutter/keybindings" = {
        switch-monitor = [ ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
      };

      "org/gnome/desktop/interface" = {
        icon-theme = "Papirus";
      };

      "org/gnome/shell/extensions/azwallpaper" = {
        slideshow-directory = "${config.home.homeDirectory}/.local/share/backgrounds";
        slideshow-slide-duration = "(1, 30, 0)"; # hours, minutes, seconds
        slideshow-queue-reshuffle-on-complete = true;
        slideshow-pause = false;
      };
      
    };
  };
}
