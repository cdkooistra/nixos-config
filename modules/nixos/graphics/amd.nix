{
  config,
  lib,
  ...
}:

let
  cfg = config.graphics.amd;
in
{
  options.graphics.amd = {
    enable = lib.mkEnableOption "enable AMD drivers";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
