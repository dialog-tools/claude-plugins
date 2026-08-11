# Git Worktree Performance Optimization

Best practices for optimal performance when working with git worktrees.

## General Performance Tips

### Limit Active Worktrees

**Recommendation:** Maintain 3-5 active worktrees maximum for typical development.

**Why:**
- Each worktree consumes disk space for working files
- Active processes (dev servers, IDEs) multiply per worktree
- Memory usage scales with number of active worktrees

**Implementation:**
```bash
# Audit active worktrees regularly
git worktree list

# Remove unused worktrees
git worktree remove ../myproject-worktrees/old-feature
```

### Clean Up Regularly

**Schedule:** Review worktrees weekly or after completing features.

```bash
# List all worktrees with status
git worktree list --porcelain

# Remove merged/abandoned worktrees
git worktree remove <path>

# Prune stale administrative files
git worktree prune
```

**Automation:**
```bash
# Add to weekly maintenance script
#!/bin/bash
echo "Active worktrees:"
git worktree list
echo ""
echo "Run 'git worktree remove <path>' for unused worktrees"
```

### Share .git Objects (Automatic)

**How it works:**
- Git worktrees share the same `.git` directory
- Objects (commits, trees, blobs) stored once
- Significant disk space savings

**Example:**
```
Main repo: .git (500 MB)
Worktree 1: .git (link) + working files (50 MB)
Worktree 2: .git (link) + working files (50 MB)
Total: 600 MB instead of 1500 MB
```

**Verification:**
```bash
# Check that .git is a link in worktrees
ls -la ~/projects/myproject-worktrees/feature-a/.git
# Should show: .git -> /path/to/main/.git/worktrees/feature-a
```

### Use SSD for Worktree Directories

**Recommendation:** Store worktrees on SSD for better performance.

**Why:**
- Faster file operations
- Quicker IDE indexing
- Improved git operations (status, diff, etc.)

**Implementation:**
```bash
# Create worktrees on SSD volume
git worktree add /ssd/projects/myproject-worktrees/feature-a -b feature-a

# Avoid slow HDDs for active worktrees
```

---

## Disk Space Optimization

### Monitor Disk Usage

```bash
# Check total size of worktrees directory
du -sh ~/projects/myproject-worktrees/

# Check individual worktree sizes
du -sh ~/projects/myproject-worktrees/*

# Find largest directories
du -h ~/projects/myproject-worktrees/* | sort -rh | head -10
```

### Clean Build Artifacts

**Regular cleanup:**
```bash
# Remove node_modules from inactive worktrees
find ~/projects/myproject-worktrees -name "node_modules" -type d -prune -exec rm -rf {} +

# Remove build directories
find ~/projects/myproject-worktrees -name "dist" -type d -prune -exec rm -rf {} +
find ~/projects/myproject-worktrees -name "build" -type d -prune -exec rm -rf {} +
```

**Before removing worktree:**
```bash
# Clean before removal
cd ~/projects/myproject-worktrees/feature-a
npm run clean  # or equivalent cleanup script
cd ..
git worktree remove feature-a
```

### Share Package Caches

**npm:**
```bash
# npm cache is already shared globally
npm config get cache
# Usually: ~/.npm
```

**yarn:**
```bash
# Yarn cache is shared
yarn cache dir
# Usually: ~/Library/Caches/yarn
```

**pnpm:**
```bash
# pnpm uses content-addressable store (most efficient)
pnpm store path
# Usually: ~/.pnpm-store
```

**Python pip:**
```bash
# pip cache is shared
pip cache dir
# Usually: ~/Library/Caches/pip
```

---

## Memory Optimization

### Limit Concurrent Dev Servers

**Problem:** Running dev servers in multiple worktrees consumes RAM.

**Solution:**
```bash
# Stop inactive dev servers
# Use unique port management to track which are running
lsof -i :3000  # Check if dev server running
lsof -i :3001
lsof -i :3002

# Kill inactive dev servers
kill <PID>
```

### IDE Memory Management

**VS Code:**
```json
// settings.json - limit file watchers
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/dist/**": true,
    "**/.git/objects/**": true
  }
}
```

