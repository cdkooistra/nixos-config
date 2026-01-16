{
  imports = [
    ./nvidia.nix
    ./amd.nix
    ./displaylink.nix
    ./wayland.nix
  ];

  # enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32bit compatibility
  };
}
