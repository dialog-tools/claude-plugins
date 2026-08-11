# Git Worktree Tool Integrations

How to integrate git worktrees with various development tools and workflows.

## Claude Code Integration

### Starting Claude in a Worktree

```bash
# Navigate to worktree
cd ~/projects/myproject-worktrees/feature-a

# Start Claude (use plan mode for exploration)
claude --permission-mode plan

# Or start with a specific prompt
claude -p "Implement the new dashboard feature"
```

### Parallel Claude Sessions

**Workflow for multiple AI agents:**

1. **Create worktrees for each task:**
```bash
git worktree add ../myproject-worktrees/feature-a -b reza/feature-a
git worktree add ../myproject-worktrees/bugfix-b -b reza/bugfix-b
```

2. **Set up each environment** (install dependencies, copy .env files)

3. **Open separate terminals** for each worktree

4. **Start Claude in each terminal:**
```bash
# Terminal 1
cd ~/projects/myproject-worktrees/feature-a
claude

# Terminal 2
cd ~/projects/myproject-worktrees/bugfix-b
claude
```

**Benefits of this approach:**

Each Claude instance has:
- Complete isolation
- Own branch and working directory
- Independent conversation context
- No interference with other sessions

**Use cases:**
- Work on feature while Claude handles refactoring in separate worktree
- Review PR in one worktree while developing in another
- Test different implementation approaches simultaneously

---

## VS Code Integration

### Opening Worktrees

```bash
# Open specific worktree in new window
code ~/projects/myproject-worktrees/feature-a

# Or from within VS Code:
# File > Open Folder > Select worktree directory
```

### Multi-Root Workspaces

Create a workspace file to manage multiple worktrees:

```json
// myproject.code-workspace
{
  "folders": [
    {
      "path": "~/projects/myproject"
    },
    {
      "path": "~/projects/myproject-worktrees/feature-a"
    },
    {
      "path": "~/projects/myproject-worktrees/bugfix-b"
    }
  ],
  "settings": {
    "git.detectSubmodules": false
  }
}
```

**Benefits:**
- View all worktrees in single workspace
- Switch between worktrees in sidebar
- Shared settings across worktrees

### VS Code Settings Per Worktree

Each worktree can have its own `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "./venv/bin/python",
  "terminal.integrated.env.osx": {
    "PORT": "3001"
  }
}
```

**Note:** `.vscode` directory is worktree-specific, not shared.

---

## JetBrains IDEs (IntelliJ, WebStorm, PyCharm)

### Opening Worktrees

```bash
# Open worktree in IDE
idea ~/projects/myproject-worktrees/feature-a

# Or use "Open" from IDE welcome screen
```

### Project Settings

Each worktree maintains independent `.idea/` directory:
- Run configurations
- Code style settings
- Inspection profiles

**Tip:** Copy `.idea/` from main project to worktree for consistent settings.

### Version Control Integration

JetBrains IDEs automatically detect worktrees:
- Branch indicator shows worktree branch
- Commit dialog works normally
- Git log shows worktree-specific history

---

## Git GUI Tools

### GitKraken

- **Automatic detection:** GitKraken detects and displays worktrees
- **Visual representation:** Shows worktree relationships in commit graph
- **Switching:** Can switch between worktrees from UI

**Setup:**
1. Open main repository in GitKraken
2. Worktrees appear in left sidebar under "Worktrees"
3. Click worktree to view its state

### SourceTree

- **Worktree support:** Available in recent versions
- **View worktrees:** Repository > Show Worktrees
- **Create worktrees:** Can create via UI

### Fork

- **Native support:** Fork has built-in worktree support
- **Visual management:** Manage worktrees from sidebar
- **Quick switching:** Right-click branch to open in new worktree

---

## Terminal Tools

### tmux

**Worktree session management:**

```bash
# Create tmux session per worktree
tmux new-session -s feature-a -c ~/projects/myproject-worktrees/feature-a
tmux new-session -s bugfix-b -c ~/projects/myproject-worktrees/bugfix-b

# Switch between sessions
tmux attach -t feature-a
tmux attach -t bugfix-b

# List all sessions
tmux ls
```

**Benefit:** Persistent terminal sessions per worktree.

### zsh / oh-my-zsh

**Custom prompt showing worktree:**

```zsh
# Add to .zshrc
git_worktree_info() {
  local worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  local gitdir=$(git rev-parse --git-common-dir 2>/dev/null)

  if [[ "$worktree" != "$gitdir/.." ]]; then
    echo "[WT: $(basename $worktree)]"
  fi
}

PROMPT='$(git_worktree_info) %~ $ '
```

---

## CI/CD Integration

### GitHub Actions

Worktrees work seamlessly with GitHub Actions:

```yaml
name: Test Feature Branch
on:
  push:
    branches: ['user/*']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      # Tests run normally - no worktree-specific config needed
      - run: npm test
```

**Note:** CI/CD systems clone single branches, so worktree structure doesn't affect them.

### Jenkins

Similar to GitHub Actions - no special configuration needed.

---

## Docker Integration

### Mounting Worktrees

```yaml
# docker-compose.yml per worktree
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
    ports:
      - "3001:3000"  # Unique port per worktree
    environment:
      - DATABASE_URL=postgres://localhost/myapp_feature_a
```

**Best practice:** Each worktree has its own `docker-compose.yml` with unique ports and databases.

---

## Database Management Tools

### Multiple Database Instances

**PostgreSQL:**
```bash
# Create database per worktree
createdb myapp_feature_a
createdb myapp_bugfix_b

# In worktree .env file:
DATABASE_URL=postgres://localhost/myapp_feature_a
```

**MySQL:**
```bash
mysql -e "CREATE DATABASE myapp_feature_a;"
```

**SQLite:**
```bash
# Each worktree gets own SQLite file
# In .env:
DATABASE_URL=sqlite:///./dev_feature_a.db
```

---

## Package Managers

### npm / yarn / pnpm

Each worktree has independent `node_modules/`:

```bash
# Worktree 1
cd ~/projects/myproject-worktrees/feature-a
npm install

# Worktree 2
cd ~/projects/myproject-worktrees/bugfix-b
npm install
```

**Note:** Dependencies are isolated - perfect for testing dependency upgrades.

### Python venv

```bash
# Create virtual environment per worktree
cd ~/projects/myproject-worktrees/feature-a
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Best Practices Summary

1. **IDE:** Open each worktree in separate window/instance
2. **Terminal:** Use tmux or terminal tabs per worktree
3. **Ports:** Configure unique ports for each worktree's dev server
4. **Databases:** Use separate databases or namespaces per worktree
5. **Environment:** Maintain separate `.env` files per worktree
6. **Git GUIs:** Use tools with native worktree support (GitKraken, Fork)
7. **CI/CD:** No special configuration needed - works normally
