# Git Worktree Automation and Scripting

Bash functions, aliases, and scripts to automate common worktree workflows.

## Bash Functions for Worktree Management

### Function: Create Worktree with Auto-Setup

```bash
# Function to create worktree with auto-setup
wt-create() {
    local branch=$1
    local path="../worktrees/${branch}"

    git worktree add "$path" -b "$branch"
    cd "$path"

    # Auto-detect and run setup
    if [ -f "package.json" ]; then
        npm install
    elif [ -f "requirements.txt" ]; then
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    fi

    # Copy env file
    if [ -f "../.env.sample" ]; then
        cp ../.env.sample .env
    fi
}
```

**Usage:**
```bash
wt-create my-feature
# Creates worktree, installs dependencies, copies .env
```

### Function: Clean Up All Worktrees

```bash
# Function to clean up all worktrees
wt-cleanup() {
    git worktree list --porcelain | grep "worktree" | cut -d' ' -f2 | while read wt; do
        if [ "$wt" != "$(git rev-parse --show-toplevel)" ]; then
            echo "Removing $wt"
            git worktree remove "$wt" 2>/dev/null || echo "Skipped $wt"
        fi
    done
    git worktree prune
}
```

**Usage:**
```bash
wt-cleanup
# Removes all worktrees except main
```

### Function: List Worktrees with Status

```bash
# Function to list worktrees with status
wt-status() {
    git worktree list --porcelain | awk '
        /^worktree/ { path=$2 }
        /^HEAD/ { head=$2 }
        /^branch/ { branch=$2; print path, branch, head; head=""; branch="" }
        /^detached/ { print path, "DETACHED", head; head="" }
    '
}
```

**Usage:**
```bash
wt-status
# Shows worktree paths with branch and commit info
```

### Function: Interactive Worktree Switcher

```bash
# Function to interactively switch between worktrees
wt-switch() {
    local worktrees=($(git worktree list | awk '{print $1}'))
    local PS3="Select worktree: "

    select wt in "${worktrees[@]}"; do
        if [ -n "$wt" ]; then
            cd "$wt"
            echo "Switched to $wt"
            break
        fi
    done
}
```

**Usage:**
```bash
wt-switch
# Shows menu to select worktree, then cd to it
```

### Function: Create Worktree with Unique Port

```bash
# Function to create worktree with unique port in .env
wt-create-with-port() {
    local branch=$1
    local port=$2
    local path="../worktrees/${branch}"

    git worktree add "$path" -b "$branch"
    cd "$path"

    # Copy env and set unique port
    if [ -f "../.env.sample" ]; then
        cp ../.env.sample .env
        echo "PORT=$port" >> .env
    fi

    npm install
}
```

**Usage:**
```bash
wt-create-with-port my-feature 3001
# Creates worktree with PORT=3001 in .env
```

---

## Git Aliases

Add to `~/.gitconfig`:

```bash
[alias]
    # Short aliases
    wt = worktree
    wtl = worktree list
    wta = worktree add
    wtr = worktree remove
    wtp = worktree prune

    # More descriptive aliases
    worktrees = worktree list
    wt-create = worktree add
    wt-delete = worktree remove
    wt-clean = worktree prune

    # Advanced aliases
    wt-status = "!git worktree list --porcelain | awk '/^worktree/ {path=$2} /^branch/ {print path, $2}'"
    wt-branches = "!git worktree list | awk '{print $3}' | sed 's/\\[//;s/\\]//'"
```

**Usage:**
```bash
git wt list
git wta ../worktrees/feature -b feature
git wtr ../worktrees/feature
git wtp
```

---

## Shell Scripts

### Script: Worktree Creation with Project Detection

Save as `~/bin/wt-create.sh`:

```bash
#!/bin/bash
set -e

BRANCH=$1
WORKTREE_DIR="../worktrees"
WORKTREE_PATH="$WORKTREE_DIR/$BRANCH"

if [ -z "$BRANCH" ]; then
    echo "Usage: wt-create.sh <branch-name>"
    exit 1
fi

# Create worktree directory if it doesn't exist
mkdir -p "$WORKTREE_DIR"

# Create worktree
echo "Creating worktree for $BRANCH..."
git worktree add "$WORKTREE_PATH" -b "$BRANCH"

cd "$WORKTREE_PATH"

# Detect project type and setup
if [ -f "package.json" ]; then
    echo "Detected Node.js project, running npm install..."
    npm install
elif [ -f "requirements.txt" ]; then
    echo "Detected Python project, setting up venv..."
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
elif [ -f "Gemfile" ]; then
    echo "Detected Ruby project, running bundle install..."
    bundle install
elif [ -f "go.mod" ]; then
    echo "Detected Go project, running go mod download..."
    go mod download
fi

# Copy environment files
for env_file in ../.env.sample ../.env.example; do
    if [ -f "$env_file" ]; then
        echo "Copying environment file..."
        cp "$env_file" .env
        break
    fi
done

echo "✓ Worktree created at $WORKTREE_PATH"
echo "  Run: cd $WORKTREE_PATH"
```

