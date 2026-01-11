{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.software.pinta = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable pinta";
    };
  };

  config = lib.mkIf config.software.pinta.enable {
    environment.systemPackages = [
      pkgs.pinta
    ];
  };

}
