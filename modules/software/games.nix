{ config, lib, pkgs, ... }:

{
  options.software = {
    steam.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Steam + compatibility layers";
    };
    xone.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable xone drivers";
    };
    prism.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Prism Launcher";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.software.steam.enable {
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
    })

    (lib.mkIf config.software.xone.enable {
      hardware.xone.enable = true;
    })

    (lib.mkIf config.software.prism.enable {
      environment.systemPackages = with pkgs; [
        prismlauncher
      ];
    })
    
  ];
}