**Usage:**
```bash
chmod +x ~/bin/wt-create.sh
wt-create.sh my-feature
```

### Script: Worktree Cleanup with Confirmation

Save as `~/bin/wt-cleanup.sh`:

```bash
#!/bin/bash

echo "Active worktrees:"
git worktree list

echo ""
read -p "Remove all worktrees except main? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git worktree list --porcelain | grep "worktree" | cut -d' ' -f2 | while read wt; do
        if [ "$wt" != "$(git rev-parse --show-toplevel)" ]; then
            echo "Removing $wt..."
            git worktree remove "$wt" 2>/dev/null || echo "Skipped $wt (has uncommitted changes)"
        fi
    done

    echo "Pruning stale worktree references..."
    git worktree prune

    echo "✓ Cleanup complete"
else
    echo "Cleanup cancelled"
fi
```

**Usage:**
```bash
chmod +x ~/bin/wt-cleanup.sh
wt-cleanup.sh
```

---

## Advanced Automation

### CI/CD Script: Temporary Worktree Build

```bash
#!/bin/bash
# ci-build.sh - Build in temporary worktree

set -e

COMMIT_SHA=$1
BUILD_DIR="../ci-build-$$"  # Unique per process

# Create temporary build worktree
git worktree add --detach "$BUILD_DIR" "$COMMIT_SHA"

# Cleanup on exit
trap "git worktree remove --force '$BUILD_DIR'" EXIT

cd "$BUILD_DIR"

# Run build
npm install
npm run build
npm test

# Artifacts are in $BUILD_DIR/dist
# Copy if needed before cleanup
```

### Hook: Pre-Commit Check for All Worktrees

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check that all worktrees are in clean state before committing
WORKTREES=$(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2)

for wt in $WORKTREES; do
    if [ "$wt" != "$(git rev-parse --show-toplevel)" ]; then
        cd "$wt"
        if ! git diff-index --quiet HEAD --; then
            echo "Error: Worktree $wt has uncommitted changes"
            exit 1
        fi
    fi
done
```

### Cron Job: Weekly Worktree Audit

```bash
# Add to crontab: crontab -e
# Run every Monday at 9 AM
0 9 * * 1 /path/to/worktree-audit.sh

# worktree-audit.sh
#!/bin/bash
cd ~/projects/my-project

echo "Weekly Worktree Audit - $(date)" >> ~/worktree-audit.log
git worktree list >> ~/worktree-audit.log
echo "---" >> ~/worktree-audit.log

# Notify if too many worktrees
WORKTREE_COUNT=$(git worktree list | wc -l)
if [ "$WORKTREE_COUNT" -gt 5 ]; then
    echo "Warning: $WORKTREE_COUNT worktrees active!" | mail -s "Worktree Audit" user@example.com
fi
```

---

## Integration with Task Runners

### npm Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "wt:create": "git worktree add ../worktrees/$npm_config_branch -b $npm_config_branch && cd ../worktrees/$npm_config_branch && npm install",
    "wt:list": "git worktree list",
    "wt:clean": "git worktree prune"
  }
}
```

**Usage:**
```bash
npm run wt:create --branch=my-feature
npm run wt:list
npm run wt:clean
```

### Make Targets

Add to `Makefile`:

```makefile
.PHONY: wt-create wt-list wt-clean

wt-create:
	@read -p "Branch name: " branch; \
	git worktree add ../worktrees/$$branch -b $$branch && \
	cd ../worktrees/$$branch && \
	make setup

wt-list:
	@git worktree list

wt-clean:
	@git worktree prune
	@echo "Cleaned up stale worktree references"

setup:
	npm install
	cp ../.env.sample .env || true
```

**Usage:**
```bash
make wt-create
make wt-list
make wt-clean
```

---

## Shell Configuration

### Add to `~/.bashrc` or `~/.zshrc`

```bash
# Git Worktree helpers
export WORKTREE_DIR="../worktrees"

# Source worktree functions
if [ -f ~/.git-worktree-functions.sh ]; then
    source ~/.git-worktree-functions.sh
fi

# Prompt shows worktree status
parse_git_worktree() {
    local worktree=$(git rev-parse --show-toplevel 2>/dev/null)
    local gitdir=$(git rev-parse --git-common-dir 2>/dev/null)

    if [[ "$worktree" != "$gitdir/.." ]] && [[ -n "$worktree" ]]; then
        echo " [WT:$(basename $worktree)]"
    fi
}

# Add to PS1
export PS1='$(parse_git_worktree)\$ '
```

---

## Summary of Automation Scripts

| Script/Function | Purpose |
|----------------|---------|
| `wt-create` | Create worktree with auto-setup |
| `wt-cleanup` | Remove all worktrees |
| `wt-status` | List worktrees with status |
| `wt-switch` | Interactive worktree switcher |
| Git aliases | Short commands for common operations |
| CI build script | Temporary worktree for builds |
| Audit cron job | Weekly worktree monitoring |
