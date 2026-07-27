#!/usr/bin/env python

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
    if len(sys.argv) > 1:
        print("Usage: ./update.py")
        sys.exit(1)

    flake = find_flake()

    res = subprocess.run(
        ["sudo", "nix", "flake", "update", "--flake", f"{flake}"], check=False
    )

    sys.exit(res.returncode)


if __name__ == "__main__":
    main()
