# Migrating to Git Worktrees

Step-by-step guides for migrating from common workflows to git worktrees.

## Migration Scenarios

This guide covers:
1. Multiple repository clones → Worktrees
2. Branch switching + stashing → Worktrees
3. Fork-based workflow → Worktrees
4. Monorepo with many features → Worktrees

---

## From Multiple Clones to Worktrees

### Current Workflow

```bash
# Multiple full clones of same repository
~/projects/
├── myproject/              # Main development
├── myproject-feature-1/    # Clone for feature 1
├── myproject-feature-2/    # Clone for feature 2
└── myproject-hotfix/       # Clone for urgent fixes
```

**Problems:**
- Disk space waste (4× repository size)
- Fetching/pulling required in each clone
- Configuration duplication
- Easy to lose track of uncommitted work

### Migration Steps

**1. Audit existing clones:**

```bash
# List your project directories
ls ~/projects/ | grep myproject

# For each clone, check the branch and uncommitted changes
for dir in ~/projects/myproject*; do
    echo "=== $dir ==="
    cd "$dir"
    git branch --show-current
    git status --short
done
```

**2. Identify what to preserve:**

```bash
# Take notes on:
# - Active branch in each clone
# - Any uncommitted changes
# - Any local branches not pushed
# - Any stashes

cd ~/projects/myproject-feature-1
git stash list
git branch --no-merged
```

**3. Create worktrees in main repository:**

```bash
cd ~/projects/myproject  # Main repo

# Create worktrees for each active clone
git worktree add ../worktrees/feature-1 feature-1
git worktree add ../worktrees/feature-2 feature-2
git worktree add ../worktrees/hotfix hotfix-branch
```

**4. Migrate uncommitted work:**

```bash
# Option A: Copy files directly
cp -r ~/projects/myproject-feature-1/modified-file.js \
      ~/projects/worktrees/feature-1/

# Option B: Use git stash
cd ~/projects/myproject-feature-1
git stash
# Note the stash SHA
cd ~/projects/worktrees/feature-1
git stash apply <stash-sha>

# Option C: Create patch
cd ~/projects/myproject-feature-1
git diff > /tmp/feature-1.patch
cd ~/projects/worktrees/feature-1
git apply /tmp/feature-1.patch
```

**5. Verify worktrees:**

```bash
cd ~/projects/myproject
git worktree list

# Check each worktree
cd ~/projects/worktrees/feature-1
git status
npm test  # Verify everything works
```

**6. Remove old clones:**

```bash
# After verifying worktrees work
rm -rf ~/projects/myproject-feature-1
rm -rf ~/projects/myproject-feature-2
rm -rf ~/projects/myproject-hotfix
```

**7. Setup environment in worktrees:**

```bash
# For each worktree
cd ~/projects/worktrees/feature-1
npm install
cp ../../myproject/.env .env
```

### Space Savings Calculation

**Before (multiple clones):**
```
Main clone: 500 MB
Feature 1 clone: 500 MB
Feature 2 clone: 500 MB
Hotfix clone: 500 MB
Total: 2000 MB (2 GB)
```

**After (worktrees):**
```
Main repo .git: 500 MB
Worktree 1 files: 100 MB
Worktree 2 files: 100 MB
Worktree 3 files: 100 MB
Total: 800 MB (0.8 GB)
```

**Savings: 1.2 GB (60% reduction)**

---

## From Stash-Heavy Workflow to Worktrees

### Current Workflow

```bash
# Frequently stashing to switch contexts
git stash                    # Save current work
git checkout other-branch    # Switch branches
# ... work on other branch
git checkout original-branch
git stash pop               # Restore work
```

**Problems:**
- Stash stack becomes confusing
- Risk of applying wrong stash
- Lost productivity switching contexts
- No parallel work possible

### Migration Steps

**1. Audit current stashes:**

```bash
# List all stashes
git stash list

# For each stash, identify what it contains
git stash show -p stash@{0}
git stash show -p stash@{1}
# etc.
```

**2. Create worktrees for active work:**

```bash
# Instead of stashing, create worktree
git worktree add ../worktrees/context-1 -b feature-a
git worktree add ../worktrees/context-2 -b feature-b
```

**3. Migrate stashed work:**

```bash
# Apply stash to appropriate worktree
cd ../worktrees/context-1
git stash apply stash@{0}

cd ../worktrees/context-2
git stash apply stash@{1}
```

**4. Verify and cleanup stashes:**

```bash
# After verifying work is in worktrees
cd ~/projects/myproject
git stash drop stash@{0}
git stash drop stash@{1}
```

### New Workflow

**Before (with stashing):**
```bash
# Working on feature A
git stash
git checkout feature-b
# Work...
git checkout feature-a
git stash pop
```

**After (with worktrees):**
```bash
# Terminal 1: Feature A
cd ~/projects/worktrees/feature-a
# Work continuously...

# Terminal 2: Feature B (no stashing needed!)
cd ~/projects/worktrees/feature-b
# Work continuously...
```

**Benefits:**
- No context switching
- No stash management
- Parallel work
- Less cognitive load

---

## From Fork-Based Workflow to Worktrees

### Current Workflow

```bash
# Fork with multiple remotes
git remote -v
# origin: your-fork (fetch/push)
# upstream: main-repo (fetch only)

# Keeping fork updated
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Enhanced Workflow with Worktrees

**Keep fork workflow, add worktrees:**

```bash
# Main worktree: Track upstream
cd ~/projects/myproject
git remote add upstream https://github.com/original/repo.git

# Worktree for upstream changes
git worktree add ../worktrees/upstream-sync -b upstream-sync upstream/main

