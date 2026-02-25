#!/usr/bin/env python

from pathlib import Path
import subprocess
import sys

def find_flake(start: Path = Path.cwd()) -> Path:
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
        ["sudo", "nix", "flake", "update", "--flake", f"{flake}"]
    )

    sys.exit(res.returncode)

if __name__ == "__main__":
    main()
