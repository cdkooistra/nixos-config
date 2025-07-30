{
  nvidia = import ./nvidia.nix;
  amd = import ./amd.nix;

  # enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32bit compatibility
  };
}
