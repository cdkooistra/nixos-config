{ config, lib, pkgs, ... }:

{
  options.graphics = {
    amd.enable = lib.mkEnableOption "enable AMD drivers";
  };

  config = lib.mkIf config.graphics.amd.enable {
    services.xserver.videoDrivers = ["amdgpu"];
  };
}
