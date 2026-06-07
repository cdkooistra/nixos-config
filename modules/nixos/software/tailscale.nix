{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.software.tailscale;
in
{
  options.software.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
    ssh = lib.mkEnableOption "Tailscale SSH";

    auth = {
      enable = lib.mkEnableOption "OAuth";
      file = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing auth key for Tailscale with OAuth 2.0";
      };
      params = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Extra parameters to pass after auth key, always check with https://search.nixos.org/options?channel=unstable&query=services.tailscale#show=option%253Aservices.tailscale.authKeyParameters";
      };
    };

    serve = {
      enable = lib.mkEnableOption "Tailscale Serve";
      services = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Services to configure for Tailscale Serve";
      };
    };

    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Tags to advertise, e.g. [ \"tag:server\" ]";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = lib.mkIf cfg.auth.enable {
      tailscale.file = cfg.auth.file;
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.tailscale;

      # todo, make an option for operator?
      extraSetFlags = [ "--operator=connor" ];

      # configure tags
      extraUpFlags = lib.concatLists [
        (lib.optional cfg.ssh "--ssh")
        (lib.optional (cfg.tags != [ ]) "--advertise-tags=${lib.concatStringsSep "," cfg.tags}")
      ];

      # configure auth
      authKeyFile = lib.mkIf cfg.auth.enable config.age.secrets.tailscale.path;
      authKeyParameters = lib.mkIf cfg.auth.enable cfg.auth.params;

      # configure local services for Tailscale Serve
      serve = lib.mkIf cfg.serve.enable {
        enable = true;
        services = cfg.serve.services;
      };
    };
  };
}
