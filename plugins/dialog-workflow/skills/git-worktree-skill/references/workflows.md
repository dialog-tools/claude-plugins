# Git Worktree Workflow Templates

Complete workflow templates for common git worktree scenarios.

## Template: Feature Development

```bash
# 1. Create worktree for feature
git worktree add ../project-worktrees/new-feature -b username/new-feature

# 2. Navigate and setup
cd ../project-worktrees/new-feature
npm install
cp ../../project/.env.sample .env

# 3. Start Claude
claude --permission-mode plan

# 4. When done, merge and cleanup
git push origin username/new-feature
# Create PR, merge, then:
cd ../../project
git worktree remove ../project-worktrees/new-feature
git branch -d username/new-feature
```

## Template: Urgent Bug Fix

```bash
# 1. Quick worktree from main
git worktree add ../project-worktrees/hotfix -b hotfix/critical-bug main

# 2. Minimal setup
cd ../project-worktrees/hotfix
npm install

# 3. Fix with Claude
claude
# > "Fix the authentication timeout in src/auth.js"

# 4. Test, commit, and cleanup quickly
npm test
git commit -am "fix: resolve auth timeout"
git push origin hotfix/critical-bug
```

## Template: Parallel Development

```bash
# 1. Create multiple worktrees
git worktree add ../worktrees/frontend -b user/frontend-redesign
git worktree add ../worktrees/backend -b user/api-optimization
git worktree add ../worktrees/docs -b user/documentation

# 2. Setup each (in parallel terminals)
cd ../worktrees/frontend && npm install
cd ../worktrees/backend && npm install
cd ../worktrees/docs && npm install

# 3. Start Claude in each terminal
# Terminal 1: claude (in frontend)
# Terminal 2: claude (in backend)
# Terminal 3: claude (in docs)
```

## Template: Team Collaboration

```bash
# Team member A works on feature
git worktree add ../worktrees/team-feature -b team/new-feature

# Team member B reviews in separate worktree
git worktree add ../worktrees/review -b team/new-feature
cd ../worktrees/review
# Make review comments and suggestions

# Both can work simultaneously without interference
```

## Template: Experimentation

```bash
# Create experimental worktrees for testing approaches
git worktree add ../experiments/approach-a -b experiment/approach-a
git worktree add ../experiments/approach-b -b experiment/approach-b

# Test different solutions in isolation
# Keep winner, discard loser:
git worktree remove ../experiments/approach-b
git branch -D experiment/approach-b
```
