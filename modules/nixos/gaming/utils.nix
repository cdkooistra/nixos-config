{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.gaming.utils;
in
{
  options.gaming.utils = {
    gamescope.enable = lib.mkEnableOption "enable gamescope";
    gamemode.enable = lib.mkEnableOption "enable gamemode";
    mangohud.enable = lib.mkEnableOption "enable MangoHUD";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.gamescope.enable {
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

    })

    (lib.mkIf cfg.gamemode.enable {
      programs.gamemode.enable = true;

      # TODO: this is a hardcoded user
      users.users.connor.extraGroups = [ "gamemode" ];
    })

    {
      environment.systemPackages =
        with pkgs;

        lib.optional cfg.mangohud.enable mangohud;
    }
  ];
}
