{
  config,
  lib,
  ...
}:

let
  cfg = config.services.stirling;
in
{
  options.services.stirling = {
    enable = lib.mkEnableOption "Stirling PDF";
  };

  config = lib.mkIf cfg.enable {
    services.stirling-pdf.enable = true;

    # TODO:
    # env and env files
  };
}
