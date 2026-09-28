{
  config,
  lib,
  pkgs,
  network,
  tailscale,
  ...
}:

let
  service = "opengym";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "openGym";

    version = lib.mkOption {
      type = lib.types.str;
      description = "version to use for containers";
      default = "latest";
    };

    dir = lib.mkOption {
      type = lib.types.str;
      description = "directory to store openGym persistent data";
    };

    port = lib.mkOption {
      type = lib.types.int;
      description = "port";
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to age-encrypted secrets";
    };

    tailscale = tailscale.options;
  };

  config = lib.mkIf cfg.enable {
    age.secrets.${service} = {
      file = cfg.secretFile;
    };

    # create directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dir} 0755 1000 1000 - -"
      "d ${cfg.dir}/data 0755 1000 1000 - -"
      "d ${cfg.dir}/coach-auth 0755 1000 1000 - -"
      "d ${cfg.dir}/media 0755 1000 1000 - -"
      "d ${cfg.dir}/media/img 0755 1000 1000 - -"
      "d ${cfg.dir}/media/gif 0755 1000 1000 - -"
    ]
    ++ lib.optionals cfg.tailscale.enable (
      tailscale.mkDirectories {
        directory = cfg.dir;
      }
    );

    # create network
    systemd.services.docker-network-opengym = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      script = ''
        ${pkgs.docker}/bin/docker network inspect opengym >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create opengym
      '';
    };

    # one-time download of exercise media (images + GIFs), mirroring the
    # "media" service in their docker-compose.yml
    systemd.services.opengym-media = {
      description = "download openGym exercise media";
      serviceConfig.Type = "oneshot";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      script = ''
        if [ -z "$(${pkgs.coreutils}/bin/ls -A ${cfg.dir}/media/img 2>/dev/null)" ]; then
          ${pkgs.docker}/bin/docker run --rm \
            --entrypoint /bin/sh \
            -v ${cfg.dir}/media/img:/out/img \
            -v ${cfg.dir}/media/gif:/out/gif \
            alpine/git -c '
              git clone --depth 1 https://github.com/hasaneyldrm/exercises-dataset /tmp/ds &&
              cp /tmp/ds/images/*.jpg /out/img/ &&
              cp /tmp/ds/videos/*.gif /out/gif/
            '
        fi
      '';
    };

    # set up containers
    virtualisation.oci-containers.containers = {
      opengym-api = {
        autoStart = true;
        image = "ghcr.io/duartesantos8/opengym-api:${cfg.version}";

        networks = lib.mkIf (!cfg.tailscale.enable) [ "opengym" ];
        extraOptions = lib.mkIf cfg.tailscale.enable [ "--network=container:${service}-tailscale" ];

        environmentFiles = [ config.age.secrets.${service}.path ];
        environment = {
          RP_ID = "${service}.${network.tailnet}.ts.net";
          RP_NAME = "${service}";
          ORIGIN = "https://${service}.${network.tailnet}.ts.net";
          DATA_DIR = "/data";
          TRUST_PROXY = "1";
        };

        volumes = [
          "${cfg.dir}/data:/data"
          "${cfg.dir}/coach-auth:/coach-auth"
        ];

        dependsOn = lib.optionals cfg.tailscale.enable [ "${service}-tailscale" ];
      };

      opengym-web = {
        autoStart = true;
        image = "ghcr.io/duartesantos8/opengym-web:${cfg.version}";

        networks = lib.mkIf (!cfg.tailscale.enable) [ "opengym" ];
        extraOptions = lib.mkIf cfg.tailscale.enable [ "--network=container:${service}-tailscale" ];

        environmentFiles = [ config.age.secrets.${service}.path ];
        environment = {
          BACKEND = "127.0.0.1"; # share same network space
        };

        volumes = [
          "${cfg.dir}/media/img:/usr/share/nginx/html/img:ro"
          "${cfg.dir}/media/gif:/usr/share/nginx/html/gif:ro"
        ];

        ports = lib.mkIf (!cfg.tailscale.enable) [ "${toString cfg.port}:80" ];

        dependsOn = [
          "opengym-api"
        ]
        ++ lib.optionals cfg.tailscale.enable [ "${service}-tailscale" ];
      };

      # create tailscale sidecar
      opengym-tailscale = lib.mkIf cfg.tailscale.enable (
        tailscale.mkContainer {
          service = "${service}";
          directory = cfg.dir;
          networks = [ "opengym" ];
          cfg = cfg.tailscale // {
            envfile = "${service}";
          };
        }
      );
    };

    # media must be downloaded before web serves it
    systemd.services."docker-opengym-web" = {
      after = [ "opengym-media.service" ];
      requires = [ "opengym-media.service" ];
    };
  };
}
