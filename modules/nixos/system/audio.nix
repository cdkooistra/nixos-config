{
  lib,
  config,
  ...
}:

{
  options.system.audio.extraConfig = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf (lib.types.attrsOf lib.types.anything));
    default = { };
    description = "Extra PipeWire config";
  };

  config = {
    # pipewire needs this to have realtime scheduling prio
    security.rtkit.enable = true;

    # disable legacy
    services = {
      pulseaudio.enable = false;

      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
        extraConfig = config.system.audio.extraConfig;
      };
    };
  };
}
