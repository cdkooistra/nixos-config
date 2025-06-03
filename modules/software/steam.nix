{ config, lib, pkgs, ... }:

{
  options = {
    steam.enable = lib.mkEnableOption "enable Steam + compatibility layers";
  };

  config = lib.mkIf config.steam.enable {
    
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

  };
}
