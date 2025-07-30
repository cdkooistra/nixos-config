{ config, lib, pkgs, ... }:

{
  options = {
    amd.enable = lib.mkEnableOption "enable AMD drivers";
  };

  config = lib.mkIf config.amd.enable {
    services.xserver.videoDrivers = ["amdgpu"];
  };
}
