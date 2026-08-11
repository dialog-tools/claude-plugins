# Advanced Git Worktree Operations

Advanced techniques and operations for git worktrees beyond basic create/remove.

## Moving Worktrees

Move a worktree to a new filesystem location:

```bash
# Move a worktree to a new location
git worktree move <worktree> <new-path>

# Example
git worktree move ../old-location/feature-a ../new-location/feature-a
```

**Use cases:**
- Reorganizing worktree directory structure
- Moving to faster storage (HDD → SSD)
- Consolidating worktrees to new location

**Note:** Git automatically updates all references and links.

---

## Locking Worktrees

Lock worktrees to prevent accidental removal:

```bash
# Lock a worktree
git worktree lock <path>

# Lock with reason
git worktree lock <path> --reason "In use by CI system"

# Check if locked
git worktree list  # Shows "locked" status

# Unlock
git worktree unlock <path>
```

**Use cases:**
- Network drives that may disconnect
- CI/CD systems using worktrees
- Shared development environments
- Critical long-running worktrees

**Example - CI/CD:**
```bash
# Lock worktree used by CI
git worktree lock ../ci-build --reason "Jenkins build in progress"

# Jenkins job cleans up after completion
git worktree unlock ../ci-build
git worktree remove ../ci-build
```

---

## Repairing Worktrees

If worktree metadata becomes corrupted:

```bash
# Repair worktree administrative files
git worktree repair

# Repair from specific worktree
cd <worktree-path>
git worktree repair
```

**When to use:**
- After system crash
- After moving .git directory manually
- When `git status` fails in worktree
- After restoring from backup

**What it fixes:**
- Broken links between worktree and .git directory
- Corrupted gitdir references
- Missing administrative files

---

## Git Configuration for Worktrees

### Shared Configuration

By default, most git config is shared across worktrees:

```bash
# Set global config (affects all worktrees)
git config user.name "Your Name"
git config user.email "you@example.com"

# These settings shared:
# - user.name
# - user.email
# - core.editor
# - core.excludesfile
# - most other config
```

### Worktree-Specific Configuration

Set configuration only for current worktree:

```bash
# Set config only for current worktree
git config --worktree user.email "worktree-specific@email.com"

# View worktree-specific config
git config --worktree --list

# Example: Different commit email per worktree
cd ~/projects/worktrees/work-feature
git config --worktree user.email "work@company.com"

cd ~/projects/worktrees/personal-feature
git config --worktree user.email "personal@email.com"
```

**Use cases:**
- Different email per worktree (work vs. personal)
- Worktree-specific merge strategies
- Custom commit templates per worktree

---

## Worktree-Specific Hooks

Hooks are stored in `.git/hooks` and shared by default.

### Shared Hooks (Default)

```bash
# All worktrees use the same hooks
ls .git/hooks/
# pre-commit, post-commit, etc.
```

### Worktree-Specific Hooks (Git 2.36+)

```bash
# Enable worktree-specific hooks
git config core.hooksPath .git/worktrees/<worktree-name>/hooks

# Create hooks directory
mkdir -p .git/worktrees/feature-a/hooks

# Add worktree-specific hook
cat > .git/worktrees/feature-a/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running worktree-specific pre-commit hook"
EOF

chmod +x .git/worktrees/feature-a/hooks/pre-commit
```

**Use cases:**
- Different linting rules per worktree
- Experimental features in one worktree
- Team-specific hooks for different worktrees

---

## Worktree Internals

### File Structure

Understanding the internal structure helps with troubleshooting:

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
# View .git file contents
cat ~/projects/worktrees/feature-a/.git

