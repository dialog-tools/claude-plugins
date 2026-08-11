---
name: Git Worktree Manager
description: Manage git worktrees for parallel development workflows - create, list, switch between, and remove worktrees with proper project setup
version: 2.1.0
---

# Git Worktree Manager

Manage git worktrees to enable parallel development workflows without branch switching.

## When to Use

Invoke this skill when users:
- **Want to run multiple Claude Code sessions in parallel** (PRIMARY use case)
- Mention "worktree", "parallel development", or "multiple branches"
- Need to work on multiple features simultaneously **without losing Claude's context**
- Want isolation without constant branch switching
- Experience context-switching pain with stashing/checkout cycles
- **Need to switch between tasks while preserving AI assistant's understanding**

## Requirements

- Git version 2.5 or higher (worktrees introduced in Git 2.5)
- Terminal multiplexer (tmux) or multiple terminal tabs recommended
- For macOS users: iTerm2 with notifications for optimal Claude Code workflow

## Why Worktrees with Claude Code?

**The Context Switching Problem:**

Every time you switch branches:
1. `git stash` your work
2. `git checkout` different branch
3. Claude loses all accumulated context
4. Restart Claude and re-explain architecture
5. Wait for Claude to rebuild understanding

**The Worktree Solution:**

Create multiple worktrees:
1. Each worktree has its own directory
2. Each runs its own Claude Code session
3. Claude maintains full context per worktree
4. Switch between terminals, not branches
5. Zero context rebuilding overhead

**Result:** 3-5x faster task switching with preserved AI context.

**Official Anthropic Workflow:**

From Claude Code best practices (Section 6c):

```bash
# Create 3-4 worktrees in separate folders
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
git worktree add ../project-hotfix hotfix

# Open separate terminal tabs
# Tab 1: cd ../project-feature-a && claude
# Tab 2: cd ../project-feature-b && claude
# Tab 3: cd ../project-hotfix && claude

# Cycle through tabs to check progress
# Each Claude maintains independent context
```

**Benefits:**
- **Zero context loss** - Each Claude maintains full understanding
- **Parallel progress** - Multiple tasks advance simultaneously
- **No stash management** - Work stays exactly where you left it
- **Clean separation** - Impossible to commit to wrong branch

## Core Operations

### Create Worktree

Create a new worktree for isolated development:

```bash
# Basic creation
git worktree add <path> -b <branch-name>

# Recommended pattern
git worktree add ../worktrees/<feature-name> -b <username>/<feature-name>

# From existing branch
git worktree add ../worktrees/<feature-name> existing-branch

# From remote branch
git worktree add ../worktrees/<feature-name> origin/feature-branch
```

**Key Points:**
- Use descriptive branch names (prefix with username)
- Organize worktrees in dedicated directory (`../worktrees/`)
- Cannot check out same branch in multiple worktrees
- Each worktree needs environment setup (see below)

### List Worktrees

View all active worktrees:

```bash
# Standard list
git worktree list

# Detailed output
git worktree list --porcelain
```

### Remove Worktree

Clean up completed or abandoned worktrees:

```bash
# Standard removal (from main repo)
git worktree remove <path>

# Force remove (with uncommitted changes)
git worktree remove --force <path>

# Clean up stale references
git worktree prune
```

### Navigate to Worktree

After creation, navigate to work in the worktree:

```bash
cd <worktree-path>
```

## Environment Setup Checklist

**CRITICAL:** Each worktree requires separate environment setup.

### JavaScript/Node.js Projects

```bash
# 1. Navigate to worktree
cd <worktree-path>

# 2. Install dependencies
npm install  # or: yarn, pnpm, bun

# 3. Copy environment file
cp ../<main-repo>/.env.sample .env

# 4. Configure unique port
echo "PORT=3001" >> .env  # Increment for each worktree

# 5. Start development server
npm run dev
```

### Python Projects

```bash
# 1. Navigate to worktree
cd <worktree-path>

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Copy environment file
cp ../<main-repo>/.env.sample .env
```

### Go Projects

```bash
# 1. Navigate to worktree
cd <worktree-path>

# 2. Download dependencies
go mod download

# 3. Copy environment file (if applicable)
cp ../<main-repo>/.env.sample .env
```

### Ruby Projects

```bash
# 1. Navigate to worktree
cd <worktree-path>

# 2. Install dependencies
bundle install

# 3. Copy environment file
cp ../<main-repo>/.env.sample .env
```

## Best Practices

### Directory Organization

**Recommended structure:**
```
~/projects/
├── myproject/              # Main repository
│   └── .git/
└── myproject-worktrees/    # All worktrees here
    ├── feature-a/
    ├── bugfix-b/
    └── experiment-c/
```

**Benefits:**
- Consistent location
- Easy cleanup
- Clear separation from main repo

### Naming Conventions

