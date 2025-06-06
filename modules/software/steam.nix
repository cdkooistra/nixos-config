{ config, lib, pkgs, ... }:

{
  options.software = {
    steam.enable = lib.mkEnableOption "enable Steam + compatibility layers";
    xone.enable = lib.mkEnableOption "enable xone drivers";
  };

  config = lib.mkIf config.software.steam.enable (lib.mkMerge [
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

    (lib.mkIf config.software.xone.enable {
      hardware.xone.enable = true;
    })
  ]);
}