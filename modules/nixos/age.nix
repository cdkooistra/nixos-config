{ inputs, pkgs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    age
    inputs.agenix.packages.${pkgs.system}.agenix
  ];
}
