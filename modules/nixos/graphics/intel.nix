{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.graphics.intel;
in
{
  options.graphics.intel = {
    enable = lib.mkEnableOption "enable Intel drivers";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-vaapi-driver
      vpl-gpu-rt
    ];
  };
}
