{
  config,
  lib,
  ...
}:

{
  options.software.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable docker";
    };
  };

  config = lib.mkIf config.software.docker.enable {
    hardware.nvidia-container-toolkit.enable = config.nvidia.enable or false;

    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        daemon.settings = {
          features.cdi = true;
        };
      };
    };

    users.users.connor.extraGroups = [ "docker" ];
  };
}
