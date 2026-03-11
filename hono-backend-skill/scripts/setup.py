#!/usr/bin/env python3
import sys
import subprocess
import os

def setup_hono_project(project_name):
    print(f"Initializing Hono project: {project_name}")
    try:
        subprocess.run(["npm", "create", "hono@latest", project_name, "--template", "cloudflare-workers"], check=True)
        print(f"✅ Successfully created Hono project {project_name} for Cloudflare Workers.")
        print("Commands:")
        print(f"  cd {project_name} && npm install && npm run dev")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to create project: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 setup.py <project-name>")
        sys.exit(1)
    setup_hono_project(sys.argv[1])