# Output:
gitdir: /path/to/main/repo/.git/worktrees/feature-a
```

**This link:**
- Points to administrative directory in main .git
- Allows worktree to access shared objects
- Enables git commands to work in worktree

---

## Advanced Integration Patterns

### CI/CD with Worktrees

Create temporary worktrees for builds without disrupting development:

```bash
# Create temporary worktree for CI build
git worktree add --detach ../ci-build <commit-sha>
cd ../ci-build
# Run build/tests
cd ..
git worktree remove ../ci-build
```

**Benefits:**
- Isolated build environment
- No interference with development worktrees
- Faster than full clone
- Shares objects with main repo

**Example - GitHub Actions:**
```yaml
name: Build with Worktree
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create build worktree
        run: |
          git worktree add ../build --detach ${{ github.sha }}
          cd ../build
          npm run build
```

### Multiple Remote Branches

Work with different remotes in separate worktrees:

```bash
# Create worktree from remote branch
git worktree add ../feature-remote origin/feature-name

# Track different remotes in different worktrees
git worktree add ../upstream-fix -b fix upstream/main
git worktree add ../origin-feature -b feature origin/main
```

**Use cases:**
- Compare implementations across forks
- Work on both upstream and origin simultaneously
- Review PRs from different remotes

### Bisecting with Worktrees

Use worktree for git bisect without disrupting main work:

```bash
# Use worktree for git bisect
git worktree add ../bisect-tree <commit>
cd ../bisect-tree
git bisect start
git bisect bad
git bisect good <commit>
# ... bisect process
cd ..
git worktree remove ../bisect-tree
```

**Benefits:**
- Main worktree unaffected
- Continue development while bisecting
- Isolate bisect testing environment

---

## Detached HEAD Worktrees

Create worktrees without branch association:

```bash
# Create detached HEAD worktree
git worktree add --detach ../detached-tree <commit-sha>

# Useful for:
# - One-time builds
# - Testing specific commits
# - CI/CD temporary environments
```

**Warning:** Commits in detached HEAD state may be lost unless:
- You create a branch: `git checkout -b new-branch`
- You tag the commit: `git tag temp-tag`
- You note the commit SHA

---

## Sparse Checkout in Worktrees

Work with subset of repository in worktree:

```bash
# Create sparse worktree (Git 2.40+)
git worktree add --sparse ../sparse-tree branch-name

# In the worktree, enable sparse checkout
cd ../sparse-tree
git sparse-checkout init --cone
git sparse-checkout set path/to/needed/files

# Only specified paths are checked out
ls  # Shows only path/to/needed/files
```

**Use cases:**
- Large monorepos - only checkout relevant portion
- Frontend/backend separation in same repo
- Docs-only worktree for documentation updates

**Benefits:**
- Faster checkouts
- Less disk space
- Reduced IDE indexing time

---

## Platform-Specific Advanced Techniques

### Windows Symbolic Links

```powershell
# Enable symbolic links (may require admin)
git config --global core.symlinks true

# Worktrees work with symlinks on Windows 10+
git worktree add ../worktrees/feature-a -b feature-a
```

### macOS/Linux Hard Links

```bash
# Git automatically uses hard links for space efficiency
# No configuration needed
```

### Network Drives

Worktrees on network drives require special handling:

```bash
# Always lock network drive worktrees
git worktree add //network/share/worktrees/feature-a -b feature-a
git worktree lock //network/share/worktrees/feature-a --reason "Network drive"

# Use repair if network disconnects
git worktree repair
```

**Recommendation:** Avoid network drives for active development worktrees. Use for:
- CI/CD temporary builds
- Backup/archive worktrees
- Read-only review worktrees

---

## Summary of Advanced Commands

| Command | Use Case |
|---------|----------|
| `git worktree move` | Relocate worktree |
| `git worktree lock` | Prevent accidental removal |
| `git worktree repair` | Fix corrupted metadata |
| `git config --worktree` | Worktree-specific settings |
| `git worktree add --detach` | Detached HEAD worktree |
| `git worktree add --sparse` | Sparse checkout worktree |
| `git sparse-checkout set` | Configure sparse paths |
