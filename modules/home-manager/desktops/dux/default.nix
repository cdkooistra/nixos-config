{
  config,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf osConfig.desktops.dux.enable {
    # these settings makes an out-of-(nix-)store symlink of config files.
    # this allows the UI to make changes to a symlink, which is in fact
    # the configuration tracked by the repo.
    #
    # force = true to make sure when the actual file exists, it is overwritten by
    # what is inside the repo.

    xdg.configFile."niri/dms/binds.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos-config/public/modules/home-manager/desktops/dux/binds.kdl";
      force = true;
    };

    xdg.configFile."dms/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos-config/public/modules/home-manager/desktops/dux/settings.json";
      force = true;
    };
  };
}
