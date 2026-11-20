{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf osConfig.desktops.dux.enable {
    # this settings makes an out-of-(nix-)store symlink of said settings.json.
    # this allows the UI to make changes to a symlink, which is in fact
    # the settings.json tracked by the repo.
    #
    # force = true to make sure when the actual .json exists, it is overwritten by
    # what is inside the repo settings.json.
    xdg.configFile."dms/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos-config/public/modules/home-manager/desktops/dux/settings.json";
      force = true;
    };
  };
}
