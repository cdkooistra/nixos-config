{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.apps.spotify;
in
{
  options.apps.spotify.enable = lib.mkEnableOption "Spotify";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ spotify ];
  };
}
