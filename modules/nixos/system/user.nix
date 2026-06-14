{
  config,
  lib,
  secrets,
  ...
}:

{
  users.users.connor = {
    isNormalUser = true;
    description = "Connor K";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPasswordFile = lib.mkIf (config.age.secrets ? passwd) config.age.secrets.passwd.path;

    openssh.authorizedKeys.keys = lib.mkIf config.system.openssh.enable (
      builtins.attrValues (import "${secrets}/hosts.nix")
    );
  };

  nix.settings.trusted-users = [
    "root"
    "connor"
  ];
}
