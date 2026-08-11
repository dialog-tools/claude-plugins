#!/bin/bash

# Git Worktree Helper Script
# Provides convenient functions for managing worktrees with Claude Code workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check if in git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error_exit "Not in a git repository. Please navigate to a git repository first."
    fi
}

# Get the main repo directory
get_main_repo() {
    check_git_repo
    git rev-parse --show-toplevel
}

# Get username for branch prefixing
get_username() {
    local username=$(git config user.name 2>/dev/null)
    if [ -z "$username" ]; then
        error_exit "Git user.name not configured. Run: git config user.name 'Your Name'"
    fi
    echo "$username" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

# Create a new worktree with full setup
wt_create() {
    local feature_name=$1

    # Validate input
    if [ -z "$feature_name" ]; then
        error_exit "Feature name is required"
    fi

    # Validate feature name format (no spaces, special chars except - and _)
    if [[ ! "$feature_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error_exit "Feature name must contain only letters, numbers, hyphens, and underscores"
    fi

    local username=$(get_username)
    local main_repo=$(get_main_repo)
    local repo_name=$(basename "$main_repo")
    local worktrees_dir="$(dirname "$main_repo")/${repo_name}-worktrees"
    local branch_name="${username}/${feature_name}"
    local worktree_path="${worktrees_dir}/${feature_name}"

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        error_exit "Worktree directory already exists: $worktree_path"
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        error_exit "Branch already exists: $branch_name"
    fi

    echo -e "${BLUE}Creating worktree for: ${feature_name}${NC}"
    echo -e "Branch: ${branch_name}"
    echo -e "Path: ${worktree_path}"

    # Create worktrees directory if it doesn't exist
    mkdir -p "$worktrees_dir" || error_exit "Failed to create worktrees directory"

    # Create the worktree
    if ! git worktree add "$worktree_path" -b "$branch_name" 2>&1; then
        error_exit "Failed to create worktree. Check git worktree output above."
    fi

    # Navigate to worktree
    cd "$worktree_path"
    echo -e "${GREEN}✓ Worktree created${NC}"

    # Auto-detect project type and setup
    echo -e "${BLUE}Setting up environment...${NC}"

    if [ -f "package.json" ]; then
        echo -e "${YELLOW}Detected Node.js project${NC}"
        if command -v npm &> /dev/null; then
            if npm install; then
                echo -e "${GREEN}✓ npm install complete${NC}"
            else
                echo -e "${YELLOW}⚠ npm install failed (continuing anyway)${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ npm not found, skipping dependency installation${NC}"
        fi
    fi

    if [ -f "requirements.txt" ]; then
        echo -e "${YELLOW}Detected Python project${NC}"
        if command -v python3 &> /dev/null; then
            if python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt; then
                echo -e "${GREEN}✓ pip install complete${NC}"
            else
                echo -e "${YELLOW}⚠ pip install failed (continuing anyway)${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ python3 not found, skipping dependency installation${NC}"
        fi
    fi

    if [ -f "Cargo.toml" ]; then
        echo -e "${YELLOW}Detected Rust project${NC}"
        if command -v cargo &> /dev/null; then
            cargo build 2>/dev/null || echo -e "${YELLOW}⚠ cargo build failed (continuing anyway)${NC}"
        else
            echo -e "${YELLOW}⚠ cargo not found, skipping build${NC}"
        fi
    fi

    if [ -f "go.mod" ]; then
        echo -e "${YELLOW}Detected Go project${NC}"
        if command -v go &> /dev/null; then
            go mod download 2>/dev/null || echo -e "${YELLOW}⚠ go mod download failed (continuing anyway)${NC}"
        else
            echo -e "${YELLOW}⚠ go not found, skipping dependency download${NC}"
        fi
    fi

    # Copy environment files
    if [ -f "$main_repo/.env.sample" ]; then
        cp "$main_repo/.env.sample" .env
        echo -e "${GREEN}✓ Copied .env.sample to .env${NC}"
    elif [ -f "$main_repo/.env.example" ]; then
        cp "$main_repo/.env.example" .env
        echo -e "${GREEN}✓ Copied .env.example to .env${NC}"
    fi

    echo -e "${GREEN}✓ Setup complete!${NC}"
    echo -e "${BLUE}You are now in: ${worktree_path}${NC}"
    echo -e "${BLUE}To start Claude: ${YELLOW}claude${NC}"
}

# List all worktrees with nice formatting
wt_list() {
    echo -e "${BLUE}=== Git Worktrees ===${NC}"
    git worktree list --porcelain | awk -v green="$GREEN" -v yellow="$YELLOW" -v nc="$NC" '
        /^worktree/ {
            path=$2
            sub(/.*\//, "", path)
        }
        /^HEAD/ { head=substr($2, 1, 7) }
        /^branch/ {
            branch=$2
            sub(/.*\//, "", branch)
            printf "%s%-30s%s %s%-15s%s %s\n", green, path, nc, yellow, branch, nc, head
            head=""; branch=""
        }
        /^detached/ {
            printf "%s%-30s%s %sDETACHED%s %s\n", green, path, nc, yellow, nc, head
            head=""
        }
    '
}

# Remove a worktree by name
wt_remove() {
    local feature_name=$1

    # Validate input
    if [ -z "$feature_name" ]; then
        error_exit "Feature name is required"
    fi

    local main_repo=$(get_main_repo)
    local repo_name=$(basename "$main_repo")
    local worktrees_dir="$(dirname "$main_repo")/${repo_name}-worktrees"
    local worktree_path="${worktrees_dir}/${feature_name}"

    # Check if worktree exists
    if [ ! -d "$worktree_path" ]; then
        error_exit "Worktree '${feature_name}' not found at: $worktree_path"
    fi

    # Check for uncommitted changes
    cd "$worktree_path"
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${YELLOW}⚠ Warning: Worktree has uncommitted changes${NC}"
        read -p "Continue with removal? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Removal cancelled${NC}"
            return 0
        fi
    fi

    cd "$main_repo"
    echo -e "${YELLOW}Removing worktree: ${feature_name}${NC}"

    if ! git worktree remove "$worktree_path" 2>&1; then
        echo -e "${YELLOW}Normal removal failed, trying force removal...${NC}"
        if ! git worktree remove --force "$worktree_path" 2>&1; then
            error_exit "Failed to remove worktree even with --force"
        fi
    fi

    echo -e "${GREEN}✓ Worktree removed${NC}"
}

# Clean up all worktrees
wt_cleanup() {
    echo -e "${YELLOW}Cleaning up worktrees...${NC}"
    git worktree prune
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Start Claude in a specific worktree
wt_claude() {
    local feature_name=$1
    local main_repo=$(get_main_repo)
    local repo_name=$(basename "$main_repo")
    local worktrees_dir="$(dirname "$main_repo")/${repo_name}-worktrees"
    local worktree_path="${worktrees_dir}/${feature_name}"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree '${feature_name}' not found${NC}"
        return 1
    fi

    cd "$worktree_path"
    echo -e "${GREEN}Starting Claude in: ${worktree_path}${NC}"
    claude
}

# Main command handler
case "${1:-help}" in
    create|new)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Feature name required${NC}"
            echo "Usage: $0 create <feature-name>"
            exit 1
        fi
        wt_create "$2"
        ;;
    list|ls)
        wt_list
        ;;
    remove|rm)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Feature name required${NC}"
            echo "Usage: $0 remove <feature-name>"
            exit 1
        fi
        wt_remove "$2"
        ;;
    cleanup|prune)
        wt_cleanup
        ;;
    claude)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Feature name required${NC}"
            echo "Usage: $0 claude <feature-name>"
            exit 1
        fi
        wt_claude "$2"
        ;;
    help|*)
        echo -e "${BLUE}Git Worktree Helper${NC}"
        echo ""
        echo "Usage: $0 <command> [arguments]"
        echo ""
        echo "Commands:"
        echo -e "  ${GREEN}create${NC} <name>    Create new worktree with setup"
        echo -e "  ${GREEN}list${NC}             List all worktrees"
        echo -e "  ${GREEN}remove${NC} <name>    Remove a worktree"
        echo -e "  ${GREEN}cleanup${NC}          Clean up stale worktree references"
        echo -e "  ${GREEN}claude${NC} <name>    Start Claude in a worktree"
        echo -e "  ${GREEN}help${NC}             Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 create dashboard-feature"
        echo "  $0 list"
        echo "  $0 claude dashboard-feature"
        echo "  $0 remove dashboard-feature"
        ;;
esac