**IntelliJ/WebStorm:**
- Adjust IDE heap size: Help > Edit Custom VM Options
- Exclude directories: Right-click folder > Mark Directory As > Excluded

### Close Inactive Worktrees

**Best practice:** Close IDE windows and terminals for worktrees not actively in use.

```bash
# tmux: kill inactive sessions
tmux kill-session -t feature-a

# VS Code: close windows
# Manual or via command:
# osascript -e 'quit app "Visual Studio Code"'
```

---

## Git Performance

### Fetch Once, Use Everywhere

**Benefit:** Since worktrees share `.git`, fetching in one location updates all.

```bash
# Fetch in main repo
cd ~/projects/myproject
git fetch --all

# All worktrees now have updated refs
cd ~/projects/myproject-worktrees/feature-a
git log origin/main  # Already up to date
```

### Sparse Checkout (Advanced)

**Use case:** Large repositories where you only need subset of files per worktree.

```bash
# Enable sparse checkout
git sparse-checkout init --cone

# In worktree, only checkout specific directories
git sparse-checkout set src/frontend

# Working directory only contains src/frontend
```

**Note:** Sparse checkout is per-worktree, so each can have different active paths.

### Shallow Clones (CI/CD)

**Not recommended for worktrees:** Shallow clones don't work well with worktrees since history is shared.

If using shallow clone:
```bash
# Don't use worktrees with shallow clones
git clone --depth 1 <repo>  # Avoid with worktrees
```

---

## Network Performance

### Reduce Remote Operations

**Worktrees share remote refs:**
```bash
# No need to fetch per worktree
# Fetch once in main repo, all worktrees updated
cd ~/projects/myproject
git fetch --all --prune
```

### Batch Push Operations

**Efficient:**
```bash
# Push from multiple worktrees
cd ~/projects/myproject-worktrees/feature-a
git push origin feature-a

cd ~/projects/myproject-worktrees/bugfix-b
git push origin bugfix-b
```

**Note:** Each worktree can push independently - no performance issues.

---

## Build Performance

### Share Build Caches

**Webpack/Vite:**
```javascript
// vite.config.js - use shared cache
export default {
  cacheDir: '/path/to/shared/.vite',
}
```

**Note:** Shared build caches can cause conflicts if different worktrees have different dependencies.

**Recommendation:** Use per-worktree caches for safety.

### Parallel Builds

**Benefit:** Build multiple worktrees in parallel.

```bash
# Terminal 1
cd ~/projects/myproject-worktrees/feature-a
npm run build

# Terminal 2 (simultaneously)
cd ~/projects/myproject-worktrees/bugfix-b
npm run build
```

**Use case:** Pre-build multiple features for testing/deployment.

---

## Monitoring and Profiling

### Track Worktree Count

```bash
# Count active worktrees
git worktree list | wc -l

# Alert if too many
WORKTREE_COUNT=$(git worktree list | wc -l)
if [ "$WORKTREE_COUNT" -gt 5 ]; then
  echo "Warning: $WORKTREE_COUNT worktrees active. Consider cleanup."
fi
```

### Monitor Disk Usage Over Time

```bash
# Log disk usage weekly
echo "$(date): $(du -sh ~/projects/myproject-worktrees)" >> ~/.worktree-usage.log

# Review log
tail -20 ~/.worktree-usage.log
```

### Performance Profiling

**Git operations:**
```bash
# Enable git trace for performance debugging
GIT_TRACE=1 git worktree list
GIT_TRACE_PERFORMANCE=1 git status
```

---

## Summary of Recommendations

| Action | Frequency | Impact |
|--------|-----------|--------|
| Limit to 3-5 active worktrees | Ongoing | High |
| Clean up unused worktrees | Weekly | High |
| Use SSD for worktrees | Setup | Medium |
| Stop inactive dev servers | Daily | Medium |
| Clean build artifacts | Monthly | Medium |
| Monitor disk usage | Monthly | Low |
| Fetch once (main repo) | As needed | Low |

**Key Principle:** Treat worktrees as temporary workspaces, not permanent installations.
