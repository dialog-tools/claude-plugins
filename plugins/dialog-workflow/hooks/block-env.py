#!/usr/bin/env python3
import json
import sys
import re
import subprocess

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})
command = tool_input.get("command", "")

if tool_name != "Bash" or not command:
    sys.exit(0)

def unignored_env_files_exist():
    """True only if a real .env file would be swept up by a broad git add —
    i.e. it exists and is NOT covered by .gitignore."""
    try:
        result = subprocess.run(
            ["git", "ls-files", "--others", "--cached", "--exclude-standard"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return False
        for f in result.stdout.splitlines():
            name = f.rsplit("/", 1)[-1]
            if name.startswith(".env") and not any(
                s in name for s in (".sample", ".example", ".template")
            ):
                return True
    except Exception:
        pass
    return False


# Check for git add commands that might add .env files
dangerous_add_patterns = [
    r"git\s+add\s+.*\.env(?!\.sample)",  # git add .env (but not .env.sample)
    r"git\s+add\s+\.\s*$",  # git add .
    r"git\s+add\s+-A",  # git add -A
    r"git\s+add\s+--all",  # git add --all
    r"git\s+commit\s+.*-a",  # git commit -a (stages all tracked files)
]

for pattern in dangerous_add_patterns:
    if re.search(pattern, command):
        if unignored_env_files_exist():
            print("🚫 BLOCKED: This command would stage an un-gitignored .env file with sensitive credentials!", file=sys.stderr)
            print(f"Command: {command}", file=sys.stderr)
            print("Add the .env file to .gitignore, or stage specific files instead.", file=sys.stderr)
            sys.exit(2)
        break  # broad add is safe: no unignored .env files in this repo

# For git commit commands, check what's actually staged
if re.search(r"git\s+commit", command):
    try:
        # Check what files are staged for commit
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode == 0:
            staged_files = result.stdout.strip().split('\n') if result.stdout.strip() else []
            
            # Check if any .env files are staged (but allow .env.sample, .env.example, etc.)
            env_files = [f for f in staged_files if '.env' in f and not any(suffix in f for suffix in ['.sample', '.example', '.template'])]
            
            if env_files:
                print("🚫 BLOCKED: .env files are staged for commit!", file=sys.stderr)
                print(f"Command: {command}", file=sys.stderr)
                print(f"Staged .env files: {', '.join(env_files)}", file=sys.stderr)
                print("Remove .env files from staging with: git reset HEAD <file>", file=sys.stderr)
                sys.exit(2)
    except Exception:
        # If we can't check staged files, err on the side of caution for safety-critical operations
        # But don't block - let the command proceed
        pass

sys.exit(0)