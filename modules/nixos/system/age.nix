{ inputs, pkgs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    age
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.agenix
  ];
}
