{ config, lib, pkgs, ... }:

{
  options = {
    software.docker.enable = lib.mkEnableOption "enable docker";   
  };

  config = lib.mkIf config.software.docker.enable {
    hardware.nvidia-container-toolkit.enable = config.nvidia.enable or false;

    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        features.cdi = true;
      };
    };

    users.users.connor.extraGroups = [ "docker" ];

  };
}
