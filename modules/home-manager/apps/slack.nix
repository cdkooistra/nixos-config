{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.apps.slack;
in
{
  options.apps.slack.enable = lib.mkEnableOption "Slack";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ slack ];
  };
}
