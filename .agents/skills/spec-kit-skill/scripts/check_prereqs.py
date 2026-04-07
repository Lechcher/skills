#!/usr/bin/env python3
import shutil
import sys
import subprocess

def check_command(cmd_name, required=True):
    path = shutil.which(cmd_name)
    if path:
        print(f"✅ {cmd_name} is installed at {path}")
        return True
    else:
        status = "❌" if required else "⚠️"
        print(f"{status} {cmd_name} is NOT installed.")
        return False

def main():
    print("Checking prerequisites for Spec Kit...\n")
    all_passed = True
    
    # Check Python, Git, uv
    for cmd in ["python3", "git", "uv"]:
        if not check_command(cmd):
            all_passed = False

    # Check specify
    if not check_command("specify"):
        print("\nTo install `specify` CLI, run:")
        print("  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git")
        all_passed = False

    if all_passed:
        print("\n🚀 All prerequisites met! You are ready to invoke specify init.")
        sys.exit(0)
    else:
        print("\n⚠️ Please install the missing tools before proceeding.")
        sys.exit(1)

if __name__ == "__main__":
    main()
