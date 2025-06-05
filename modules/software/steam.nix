{ config, lib, pkgs, ... }:

{
  options = {
    steam.enable = lib.mkEnableOption "enable Steam + compatibility layers";
    xone.enable = lib.mkEnableOption "enable xone drivers";
  };

  config = lib.mkIf config.steam.enable (lib.mkMerge [
    {
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;

        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            gamemode
            gamescope
          ];
        };
      };

      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        mangohud
        lutris
        bottles
      ];
    }

    (lib.mkIf config.xone.enable {
      hardware.xone.enable = true;
    })
  ]);
}