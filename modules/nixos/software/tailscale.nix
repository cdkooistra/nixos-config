{
  config,
  lib,
  ...
}:

{
  options.software.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Tailscale";
    };

    ssh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable tailscale-ssh";
    };

  };

  config = lib.mkIf config.software.tailscale.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;

      # todo, make an option for operator?
      extraSetFlags = [ "--operator=connor" ] ++ lib.optional config.software.tailscale.ssh "--ssh";
    };

  };
}
