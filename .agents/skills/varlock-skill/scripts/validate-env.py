#!/usr/bin/env python3
"""
Varlock CLI helper for agents to quickly validate or scan .env files.
"""
import subprocess
import sys
import json

def run_varlock_command(command: list):
    try:
        result = subprocess.run(
            ["npx", "varlock"] + command,
            capture_output=True,
            text=True,
            check=True
        )
        print(f"Success:\n{result.stdout}")
    except subprocess.CalledProcessError as e:
        print(f"Error running varlock {command}:\n{e.stderr}\n{e.stdout}", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        print("Usage: python validate-env.py [load|scan]")
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "load":
        print("Validating constraints by running varlock load...")
        run_varlock_command(["load", "-j"])
    elif cmd == "scan":
        print("Scanning for leaked secrets by running varlock scan...")
        run_varlock_command(["scan"])
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)

if __name__ == "__main__":
    main()
