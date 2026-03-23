{
  config,
  lib,
  ...
}:

let
  cfg = config.apps.proton;
in
{
  options.apps.proton = {
    enable = lib.mkEnableOption "enable Proton suite";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "me.proton.Pass"
      "me.proton.Mail"
      "com.protonvpn.www"
    ];
  };

}
