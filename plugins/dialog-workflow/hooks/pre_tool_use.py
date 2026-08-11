#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# ///

import json
import sys
import re

def get_rm_command_guidance(command):
    """
    Provide specific guidance based on the rm command that was blocked.
    Returns a helpful error message with alternatives.
    """
    normalized = ' '.join(command.lower().split())
    
    # Determine what they were trying to do and suggest alternatives
    suggestions = []
    
    # Check if it's targeting a specific directory/file
    if 'node_modules' in command:
        suggestions.append("• To remove node_modules: First check size with 'du -sh node_modules', then use 'rm -r node_modules' (without -f)")
        suggestions.append("• Or move to trash: 'mv node_modules /tmp/node_modules_backup'")
    elif '.git' in command:
        suggestions.append("• To remove git directory: Use 'rm -r .git' (without -f) after confirming with 'ls -la .git'")
        suggestions.append("• Consider backing up first: 'mv .git /tmp/git_backup'")
    elif 'dist' in command or 'build' in command:
        suggestions.append("• To clean build directories: Use 'rm -r dist' or 'rm -r build' (without -f)")
        suggestions.append("• Many projects have clean scripts: Try 'npm run clean' or 'make clean'")
    
    # Check for wildcard usage
    if '*' in command:
        suggestions.append("• Instead of wildcards with rm -rf, first list files: 'ls -la pattern*'")
        suggestions.append("• Then remove specific files: 'rm file1.txt file2.txt'")
        suggestions.append("• Or use find for safer deletion: 'find . -name \"pattern*\" -type f -delete'")
    
    # Check for current directory or parent directory
    if re.search(r'rm\s+.*-[a-z]*r.*\s+\.$', normalized) or ' ./' in normalized:
        suggestions.append("• To clean current directory: Remove specific subdirectories/files individually")
        suggestions.append("• List contents first: 'ls -la'")
        suggestions.append("• Then remove items: 'rm -r specific_dir' (without -f)")
    
    # Default suggestions if no specific pattern matched
    if not suggestions:
        suggestions.append("• For single files: 'rm filename.txt'")
        suggestions.append("• For empty directories: 'rmdir dirname'")
        suggestions.append("• For non-empty directories: 'rm -r dirname' (without -f, allows confirmation)")
        suggestions.append("• To move instead of delete: 'mv item /tmp/backup_item'")
    
    # Always add these general tips
    suggestions.append("\n💡 Tips:")
    suggestions.append("• The -f flag forces deletion without confirmation - usually not needed")
    suggestions.append("• Always verify what you're deleting first with 'ls -la <path>'")
    suggestions.append("• Consider moving to /tmp instead of permanent deletion")
    
    return "\n".join(suggestions)

def is_dangerous_rm_command(command):
    """
    Comprehensive detection of dangerous rm commands.
    Matches various forms of rm -rf and similar destructive patterns.
    Returns tuple: (is_dangerous, reason)
    """
    # Skip if this is clearly not an actual rm command execution
    # (e.g., it's a grep search, comment, or string)
    if any(prefix in command for prefix in ['grep ', 'echo ', '#', '"rm', "'rm", 'cat ', 'less ', 'more ']):
        return False, None
    
    # Normalize command by removing extra spaces and converting to lowercase
    normalized = ' '.join(command.lower().split())
    
    # Pattern 1: Standard rm -rf variations
    dangerous_patterns = [
        (r'\brm\s+.*-[a-z]*r[a-z]*f', "Recursive force removal (rm -rf)"),
        (r'\brm\s+.*-[a-z]*f[a-z]*r', "Force recursive removal (rm -fr)"),
        (r'\brm\s+--recursive\s+--force', "Recursive force removal with long options"),
        (r'\brm\s+--force\s+--recursive', "Force recursive removal with long options"),
        (r'\brm\s+-r\s+.*-f', "Recursive removal with force flag"),
        (r'\brm\s+-f\s+.*-r', "Force removal with recursive flag"),
    ]
    
    # Check for dangerous patterns
    for pattern, reason in dangerous_patterns:
        if re.search(pattern, normalized):
            return True, reason
    
    # Pattern 2: Check for rm with recursive flag targeting dangerous paths
    dangerous_paths = [
        (r'/', "root directory"),
        (r'/\*', "root directory with wildcard"),
        (r'~/?(\s|$)', "home directory"),
        (r'\$HOME', "home directory via $HOME"),
        (r'\.\.', "parent directory references"),
        (r'\*', "wildcards"),
        (r'\.\s*$', "current directory"),
    ]
    
    if re.search(r'\brm\s+.*-[a-z]*r', normalized):  # If rm has recursive flag
        for path_pattern, path_desc in dangerous_paths:
            if re.search(path_pattern, normalized):
                return True, f"Recursive removal targeting {path_desc}"
    
    return False, None

