{
  users.users.connor = {
    isNormalUser = true;
    description = "Connor K";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "connor"
  ];
}