**Branch names:**
- Prefix with username: `reza/new-dashboard`
- Use descriptive names: `feature/user-auth`, `bugfix/null-pointer`
- Match worktree directory name to branch

**Worktree paths:**
- Use lowercase with hyphens: `../worktrees/new-dashboard`
- Match branch name for clarity

### Port Management

Assign unique ports to prevent conflicts:

```bash
# Main repo: PORT=3000
# Worktree 1: PORT=3001
# Worktree 2: PORT=3002
# etc.

# Set in .env
echo "PORT=3001" >> .env
```

### Database Considerations

Use separate databases or namespaces per worktree:

```bash
# Option 1: Unique database per worktree
DATABASE_URL=postgres://localhost/myapp_feature_a

# Option 2: Use separate DB container
docker-compose up -d  # Each worktree has own docker-compose.yml
```

### Cleanup Routine

Regularly audit and remove unused worktrees:

```bash
# List all worktrees
git worktree list

# Remove completed feature worktrees
git worktree remove ../worktrees/completed-feature

# Prune stale references
git worktree prune
```

**Recommendation:** Limit to 3-5 active worktrees for optimal performance.

## Quick Reference Commands

```bash
# Create
git worktree add ../worktrees/<name> -b <branch>

# List
git worktree list

# Remove
git worktree remove ../worktrees/<name>

# Prune
git worktree prune

# Navigate
cd ../worktrees/<name>
```

## Using the Helper Script

The skill includes a `worktree-helper.sh` script for common operations:

```bash
# Make available (one-time setup)
chmod +x ~/.claude/skills/git-worktree-skill/scripts/worktree-helper.sh
ln -s ~/.claude/skills/git-worktree-skill/scripts/worktree-helper.sh ~/bin/wt

# Usage
wt create <feature-name>   # Creates worktree with auto-setup
wt list                    # Lists all worktrees
wt switch                  # Interactive worktree switcher
wt remove <feature-name>   # Removes worktree
wt cleanup                 # Remove all non-main worktrees
```

## Safety Considerations

**Before removing worktrees:**
- Verify branch is pushed: `git push origin <branch>`
- Check for uncommitted changes: `git status`
- Ensure work is merged or no longer needed

**Avoid:**
- Manually deleting worktree directories (use `git worktree remove`)
- Checking out same branch in multiple worktrees
- Running multiple dev servers on same port
- Connecting multiple worktrees to same database without isolation

## Project-Specific Configuration

Some projects have custom worktree setup requirements (multiple services, port configurations, env var transformations). Check for a `.claude/worktree-config.json` file in the project root.

### Detecting Project Config

```bash
# Check if project has worktree config
if [ -f ".claude/worktree-config.json" ]; then
    echo "Project has custom worktree configuration"
    # Use project's setup script
    .claude/scripts/setup-worktrees.sh <feature-name>
fi
```

### Config File Schema

```json
{
  "worktreeDir": "../<project>-worktrees",
  "ports": {
    "v1": { "vite": 5173, "agent": 3001, "feed": 3002 },
    "v2": { "vite": 5174, "agent": 3011, "feed": 3012 }
  },
  "envVars": {
    "derive": ["VITE_VAR=${BACKEND_VAR}"]
  },
  "setup": {
    "npm": true,
    "feedService": "npm run setup:feed-service",
    "viteEnvDir": true
  }
}
```

### Using Project Setup Script

When a project has `.claude/scripts/setup-worktrees.sh`:

```bash
# Creates <feature>-v1 and <feature>-v2 worktrees with proper config
.claude/scripts/setup-worktrees.sh <feature-name>

# Example:
.claude/scripts/setup-worktrees.sh pain-point-skill
# Creates: ../frontend-worktrees/pain-point-skill-v1
#          ../frontend-worktrees/pain-point-skill-v2
```

The script handles:
- Git worktree creation with feature branches
- npm install
- .env copying and transformation
- Port configuration (v1 defaults, v2 offset)
- Vite envDir configuration
- Python venv setup for feed services

## Advanced Topics

For detailed information on advanced scenarios, see the `references/` directory:

- **`advanced-operations.md`** - Move, lock, repair worktrees; worktree internals
- **`workflows.md`** - Complete workflow templates for common scenarios
- **`troubleshooting.md`** - Common issues and solutions
- **`integrations.md`** - VS Code, IDEs, CI/CD, Docker integration
- **`performance.md`** - Optimization tips and disk space management
- **`automation.md`** - Bash functions, aliases, and scripts
- **`platform-guide.md`** - Windows, macOS, Linux-specific considerations
- **`migration-guide.md`** - Migrating from multiple clones or stash workflows
- **`examples.md`** - Real-world usage examples

## Resources

- Git documentation: `git worktree --help`
- Helper script: `scripts/worktree-helper.sh`
- Validation script: `scripts/test-worktree-helper.sh`
