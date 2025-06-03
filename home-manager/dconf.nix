{ config, lib, inputs, ... }:

{
  dconf = {
    enable = true; 
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" ];
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

      "org/gnome/mutter/keybindings" = {
        switch-monitor = [ ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
      };
    };
  };
}
