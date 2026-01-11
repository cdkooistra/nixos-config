{
  config,
  lib,
  pkgs,
  tailscale,
  ...
}:

let
  service = "browsers";
  cfg = config.services.${service};
  # mkContainerName = suffix: "${service}-${suffix}";
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
              description = "directory to store browser persistent data";
            };

            secretFile = lib.mkOption {
              type = lib.types.path;
              description = "path to age-encrypted secrets";
            };

            # image ?

            tailscale = tailscale.options;
          };
        }
      );
      default = { };
      description = "Browser instanced configurations";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # retrieve age secret
        age.secrets = lib.mkMerge (
          lib.mapAttrsToList (name: instance: {
            "${service}-${name}".file = instance.secretFile;
          }) cfg.instances
        );

        # create directories
        systemd.tmpfiles.rules = lib.flatten (
          lib.mapAttrsToList (name: instance: [
            "d ${instance.dir} 0755 1000 1000 - -"
            "d ${instance.dir}/config 0755 1000 1000 - -"
          ]) cfg.instances
        );

        # set up containers
        virtualisation.oci-containers.containers = lib.mkMerge (
          (lib.mapAttrsToList (name: instance: {
            "${service}-${name}" = {
              autoStart = true;
              image = "lscr.io/linuxserver/chromium:latest";

              extraOptions = [
                "--device=/dev/dri:/dev/dri"
                "--group-add=video"
              ]
              ++ lib.optionals instance.tailscale.enable [
                "--network=container:${service}-${name}-tailscale"
              ];

              environmentFiles = [ config.age.secrets."${service}-${name}".path ];
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "Europe/Amsterdam";
              };

              volumes = [
                "${instance.dir}/config:/config"
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
