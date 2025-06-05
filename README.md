# NixOS configuration

Hi, this is my NixOS Flake + Home Manager configuration.

## Secrets

To manage secrets, I use [sops-nix](https://github.com/Mic92/sops-nix) together with [age](https://github.com/FiloSottile/age). To have sops-nix encrypt/decrypt with our set ed25519 private key, we generate an age key:

```bash
mkdir -p ~/.config/sops/age
$ nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```

Afterwards, make sure to append the public key to the .sops.yaml file:

```bash
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

Now you can set any secrets in ```secrets/secrets.yaml``` using the following command:

```bash
sops .secrets/secrets.yaml
```

These secrets will now be encrypted when viewed through any other way.
