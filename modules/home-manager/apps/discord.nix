{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.discord;
in
{
  options.apps.discord.enable = lib.mkEnableOption "Discord";

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [ "com.discordapp.Discord" ];
  };
}
