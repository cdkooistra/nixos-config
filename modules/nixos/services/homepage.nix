{
  config,
  lib,
  pkgs,
  tailscale,
  ...
}:

let
  service = "homepage";
  cfg = config.services."${service}";
in
{
  options.services."${service}" = {
    enable = lib.mkEnableOption "Homepage";

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory for tailscale sidecar state";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8100;
      description = "port for Homepage";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    services.homepage-homepage-dashboard = {
      enable = true;
      package = pkgs.unstable.homepage-dashboard;
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

    # allow sidecar to reach host web UI
    networking.firewall.interfaces."docker0".allowedTCPPorts = [ cfg.port ];
  };
}
