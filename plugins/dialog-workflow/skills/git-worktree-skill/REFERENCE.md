# Git Worktree Reference Guide

This document provides additional reference information for git worktrees that Claude can access when needed for specific scenarios.

## Advanced Worktree Operations

### Moving Worktrees

```bash
# Move a worktree to a new location
git worktree move <worktree> <new-path>

# Example
git worktree move ../old-location/feature-a ../new-location/feature-a
```

### Locking Worktrees

Lock worktrees to prevent accidental removal (useful on network drives or automated systems):

```bash
# Lock a worktree
git worktree lock <path>

# Lock with reason
git worktree lock <path> --reason "In use by CI system"

# Unlock
git worktree unlock <path>
```

### Repairing Worktrees

If worktree metadata becomes corrupted:

```bash
# Repair worktree administrative files
git worktree repair

# Repair from specific worktree
cd <worktree-path>
git worktree repair
```

## Git Configuration for Worktrees

### Shared Configuration

By default, most git config is shared across worktrees. To set worktree-specific config:

```bash
# Set config only for current worktree
git config --worktree user.email "worktree-specific@email.com"

# View worktree-specific config
git config --worktree --list
```

### Worktree-Specific Hooks

Hooks are stored in `.git/hooks` and shared by default. For worktree-specific hooks:

```bash
# Enable worktree-specific hooks (Git 2.36+)
git config core.hooksPath .git/worktrees/<worktree>/hooks
```

## Worktree Internals

### File Structure

```
.git/
├── worktrees/
│   ├── feature-a/
│   │   ├── gitdir         # Points to worktree location
│   │   ├── HEAD           # Current branch
│   │   ├── ORIG_HEAD
│   │   ├── index          # Staging area
│   │   └── commondir      # Points back to main .git
│   └── feature-b/
│       └── ...
```

### Worktree Link File

In each worktree directory, `.git` is a file (not directory):

```bash
# Contents of worktree/.git
gitdir: /path/to/main/repo/.git/worktrees/feature-a
```

## Integration Patterns

### CI/CD with Worktrees

```bash
# Create temporary worktree for CI build
git worktree add --detach ../ci-build <commit-sha>
cd ../ci-build
# Run build/tests
cd ..
git worktree remove ../ci-build
```

### Multiple Remote Branches

```bash
# Create worktree from remote branch
git worktree add ../feature-remote origin/feature-name

# Track different remotes in different worktrees
git worktree add ../upstream-fix -b fix upstream/main
git worktree add ../origin-feature -b feature origin/main
```

### Bisecting with Worktrees

```bash
# Use worktree for git bisect without disrupting main work
git worktree add ../bisect-tree <commit>
cd ../bisect-tree
git bisect start
git bisect bad
git bisect good <commit>
# ... bisect process
cd ..
git worktree remove ../bisect-tree
```

## Platform-Specific Considerations

### Windows

```powershell
# Use backslashes or forward slashes
git worktree add ..\worktrees\feature-a -b feature-a
# or
git worktree add ../worktrees/feature-a -b feature-a

# Paths in Git Bash
git worktree add /c/projects/worktrees/feature-a -b feature-a
```

### macOS/Linux

```bash
# Use tilde for home directory
git worktree add ~/projects/worktrees/feature-a -b feature-a

# Relative paths work naturally
git worktree add ../worktrees/feature-a -b feature-a
```

### Network Drives

Worktrees on network drives may have performance issues. Consider:
- Using lock files to prevent corruption
- Keeping worktrees on local SSD when possible
- Using `git worktree repair` if issues occur

## Performance Considerations

### Space Efficiency

Worktrees share:
- Object database (commits, trees, blobs)
- References (branches, tags)
- Configuration (most settings)

Only duplicated per worktree:
- Working directory files
- Index (staging area)
- HEAD and branch state

**Typical space usage:**
- Main repo: 500 MB
- Each worktree: 100-200 MB (just working files)

### Speed Optimization

```bash
# Use shallow worktrees for large repos (Git 2.40+)
git worktree add --sparse ../sparse-tree branch-name

# Sparse checkout in worktree
cd ../sparse-tree
git sparse-checkout set path/to/needed/files
```

## Troubleshooting Edge Cases

### Orphaned Worktree References

If worktree directory is deleted manually:

```bash
# Worktree shows in list but doesn't exist
git worktree list
# Shows: /path/to/deleted (bare)

# Remove the reference
git worktree prune

# Or force remove
git worktree remove --force /path/to/deleted
```

### Corrupted Worktree State

```bash
# Reset worktree state
cd <worktree>
git reset --hard

# If that fails, recreate
cd <main-repo>
git worktree remove --force <path>
git worktree add <path> -b <branch>
```

### Branch Checkout Conflicts

```bash
# Error: branch is already checked out at ...
# Solutions:

# 1. Create new branch from same point
git worktree add <path> -b new-branch-name existing-branch

# 2. Checkout detached HEAD
git worktree add --detach <path> <branch>

# 3. Remove old worktree first
git worktree remove <old-path>
git worktree add <new-path> <branch>
```

## Scripting and Automation

### Bash Functions for Worktree Management

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

### Git Aliases

```bash
# Add to ~/.gitconfig
[alias]
    wt = worktree
    wtl = worktree list
    wta = worktree add
    wtr = worktree remove
    wtp = worktree prune
```

## Migration Strategies

### From Multiple Clones to Worktrees

If currently using multiple clones:

```bash
# 1. List your clones
ls ~/projects/

# 2. For each clone, check the branch
cd ~/projects/clone1 && git branch --show-current

# 3. Create worktrees in main repo
cd ~/projects/main-repo
git worktree add ../worktrees/feature-1 <branch-from-clone1>
git worktree add ../worktrees/feature-2 <branch-from-clone2>

# 4. Copy over uncommitted work if needed
cp -r ~/projects/clone1/modified-files ../worktrees/feature-1/

# 5. Remove old clones
rm -rf ~/projects/clone1 ~/projects/clone2
```

### From Stash-Heavy Workflow to Worktrees

If frequently stashing to switch contexts:

```bash
# Instead of:
git stash
git checkout other-branch
# work...
git checkout original-branch
git stash pop

# Use:
git worktree add ../worktrees/other-work other-branch
# Work in separate terminal/window without stashing
```

## Resources and Further Reading

- Git Worktree Manual: `man git-worktree`
- Git Worktree Internals: https://git-scm.com/docs/gitrepository-layout
- Git 2.5 Release Notes (worktree introduction): https://github.com/git/git/blob/master/Documentation/RelNotes/2.5.0.txt
- Multiple Worktree Support in Git GUI tools

## Glossary

- **Main Working Tree**: The original repository checkout
- **Linked Working Tree**: A worktree created with `git worktree add`
- **Worktree Directory**: The actual filesystem location of worktree files
- **Gitdir**: The administrative directory for the worktree (in `.git/worktrees/`)
- **Common Directory**: The shared `.git` directory containing objects and refs
- **Detached HEAD**: Worktree not associated with any branch
- **Bare Repository**: Repository with no working tree (cannot add worktrees)
