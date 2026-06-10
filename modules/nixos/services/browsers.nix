{
  config,
  lib,
  tailscale,
  ...
}:

let
  service = "browsers";
  cfg = config.services.${service};
in
{
  options.services.${service} = {
    enable = lib.mkEnableOption "Browser containers";

    instances = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            dir = lib.mkOption {
              type = lib.types.str;
              description = "Directory to store browser persistent data";
            };

            secretFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to age-encrypted secrets";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 5800;
              description = "Port to access the container's web UI (jlesage uses 5800 internally)";
            };

            vncPort = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Optional port to expose the VNC interface (container port 5900). Set to null to disable.";
            };

            shmSize = lib.mkOption {
              type = lib.types.str;
              default = "2g";
              description = "Shared memory size for the container. Recommended 2g to avoid Firefox crashes.";
            };

            tailscale = tailscale.options;
          };
        }
      );
      default = { };
      description = "Browser instance configurations";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Retrieve age secrets
        age.secrets = lib.mkMerge (
          lib.mapAttrsToList (name: instance: {
            "${service}-${name}".file = instance.secretFile;
          }) cfg.instances
        );

        # Create persistent data directories
        systemd.tmpfiles.rules = lib.flatten (
          lib.mapAttrsToList (name: instance: [
            "d ${instance.dir} 0755 1000 1000 - -"
            "d ${instance.dir}/config 0755 1000 1000 - -"
          ]) cfg.instances
        );

        # Set up containers
        virtualisation.oci-containers.containers = lib.mkMerge (
          (lib.mapAttrsToList (name: instance: {
            "${service}-${name}" = {
              autoStart = true;
              image = "jlesage/firefox:latest";

              extraOptions = [
                # Firefox requires the membarrier syscall; unconfined is the
                # straightforward fix on NixOS where seccomp profiles can be
                # tricky to supply as files.
                "--security-opt=seccomp=unconfined"
                # Firefox needs enough shared memory to avoid tab crashes.
                "--shm-size=${instance.shmSize}"
              ]
              ++ lib.optionals instance.tailscale.enable [
                "--network=container:${service}-${name}-tailscale"
              ]
              ++ lib.optionals config.graphics.nvidia.enable [
                "--device=nvidia.com/gpu=all"
              ];

              environmentFiles = [ config.age.secrets."${service}-${name}".path ];
              environment = {
                # jlesage images use USER_ID/GROUP_ID, not PUID/PGID
                USER_ID = "1000";
                GROUP_ID = "1000";
                TZ = "Europe/Amsterdam";
              };

              ports = [
                "${toString instance.port}:5800"
              ]
              ++ lib.optional (instance.vncPort != null) "${toString instance.vncPort}:5900";

              volumes = [
                "${instance.dir}/config:/config:rw"
              ];

              dependsOn = lib.optionals instance.tailscale.enable [ "${service}-${name}-tailscale" ];
            };
          }) cfg.instances)
          ++ (lib.mapAttrsToList (
            name: instance:
            lib.optionalAttrs instance.tailscale.enable {
              "${service}-${name}-tailscale" = tailscale.mkContainer {
                service = "${service}-${name}";
                directory = instance.dir;
                networks = [ ];
                cfg = instance.tailscale // {
                  envfile = "${service}-${name}";
                };
              };
            }
          ) cfg.instances)
        );
      }
    ]
  );
}