# Worktree for your features
git worktree add ../worktrees/my-feature -b my-feature origin/main
```

**Workflow:**

```bash
# Terminal 1: Sync with upstream
cd ~/projects/worktrees/upstream-sync
git pull upstream main
# Review changes
git checkout main
git merge upstream-sync
git push origin main

# Terminal 2: Work on feature (uninterrupted)
cd ~/projects/worktrees/my-feature
# Continue feature work...
```

**Benefits:**
- Sync upstream without disrupting feature work
- Review upstream changes in isolation
- Test compatibility before merging

---

## From Monorepo Many-Feature Workflow to Worktrees

### Current Workflow

```bash
# Monorepo with many features
git branch
# * main
#   feature-frontend-redesign
#   feature-api-v2
#   feature-mobile-app
#   feature-analytics
#   bugfix-auth
#   docs-update
```

**Problems:**
- Constant branch switching
- Lost context between features
- Can't run multiple features simultaneously
- Difficult to compare approaches

### Migration Steps

**1. Identify active branches:**

```bash
# List branches with recent commits
git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'

# Identify which branches to create worktrees for
# Focus on active development branches
```

**2. Create worktree structure:**

```bash
# Organize by category
mkdir -p ../worktrees/{features,bugfixes,experiments,docs}

# Create worktrees
git worktree add ../worktrees/features/frontend-redesign feature-frontend-redesign
git worktree add ../worktrees/features/api-v2 feature-api-v2
git worktree add ../worktrees/features/mobile-app feature-mobile-app
git worktree add ../worktrees/bugfixes/auth bugfix-auth
git worktree add ../worktrees/docs/update docs-update
```

**3. Setup each worktree:**

```bash
# Script to setup all worktrees
for wt in ../worktrees/*/*; do
    echo "Setting up $wt"
    cd "$wt"
    npm install
    cp ../../myproject/.env .env
done
```

**4. Configure unique ports:**

```bash
# Feature 1: PORT=3001
cd ../worktrees/features/frontend-redesign
echo "PORT=3001" >> .env

# Feature 2: PORT=3002
cd ../worktrees/features/api-v2
echo "PORT=3002" >> .env

# etc.
```

**5. Parallel development:**

```bash
# Terminal 1: Frontend redesign
cd ~/projects/worktrees/features/frontend-redesign
npm run dev  # Runs on port 3001

# Terminal 2: API v2
cd ~/projects/worktrees/features/api-v2
npm run dev  # Runs on port 3002

# Terminal 3: Mobile app
cd ~/projects/worktrees/features/mobile-app
npm run dev:mobile
```

### Directory Structure After Migration

```
~/projects/
├── myproject/                    # Main repo
│   └── .git/
└── worktrees/
    ├── features/
    │   ├── frontend-redesign/    # PORT=3001
    │   ├── api-v2/               # PORT=3002
    │   └── mobile-app/
    ├── bugfixes/
    │   └── auth/
    ├── experiments/
    │   └── approach-a/
    └── docs/
        └── update/
```

**Benefits:**
- All features running simultaneously
- Easy to compare implementations
- No branch switching
- Organized by category

---

## Transition Timeline

### Week 1: Setup and Exploration

- [ ] Install/update Git (2.25+)
- [ ] Read worktree documentation
- [ ] Create test worktrees in sandbox repo
- [ ] Identify current workflow pain points

### Week 2: Partial Migration

- [ ] Audit current clones/branches
- [ ] Create worktrees for 2-3 active features
- [ ] Keep old workflow alongside worktrees
- [ ] Compare productivity

### Week 3: Full Migration

- [ ] Create worktrees for all active work
- [ ] Migrate uncommitted changes
- [ ] Setup automation (scripts, aliases)
- [ ] Remove old clones

### Week 4: Optimization

- [ ] Optimize worktree organization
- [ ] Fine-tune development environment
- [ ] Document team workflow
- [ ] Train team members

---

## Rollback Plan

If worktrees don't work for your workflow:

```bash
# List all worktrees
git worktree list

# For each worktree, optionally create clone
cd ~/projects/worktrees/feature-a
git remote -v
git clone <repo-url> ~/projects/myproject-feature-a
cd ~/projects/myproject-feature-a
git checkout feature-a
# Copy uncommitted changes if needed

# Remove worktrees
cd ~/projects/myproject
git worktree remove ../worktrees/feature-a
```

**Note:** Worktrees are non-destructive - your branches and commits are safe.

---

## Post-Migration Checklist

- [ ] All active work migrated to worktrees
- [ ] Old clones removed
- [ ] Automation scripts in place
- [ ] Team members trained
- [ ] Documentation updated
- [ ] Performance is acceptable
- [ ] Backup strategy updated
- [ ] CI/CD still works

---

## Common Migration Mistakes

### Mistake 1: Creating too many worktrees

**Problem:** Migrating every branch to worktree.

**Solution:** Only create worktrees for active development (3-5 max).

### Mistake 2: Forgetting dependencies

**Problem:** Not running `npm install` in worktrees.

**Solution:** Use setup script that auto-detects project type.

### Mistake 3: Shared ports

**Problem:** All worktrees try to use port 3000.

**Solution:** Configure unique PORT in each worktree's .env.

### Mistake 4: Losing uncommitted work

**Problem:** Removing old clone before migrating changes.

**Solution:** Always verify work is in worktree before removing clone.

### Mistake 5: Not updating IDE configuration

**Problem:** IDE still points to old clone locations.

**Solution:** Update IDE project configuration to new worktree paths.

---

## Success Metrics

Track these metrics to measure migration success:

1. **Disk space saved:** Compare before/after
2. **Context switch time:** Time to switch between features
3. **Stash usage:** Number of stashes (should decrease)
4. **Parallel work:** Can you work on multiple features simultaneously?
5. **Cognitive load:** Less mental overhead managing work?

**Goal:** All metrics should improve post-migration.
