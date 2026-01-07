# NixOS configuration

Hi, this is my NixOS Flake + Home Manager configuration.

## Secrets

To manage secrets, I use [agenix](https://github.com/ryantm/agenix) together with [age](https://github.com/FiloSottile/age).

In [secrets/secrets.nix](./secrets/secrets.nix) I map each system and their corresponding public key. This mapping can then be used to determine what secret can be decrypted by which system(s).

To create a secret, first create that secret in the aforementioned `secrets.nix`:

```nix
  "secret1.age".publicKeys = [ user1 system1 ];
  "secret2.age".publicKeys = users ++ systems;
```

Then to create/edit the secret itself:

```bash
agenix -e secret1.age 
```

This will open a temporary file and allows you to insert secret content.

Then, inside any NixOS module, we need to register and use that secret as follows:

```nix
{
  # register
  age.secrets.secret1.file = ./secrets/secret1.age;

  # use
  virtualisation.oci-containers.containers.solidtime = {
    environmentFiles = [ config.age.secrets.secret1.path ];
    # age.secrets.<name>.path is the path where the secret is decrypted to. 
    # Defaults to /run/agenix/<name> (config.age.secretsDir/<name>).
    # We can only pass along a file with decrypted contents
    # ...
  };
}
```
