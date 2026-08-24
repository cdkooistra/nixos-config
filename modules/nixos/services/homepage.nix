{
  config,
  lib,
  pkgs,
  tailscale,
  network,
  ...
}:

let
  service = "homepage";
  cfg = config.services."${service}";
  hackernewsCfg = config.services.hackernews;
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
    services.hackernews.enable = true;

    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.port;
      allowedHosts = "home.${network.tailnet}.ts.net";
      package = pkgs.unstable.homepage-dashboard;

      widgets = [
        {
          resources = {
            label = "System";
            cpu = true;
            cputemp = true;
            memory = true;
            disk = "/";
            uptime = true;
            units = "metric";
          };
        }
      ];

      services = [
        {
          Services = [
            {
              Immich = {
                href = "https://immich.${network.tailnet}.ts.net";
                icon = "immich.png";
              };
            }
            {
              Solidtime = {
                href = "https://solidtime.${network.tailnet}.ts.net";
                icon = "solidtime.png";
              };
            }
          ];
        }
        {
          Feeds = [
            {
              "Hacker News" = {
                icon = "hacker-news.png";
                href = "https://news.ycombinator.com/";
                widget = {
                  type = "customapi";
                  url = "http://127.0.0.1:${toString hackernewsCfg.port}/feed.json";
                  display = "dynamic-list";
                  mappings = {
                    name = "title";
                    label = "score";
                    target = "{discussionUrl}";
                    limit = hackernewsCfg.limit;
                  };
                };
              };
            }
          ];
        }
      ];
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

    # allow sidecar to reach host
    networking.firewall.interfaces."docker0".allowedTCPPorts = [ cfg.port ];
  };
}
