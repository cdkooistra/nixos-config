{
  config,
  lib,
  ...
}:

{
  options.graphics.amd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable AMD drivers";
    };
  };

  config = lib.mkIf config.graphics.amd.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