def is_env_file_write_access(tool_name, tool_input):
    """
    Check if any tool is trying to write to .env files containing sensitive data.
    Allows reading .env files but blocks writing/editing them.
    """
    if tool_name in ['Edit', 'MultiEdit', 'Write', 'Bash']:
        # Check file paths for file-based tools that modify files
        if tool_name in ['Edit', 'MultiEdit', 'Write']:
            file_path = tool_input.get('file_path', '')
            if '.env' in file_path and not file_path.endswith('.env.sample'):
                return True
        
        # Check bash commands for .env file write operations (but allow reading)
        elif tool_name == 'Bash':
            command = tool_input.get('command', '')
            # Pattern to detect .env file write operations (but allow reading like cat, less, etc.)
            env_write_patterns = [
                r'echo\s+.*>\s*\.env\b(?!\.sample)',  # echo > .env (write)
                r'echo\s+.*>>\s*\.env\b(?!\.sample)',  # echo >> .env (append)
                r'touch\s+.*\.env\b(?!\.sample)',  # touch .env (create)
                r'cp\s+.*\s+\.env\b(?!\.sample)',  # cp something .env (copy to .env)
                r'mv\s+.*\s+\.env\b(?!\.sample)',  # mv something .env (move to .env)
                r'>\s*\.env\b(?!\.sample)',  # redirect output to .env
                r'>>\s*\.env\b(?!\.sample)',  # append output to .env
                r'\bnano\s+.*\.env\b(?!\.sample)',  # nano .env
                r'\bvim?\s+.*\.env\b(?!\.sample)',  # vim/vi .env
                r'\bemacs\s+.*\.env\b(?!\.sample)',  # emacs .env
                r'sed\s+.*-i.*\.env\b(?!\.sample)',  # sed -i (in-place edit) .env
            ]
            
            for pattern in env_write_patterns:
                if re.search(pattern, command):
                    return True
    
    return False

def main():
    try:
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)
        
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
        
        # Check for .env file write access (blocks writing to sensitive environment files but allows reading)
        if is_env_file_write_access(tool_name, tool_input):
            print("BLOCKED: Writing to .env files containing sensitive data is prohibited", file=sys.stderr)
            print("Reading .env files is allowed, but modifications are blocked for security", file=sys.stderr)
            print("Use .env.sample for template files that can be modified", file=sys.stderr)
            sys.exit(2)  # Exit code 2 blocks tool call and shows error to Claude
        
        # Check for dangerous rm -rf commands
        if tool_name == 'Bash':
            command = tool_input.get('command', '')
            
            # Block rm -rf commands with comprehensive pattern matching
            is_dangerous, reason = is_dangerous_rm_command(command)
            if is_dangerous:
                print("🚫 BLOCKED: Dangerous rm command detected", file=sys.stderr)
                print(f"Command attempted: {command}", file=sys.stderr)
                print(f"Issue: {reason} can accidentally delete important files\n", file=sys.stderr)
                print("Suggested alternatives:", file=sys.stderr)
                print(get_rm_command_guidance(command), file=sys.stderr)
                sys.exit(2)  # Exit code 2 blocks tool call and shows error to Claude
        
        sys.exit(0)
        
    except json.JSONDecodeError:
        # Gracefully handle JSON decode errors
        sys.exit(0)
    except Exception:
        # Handle any other errors gracefully
        sys.exit(0)

if __name__ == '__main__':
    main()