{
  config,
  lib,
  tailscale,
  ...
}:

let
  service = "stirling";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Stirling PDF";

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory for tailscale sidecar state";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    services.stirling-pdf = {
      enable = true;
      # todo env files
    };

    age.secrets.${service}.file = cfg.secretFile;

    systemd.tmpfiles.rules = tailscale.mkDirectories {
      directory = cfg.dir;
    };

    # create tailscale sidecar container
    virtualisation.oci-containers.containers."${service}-tailscale" = tailscale.mkContainer {
      service = "${service}";
      directory = cfg.dir;
      networks = [ ];
      cfg = cfg.tailscale // {
        envfile = "${service}";
      };
    };

    # allow sidecar to communicate with host service
    networking.firewall.interfaces."docker0".allowedTCPPorts = [ 8080 ];
  };
}
