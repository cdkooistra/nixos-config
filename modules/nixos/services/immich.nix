{
  config,
  lib,
  pkgs,
  tailscale,
  ...
}:

let
  service = "immich";
  cfg = config.services."${service}-container";
  mkContainerName = suffix: "${service}-${suffix}";
in
{
  options.services.immich-container = {
    enable = lib.mkEnableOption "Immich through oci-container";

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory to store Immich persistent data";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "directory to store files";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    # retrieve age secret
    age.secrets.${service}.file = cfg.secretFile;

    # create directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dir} 0755 root root - -"
      "d ${cfg.dir}/model-cache 0755 root root - -"
      "d ${cfg.dir}/database 0700 999 root - -"
      "d ${cfg.dataDir} 0755 root root - -" # is this correct?
    ]
    ++ lib.optionals cfg.tailscale.enable (
      tailscale.mkDirectories {
        directory = cfg.dir;
      }
    );

    # create network
    systemd.services.docker-network-immich = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      script = ''
        ${pkgs.docker}/bin/docker network inspect ${service} >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create ${service}
      '';
    };

    # set up containers
    virtualisation.oci-containers.containers = {
      ${service} = {
        autoStart = true;
        image = "ghcr.io/immich-app/immich-server:v2.4.1";

        networks = lib.mkIf (!cfg.tailscale.enable) [ "${service}" ];
        extraOptions = [ "--network=container:${service}-tailscale" ];

        environmentFiles = [ config.age.secrets.${service}.path ];
        environment = {
          DB_HOSTNAME = (mkContainerName "database");
          REDIS_HOSTNAME = (mkContainerName "redis");
        };

        volumes = [
          "${cfg.dataDir}:/usr/src/app/upload"
          "/etc/localtime:/etc/localtime:ro"
        ];

        dependsOn = [
          (mkContainerName "redis")
          (mkContainerName "database")
        ]
        ++ lib.optionals cfg.tailscale.enable [ "${service}-tailscale" ];
      };

      ${mkContainerName "ml"} = {
        autoStart = true;
        image = "ghcr.io/immich-app/immich-machine-learning:v2.4.1";
        networks = [ "${service}" ];
        environment = {
          DB_HOSTNAME = (mkContainerName "database");
          REDIS_HOSTNAME = (mkContainerName "redis");
        };
        environmentFiles = [ config.age.secrets.${service}.path ];

        volumes = [ "${cfg.dir}/model-cache:/cache" ];
      };

      ${mkContainerName "redis"} = {
        autoStart = true;
        image = "docker.io/valkey/valkey:8-alpine";
        networks = [ "${service}" ];
      };

      ${mkContainerName "database"} = {
        autoStart = true;
        # image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        image = "ghcr.io/immich-app/postgres:16-vectorchord0.3.0-pgvectors0.3.0";
        networks = [ "${service}" ];

        environmentFiles = [ config.age.secrets.${service}.path ];

        volumes = [ "${cfg.dir}/database:/var/lib/postgresql/data" ];
      };

      # create tailscale sidecar
      ${mkContainerName "tailscale"} = lib.mkIf cfg.tailscale.enable (
        tailscale.mkContainer {
          service = "${service}";
          directory = cfg.dir;
          networks = [ "${service}" ];
          cfg = cfg.tailscale // {
            envfile = "${service}";
          };
        }
      );
    };
  };
}
