{ config, lib, ... }:

{
  users.users.connor = {
    isNormalUser = true;
    description = "Connor K";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
