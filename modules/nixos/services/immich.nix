{
  config,
  lib,
  pkgs,
  tailscale,
  ...
}:

let
  service = "immich";
  cfg = config.services."${service}-service";
  # mkContainerName = suffix: "${service}-${suffix}";
in
{
  options.services."${service}-service" = {
    enable = lib.mkEnableOption "Immich";

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory for tailscale sidecar state";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "directory for media";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = 2283;
      mediaLocation = cfg.dataDir;
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
    networking.firewall.interfaces."docker0".allowedTCPPorts = [ 2283 ];
  };
}
