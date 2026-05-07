{
  config,
  lib,
  tailscale,
  ...
}:

let
  service = "forgejo";
  cfg = config.services."${service}-service";
  sshPort = 2222;
in
{
  options.services."${service}-service" = {
    enable = lib.mkEnableOption "Forgejo";

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory for tailscale sidecar state";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "port for Forgejo webui";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      lfs.enable = true;
      database.type = "postgres";
      settings = {
        server = {
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = cfg.port;
          DOMAIN = "${cfg.tailscale.hostname}.${cfg.tailscale.tailnet}.ts.net";
          ROOT_URL = "https://${cfg.tailscale.hostname}.${cfg.tailscale.tailnet}.ts.net";
          # built-in SSH server
          START_SSH_SERVER = true;
          SSH_LISTEN_PORT = sshPort;
          SSH_DOMAIN = "${cfg.tailscale.hostname}.${cfg.tailscale.tailnet}.ts.net";
          SSH_PORT = sshPort;
        };
      };
    };

    age.secrets.${service}.file = cfg.secretFile;

    systemd.tmpfiles.rules = tailscale.mkDirectories {
      directory = cfg.dir;
    };

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

    # SSH only accessible via tailscale
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ sshPort ];
  };
}
