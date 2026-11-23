{
  config,
  lib,
  osConfig,
  ...
}:

# user-level half of the XDG integration, options live in nixos/system/xdg.nix.

let
  cfg = osConfig.system.xdg;
in
{
  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true; # exports the XDG_*_HOME variables

      userDirs = lib.mkIf cfg.userDirs.enable {
        enable = true;
        createDirectories = true;
        setSessionVariables = false;
        extraConfig = {
          APPLICATIONS = "${config.home.homeDirectory}/Applications";
          CODE = "${config.home.homeDirectory}/Code";
        }
        // cfg.userDirs.extra;
      };
    };
  };
}
