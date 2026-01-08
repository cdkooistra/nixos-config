{
  config,
  lib,
  pkgs,
  ...
}:

# in host config:
# {
#   services.service = {
#     enable = true;
#     directory = "/srv/service";
#     port = 3000;

#     tailscale = {
#       enable = true;
#       hostname = "service-prod";
#       tailnet = "myhome";
#       envfile = "service-env";  # References age.secrets."service-env"
#       serve = {
#         "/" = "http://127.0.0.1:3000";
#         "/api" = "http://127.0.0.1:3000/api";
#       };
#       magicdns = true;  # default, could omit
#     };
#   };

#   # Define the secret that contains TS_AUTHKEY + other service secrets
#   age.secrets."service-env" = {
#     file = ./secrets/service.age;
#   };
# }

# in other service config:
# { config, lib, pkgs, tailscale, ... }:
# ...
# tailscale = tailscale.options;
# ...
# systemd.tmpfiles.rules = /* ... */ ++ tailscale.mkDirectories { directory = cfg.directory; };
# containers.service-tailscale = tailscale.mkContainer { service = "service"; directory = cfg.directory; cfg = cfg.tailscale; };

{
  config._module.args.tailscale = {
    options = {
      enable = lib.mkEnableOption "Tailscale Sidecar";

      hostname = lib.mkOption {
        type = lib.types.str;
        description = "what to call this Tailscale node";
      };

      serve = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          "/" = "http://127.0.0.1:3000";
        };
      };

      tailnet = lib.mkOption {
        type = lib.types.str;
        description = "what Tailnet to connect to";
      };

      magicdns = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Set to true when using MagicDNS";
      };

      envfile = lib.mkOption {
        type = lib.types.str;
        description = "path to agenix secret with env vars";
      };

      # TODO: tags
    };
    mkDirectories =
      { directory }:
      [
        "d ${directory}/tailscale/state 0755 root root - -"
        "d ${directory}/tailscale/tmp 0755 root root - -"
      ];
    mkContainer =
      {
        service,
        directory,
        cfg,
      }:
      let
        serveConfig = {
          TCP."443".HTTPS = true;
          Web."${cfg.hostname}.${cfg.tailnet}.ts.net:443".Handlers = lib.mapAttrs (path: url: {
            Proxy = url;
          }) cfg.serve;
        };
      in
      {
        image = "ghcr.io/tailscale/tailscale:1.92.5";
        autoStart = true;
        hostname = cfg.hostname;
        environment = lib.mkMerge [
          {
            "TS_STATE_DIR" = "/var/lib/tailscale";
            "TS_ACCEPT_DNS" = "${toString cfg.magicdns}";
            "TS_USERSPACE" = "false";
          }
          (lib.mkIf (cfg.serve != { }) {
            "TS_SERVE_CONFIG" = "config/serve.json";
          })
        ];
        environmentFiles = [
          # each service stores its secret: ${service_name}-env.age
          # the tailscale sidecar obtains TS_AUTHKEY from there
          config.age.secrets."${cfg.envfile}".path
        ];
        volumes = [
          "${directory}/tailscale/state:/var/lib/tailscale"
          "${directory}/tailscale/tmp:/tmp"
          "/dev/net/tun:/dev/net/tun"
        ]
        ++ lib.optionals (cfg.serve != { }) [
          "${
            (pkgs.writeTextFile {
              name = "${service}-ts-serve-cfg";
              text = builtins.toJSON serveConfig;
            })
          }:/config/serve.json"
        ];
        extraOptions = [
          "--cap-add=net_admin"
        ];
      };
  };
}
