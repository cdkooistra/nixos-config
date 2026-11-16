#!/usr/bin/env python

import os
import subprocess
import sys
from pathlib import Path


def find_flake() -> Path:
    start = Path.cwd()
    for parent in [start] + list(start.parents):
        if (parent / "public" / "flake.nix").exists():
            return parent / "public"
    raise FileNotFoundError("Could not find flake.nix")


def main():
    if len(sys.argv) < 2:
        print("Usage: ./rebuild.py <action> [host]")
        sys.exit(1)

    flake = find_flake()
    action = sys.argv[1]
    local = os.environ["NIXOS_HOST"]
    host = sys.argv[2] if len(sys.argv) > 2 else local

    if host == local:
        cmd = ["sudo", "nixos-rebuild", action, "--flake", f"{flake}#{host}"]
    else:
        cmd = [
            "nixos-rebuild",
            action,
            "--flake",
            f"{flake}#{host}",
            "--target-host",
            f"connor@{host}",
            "--sudo",
            "--ask-sudo-password",
        ]

    res = subprocess.run(cmd, check=False)
    sys.exit(res.returncode)


if __name__ == "__main__":
    main()
