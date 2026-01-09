let
  sisyphus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUscWCA9YE8aAfkdVGncl3ZXg1a71cfD9nKJfU8GjZW connor@sisyphus";
  artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHd4uuIxSByQ8KN5nZlp8gaWHrpklg+jXJiarIAaa+1 connor@artemis";
  hermes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9DbFyhcqg7VP3yBDW1tsnJhy0201lDEOqbel+inrzw connor@hermes";

  systems = [
    sisyphus
    artemis
    hermes
  ];
in
{
  "solidtime.age".publicKeys = [
    sisyphus
    hermes
  ];
  "immich.age".publicKeys = [
    sisyphus
    hermes
  ];
}
