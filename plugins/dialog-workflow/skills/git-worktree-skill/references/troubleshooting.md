# Git Worktree Troubleshooting Guide

Common issues and their solutions when working with git worktrees.

## Issue: "Branch is already checked out"

**Cause:** Trying to check out same branch in multiple worktrees

**Solution:** Create a new branch or use existing different branch
```bash
git worktree add ../path -b new-unique-branch
```

**Why it happens:** Git prevents the same branch from being checked out in multiple locations to avoid conflicts.

---

## Issue: Dev server won't start (port in use)

**Cause:** Multiple worktrees trying to use same port

**Solution:** Use unique ports per worktree
```bash
PORT=3001 npm run dev
# Or in .env file:
# PORT=3001
```

**Prevention:** Set up port management in environment setup checklist.

---

## Issue: Missing dependencies

**Cause:** Forgot to run install in new worktree

**Solution:** Always run package manager install
```bash
npm install  # or yarn, pnpm, etc.
```

**Best practice:** Add installation to worktree creation script (use `wt create` helper).

---

## Issue: Database connection errors

**Cause:** Multiple worktrees connecting to same DB with conflicting migrations

**Solution:** Use separate databases or coordinate migrations
```bash
# Use environment-specific DB
DATABASE_URL=postgres://localhost/myapp_worktree_1 npm run dev

# Or use different .env files:
cp .env.sample .env.worktree1
# Edit .env.worktree1 with unique DB
```

**Advanced:** Use Docker containers for isolated databases per worktree.

---

## Issue: Worktree references stale after moving directories

**Cause:** Worktree directory was moved or deleted manually

**Solution:** Clean up with prune
```bash
git worktree prune

# If worktree still shows in list but doesn't exist:
git worktree remove --force <path>
```

**Prevention:** Always use `git worktree remove` instead of manual deletion.

---

## Issue: .gitignore changes not recognized

**Cause:** Shared .git/info/exclude file or worktree-specific ignore issues

**Solution:** Use repository-level .gitignore
```bash
# Ensure .gitignore is committed to repository
git add .gitignore
git commit -m "chore: update gitignore"

# All worktrees will see the changes
```

---

## Issue: Hooks not running in worktrees

**Cause:** Git hooks are stored in .git/hooks which is shared

**Solution:** Hooks work the same across all worktrees
```bash
# Verify hook is executable
chmod +x .git/hooks/pre-commit

# Test in worktree
git commit -m "test"
```

**Note:** All worktrees share the same hooks directory.

---

## Issue: Performance degradation with many worktrees

**Cause:** Too many active worktrees consuming resources

**Solution:** Remove unused worktrees regularly
```bash
# List all worktrees
git worktree list

# Remove unused ones
git worktree remove <path>

# Set a limit (e.g., max 5 active worktrees)
```

**Best practice:** Use `wt list` regularly to audit active worktrees.

---

## Issue: IDE doesn't recognize worktree as project

**Cause:** IDE configuration pointing to wrong directory

**Solution:** Open worktree directory directly in IDE
```bash
# VS Code
code ../worktrees/feature-name

# IntelliJ/WebStorm
idea ../worktrees/feature-name
```

**Configuration:** Each worktree can have its own IDE settings directory.

---

## Getting Help

If issues persist:

1. **Check Git version:** `git --version` (recommend 2.25+)
2. **Verify worktree integrity:** `git worktree list --porcelain`
3. **Review Git logs:** Check for error messages
4. **Consult documentation:** `git worktree --help`
5. **Ask for assistance:** Include output from `git worktree list` and error messages
