{
  config,
  lib,
  pkgs,
  tailscale,
  ...
}:

let
  service = "solidtime";
  secrets = config.age.secrets."${service}".path;
  cfg = config.services.${service};
in
{
  options.services.solidtime = {
    enable = lib.mkEnableOption "Solidtime";

    directory = lib.mkOption {
      type = lib.types.str;
      description = "directory to store Solidtime persistent data";
    };

    port = lib.mkOption {
      type = lib.types.int;
      description = "port";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    # create directories
    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0755 root root - -"
      "d ${cfg.directory}/data 0755 1000 1000 - -"
      "d ${cfg.directory}/logs 0755 1000 1000 - -"
      "d ${cfg.directory}/db 0700 999 root - -"
    ]
    ++ lib.optionals cfg.tailscale.enable (
      tailscale.mkDirectories {
        directory = cfg.directory;
      }
    );

    # create network
    systemd.services.docker-network-solidtime = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      script = ''
        ${pkgs.docker}/bin/docker network inspect solidtime >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create solidtime
      '';
    };

    # set up containers
    virtualisation.oci-containers.containers = {
      solidtime = {
        autoStart = true;
        image = "solidtime/solidtime:0.10";
        user = "1000:1000";
        networks = [ "solidtime" ];

        environmentFiles = [ secrets ];
        environment = {
          CONTAINER_MODE = "http";
          AUTO_DB_MIGRATE = "true";
        };

        volumes = [
          "${cfg.directory}/data:/var/www/html/storage/app"
          "${cfg.directory}/logs:/var/www/html/storage/logs"
        ];

        ports = [ "${toString cfg.port}:8000" ];
        dependsOn = [ "solidtime-database" ];
      };

      solidtime-database = {
        autoStart = true;
        image = "postgres:15";
        networks = [ "solidtime" ];

        environmentFiles = [ secrets ];
        environment = {
          POSTGRES_DB = "solidtime";
          POSTGRES_USER = "solidtime";
        };

        volumes = [
          "${cfg.directory}/db:/var/lib/postgresql/data"
        ];
      };

      solidtime-scheduler = {
        autoStart = true;
        image = "solidtime/solidtime:0.10";
        user = "1000:1000";
        networks = [ "solidtime" ];

        environment = {
          CONTAINER_MODE = "scheduler";
        };

        volumes = [
          "${cfg.directory}/data:/var/www/html/storage/app"
          "${cfg.directory}/logs:/var/www/html/storage/logs"
        ];

        dependsOn = [ "solidtime-database" ];
      };

      solidtime-queue = {
        autoStart = true;
        image = "solidtime/solidtime:0.10";
        user = "1000:1000";
        networks = [ "solidtime" ];

        environment = {
          CONTAINER_MODE = "worker";
          WORKER_COMMAND = "php /var/www/html/artisan queue:work";
        };

        volumes = [
          "${cfg.directory}/data:/var/www/html/storage/app"
          "${cfg.directory}/logs:/var/www/html/storage/logs"
        ];

        dependsOn = [ "solidtime-database" ];
      };

      # create tailscale sidecar
      solidtime-tailscale = lib.mkIf cfg.tailscale.enable (
        tailscale.mkContainer {
          service = "${service}";
          directory = cfg.directory;
          cfg = cfg.tailscale;
        }
      );
    };
  };
}
