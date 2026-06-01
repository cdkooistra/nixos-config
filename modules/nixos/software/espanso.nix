{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.software.espanso = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable Espanso";
    };
  };

  config = lib.mkIf config.software.espanso.enable {
    security.wrappers.espanso = {
      source = "${pkgs.espanso-wayland}/bin/espanso";
      capabilities = "cap_dac_override+p";
      owner = "root";
      group = "root";
    };
    # services.espanso = {
    #   enable = true;
    #   package = pkgs.espanso-wayland;
    # };

    # environment.systemPackages = with pkgs; [
    #   espanso-wayland
    # ];
  };
}
