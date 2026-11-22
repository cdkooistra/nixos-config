{
  lib,
  osConfig,
  mkLink,
  ...
}:

# these settings makes an out-of-(nix-)store symlink of config files,
# using the mkLink function defined in ../gui/default.nix.
# this allows the UI to make changes to a symlink, which is in fact
# the configuration tracked by the repo.
#
# force = true to make sure when the actual file exists, it is overwritten by
# what is inside the repo.

{
  config = lib.mkIf osConfig.gui.de.dux.enable {
    xdg.configFile = {
      "dms/settings.json" = mkLink "de/dux/settings.json";
    }
    // lib.optionalAttrs (osConfig.gui.de.dux.compositor == "niri") {
      "niri/dms/binds.kdl" = mkLink "de/dux/binds.kdl";
    };
  };
}
