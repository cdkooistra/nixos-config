{
  pkgs,
  hostName,
  ...
}:

let
  mkScript = name: text: pkgs.writeShellScriptBin name text;

  rebuildScript = ../../utils/rebuild.py;
  updateScript = ../../utils/update.py;

  scripts = [
    (mkScript "nixrebuild" ''
      exec ${pkgs.python3}/bin/python ${rebuildScript} "$1" "${hostName}"
    '')

    (mkScript "nixupdate" ''
      exec ${pkgs.python3}/bin/python ${updateScript}
    '')
  ];
in
{
  home.packages = scripts;

  # create .envrc file at ../flake.nix
  home.file.".nixos-config/.envrc" = {
    text = ''
      export NIXOS_HOST="${hostName}"
      export NIXREBUILD_PATH="$(pwd)/public/utils/rebuild.py"
      export NIXUPDATE_PATH="$(pwd)/public/utils/update.py"
    '';
  };
}
