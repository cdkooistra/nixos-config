{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gaming.launchers;
  utils = config.gaming.utils;
in
{
  options.gaming.launchers = {
    steam.enable = lib.mkEnableOption "Steam";
    prism.enable = lib.mkEnableOption "Prism launcher (Minecraft)";
    bottles.enable = lib.mkEnableOption "Bottles (Wine/Proton launcher)";
    lutris.enable = lib.mkEnableOption "Lutris launcher";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        gamescopeSession.enable = utils.gamescope.enable;

        package = pkgs.steam.override {
          extraPkgs =
            pkgs:
            with pkgs;
            lib.concatLists [
              (lib.optional utils.gamemode.enable gamemode)
              (lib.optional utils.gamescope.enable gamescope)
            ];
        };
      };
    })
    {
      environment.systemPackages =
        with pkgs;
        lib.concatLists [
          (lib.optionals cfg.steam.enable [
            steam-run
            steamcmd
          ])
          (lib.optional cfg.prism.enable prismlauncher)
          (lib.optional cfg.bottles.enable bottles)
          (lib.optional cfg.lutris.enable lutris)
        ];
    }
  ];
}
