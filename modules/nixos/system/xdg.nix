{
  config,
  lib,
  ...
}:

let
  cfg = config.system.xdg;
in
{
  options.system.xdg = {
    enable = lib.mkEnableOption "XDG integration between apps and the system";

    userDirs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      # consumed by Home Manager
      extra = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };

    defaultApplications = lib.mkOption {
      # per-host default apps
      type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal.enable = true;
    xdg.mime = {
      enable = true;
      defaultApplications = cfg.defaultApplications;
    };
    xdg.icons.enable = true;
    xdg.menus.enable = true;
    xdg.autostart.enable = true;
  };

}
