{ config, lib, pkgs, ... }:

{
  options.software = {
    syncthing.enable = lib.mkEnableOption "enable syncthing";
  };

  config = lib.mkIf config.software.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "connor";
      group = "users";
      dataDir = "/home/connor";
      configDir = "/home/connor/.config/syncthing";
      
      settings = {
        devices = {
          "laptop" = { id = "7CEZ5CR-NV3HRMY-WV6ZGHE-HBUNZD3-OT7LUAI-NNAHAMA-C46DBOJ-NCVIAQ4"; };
        };
        folders = {
          "Documents" = {
            id = "e2lje-9wc4v";
            path = "/home/connor/Documents";
            devices = [ "laptop"];
          };
        };
      };

    };

    # stop creating default sync folder
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    # TODO: figure out how to do this garbage
    # systemd.services.set-syncthing-password = {
    #   description = "Set Syncthing GUI password from sops secret";
    #   after = [ "network.target" ];
    #   before = [ "syncthing.service" ];
    #   wantedBy = [ "multi-user.target" ];

    #   serviceConfig = {
    #     Type = "oneshot";
    #     User = "connor";
    #     ExecStart = pkgs.writeShellScript "set-syncthing-pw" ''
    #       '';
    #   };
    #
    # };

  };

}