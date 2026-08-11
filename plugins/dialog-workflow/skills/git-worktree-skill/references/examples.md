# Git Worktree Real-World Examples

Practical examples demonstrating git worktrees in real development scenarios.

## Example 1: Full-Stack Feature Development

**Scenario:** Building a new dashboard feature that requires changes to both frontend and backend.

### Setup

```bash
cd ~/projects/webapp
git worktree add ../worktrees/dashboard-feature -b reza/dashboard-feature

cd ../worktrees/dashboard-feature
npm install
cp ../../webapp/.env.sample .env
echo "PORT=3001" >> .env
```

### Workflow

```bash
# Start development
npm run dev  # Frontend on port 3001

# In separate terminal: Backend
npm run server  # Backend on port 4001

# Meanwhile, main repo remains on stable branch
cd ~/projects/webapp  # Still on main branch
# Other developers or CI/CD unaffected
```

### Completion

```bash
# After feature is complete
git add .
git commit -m "feat: add user dashboard with analytics"
git push origin reza/dashboard-feature

# Create PR, get review, merge

# Cleanup
cd ~/projects/webapp
git worktree remove ../worktrees/dashboard-feature
git branch -d reza/dashboard-feature
```

**Benefit:** Worked on feature without leaving main branch, avoiding stash/checkout cycles.

---

## Example 2: Urgent Bug Fix During Feature Development

**Scenario:** Working on feature when urgent production bug needs immediate fix.

### Initial State

```bash
# Currently working on feature
cd ~/projects/api
# On branch: feature/oauth-integration
# Uncommitted changes in progress
```

### Traditional Approach (Problematic)

```bash
# ❌ Old way: Stash, switch, fix, switch back
git stash
git checkout main
git checkout -b hotfix/auth-timeout
# ... fix bug ...
git push origin hotfix/auth-timeout
git checkout feature/oauth-integration
git stash pop
# Risk: Stash conflicts, lost context
```

### Worktree Approach (Clean)

```bash
# ✅ Create hotfix worktree
git worktree add ../worktrees/auth-hotfix -b hotfix/auth-timeout main

# Terminal 1: Continue feature work (uninterrupted)
cd ~/projects/api
# Continue working...

# Terminal 2: Fix urgent bug
cd ~/projects/worktrees/auth-hotfix
npm install
cp ../../api/.env .env

# Fix the bug
vim src/auth.js
npm test
git commit -am "fix: resolve authentication timeout"
git push origin hotfix/auth-timeout

# Create PR, get it merged immediately

# Cleanup
cd ~/projects/api
git worktree remove ../worktrees/auth-hotfix
```

**Benefit:** Fixed critical bug without disrupting feature work, no stash management needed.

---

## Example 3: Parallel Development of Multiple Features

**Scenario:** Team wants to develop 3 features simultaneously, comparing approaches.

### Setup Multiple Worktrees

```bash
cd ~/projects/ecommerce

# Feature 1: Payment integration
git worktree add ../worktrees/payment-stripe -b team/payment-stripe
cd ../worktrees/payment-stripe
npm install
echo "PORT=3001" >> .env

# Feature 2: Search optimization
git worktree add ../worktrees/search-elastic -b team/search-elastic
cd ../worktrees/search-elastic
npm install
echo "PORT=3002" >> .env

# Feature 3: Mobile app
git worktree add ../worktrees/mobile-app -b team/mobile-app
cd ../worktrees/mobile-app
npm install
echo "PORT=3003" >> .env
```

### Parallel Development

```bash
# Terminal 1: Payment feature
cd ~/projects/worktrees/payment-stripe
npm run dev  # Port 3001

# Terminal 2: Search feature
cd ~/projects/worktrees/search-elastic
npm run dev  # Port 3002

# Terminal 3: Mobile app
cd ~/projects/worktrees/mobile-app
npm run dev:mobile

# All running simultaneously, no interference!
```

### Testing Integration

```bash
# Test all features together
cd ~/projects/ecommerce
git worktree add ../worktrees/integration-test -b test/integration

cd ../worktrees/integration-test
git merge team/payment-stripe
git merge team/search-elastic
git merge team/mobile-app

npm install
npm test

# If integration issues found, fix in individual worktrees
```

**Benefit:** Parallel development, easy integration testing, no context switching.

---

## Example 4: Code Review in Separate Worktree

**Scenario:** Review teammate's PR while continuing own work.

### Setup

```bash
# Current work: Feature development
cd ~/projects/backend  # On branch: reza/api-refactor

# Teammate requests review of their PR
# Branch: alice/add-graphql

# Create review worktree
git fetch origin
git worktree add ../worktrees/review-alice-graphql alice/add-graphql

# Set up for review
cd ../worktrees/review-alice-graphql
npm install
npm test
```

### Review Process

```bash
# Terminal 1: Continue own work
cd ~/projects/backend  # On reza/api-refactor
# Continue feature development...

# Terminal 2: Review Alice's code
cd ~/projects/worktrees/review-alice-graphql
code .  # Open in VS Code

# Test changes
npm run dev
# Test GraphQL endpoints...

# Leave review comments
# Add suggestions directly to worktree
git commit -am "suggestion: optimize GraphQL resolver"
git push origin alice/add-graphql-suggestions
```

### Cleanup

```bash
cd ~/projects/backend
git worktree remove ../worktrees/review-alice-graphql
```

**Benefit:** Reviewed PR without disrupting own feature work, tested changes in isolation.

---

## Example 5: Experiment with Different Approaches

**Scenario:** Unsure which technical approach is better, want to try both.

### Setup Experimental Worktrees

```bash
cd ~/projects/data-pipeline

# Approach A: Use Redis for caching
git worktree add ../worktrees/experiment-redis -b experiment/redis-cache

# Approach B: Use Memcached
git worktree add ../worktrees/experiment-memcached -b experiment/memcached-cache
```

### Implement Both Approaches

```bash
# Terminal 1: Redis approach
cd ~/projects/worktrees/experiment-redis
npm install redis
# Implement caching with Redis...
npm run benchmark  # Record results

# Terminal 2: Memcached approach
cd ~/projects/worktrees/experiment-memcached
npm install memcached
# Implement caching with Memcached...
npm run benchmark  # Record results
```

### Compare and Choose

```bash
# Redis results: 1000 req/s
# Memcached results: 1200 req/s

# Choose Memcached, discard Redis approach
cd ~/projects/data-pipeline
git worktree remove ../worktrees/experiment-redis
git branch -D experiment/redis-cache

# Promote Memcached approach
cd ../worktrees/experiment-memcached
git push origin experiment/memcached-cache
# Create PR from this branch
```

**Benefit:** Tried both approaches in parallel, easy comparison, clean cleanup of rejected approach.

---

## Example 6: Documentation While Developing

**Scenario:** Update documentation while feature is in development.

### Setup

```bash
cd ~/projects/sdk

# Feature development worktree
git worktree add ../worktrees/websocket-support -b feature/websocket-support

# Documentation worktree
git worktree add ../worktrees/docs-websocket -b docs/websocket-guide
```

### Parallel Work

```bash
# Terminal 1: Implement feature
cd ~/projects/worktrees/websocket-support
# Implement WebSocket functionality...

# Terminal 2: Write documentation
cd ~/projects/worktrees/docs-websocket
# Document WebSocket API as it's being developed...
vim docs/websocket-api.md

# Benefits:
# - Docs written in real-time as API is designed
# - Can test code examples immediately
# - Separate PR for docs (different reviewers)
```

### Merge Strategy

```bash
# Merge feature first
cd ~/projects/sdk
# PR for feature/websocket-support gets merged

# Update docs branch
cd ../worktrees/docs-websocket
git rebase main
# PR for docs/websocket-guide merges after feature
```

**Benefit:** Documentation written in parallel with development, tested against real implementation.

---

## Example 7: CI/CD Build in Temporary Worktree

**Scenario:** CI needs to build specific commit without affecting main repo.

### CI Script

```bash
#!/bin/bash
# ci-build.sh

COMMIT_SHA=$1
BUILD_DIR="/tmp/ci-build-$$"

# Create temporary build worktree
git worktree add --detach "$BUILD_DIR" "$COMMIT_SHA"

# Cleanup on exit (even if script fails)
trap "git worktree remove --force '$BUILD_DIR'" EXIT

cd "$BUILD_DIR"

# Build and test
npm install
npm run build
npm test

# Copy artifacts to output directory
cp -r dist/ /output/
```

### Usage in GitHub Actions

```yaml
name: Build PR
on: [pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for worktrees

      - name: Build in worktree
        run: ./ci-build.sh ${{ github.event.pull_request.head.sha }}
```

**Benefit:** Isolated builds without disrupting repository state, automatic cleanup.

---

## Example 8: Monorepo with Micro-Frontend Architecture

**Scenario:** Monorepo with multiple frontend apps, develop all simultaneously.

### Repository Structure

```
~/projects/monorepo/
├── packages/
│   ├── app-dashboard/
│   ├── app-checkout/
│   ├── app-admin/
│   └── shared-components/
```

### Worktree Setup

```bash
cd ~/projects/monorepo

# Worktree per micro-frontend
git worktree add ../worktrees/dashboard -b feature/dashboard-redesign
git worktree add ../worktrees/checkout -b feature/checkout-flow
git worktree add ../worktrees/admin -b feature/admin-panel
```

### Development

```bash
# Terminal 1: Dashboard app
cd ~/projects/worktrees/dashboard/packages/app-dashboard
npm install
npm run dev  # Port 3000

# Terminal 2: Checkout app
cd ~/projects/worktrees/checkout/packages/app-checkout
npm install
npm run dev  # Port 3001

# Terminal 3: Admin app
cd ~/projects/worktrees/admin/packages/app-admin
npm install
npm run dev  # Port 3002

# All micro-frontends running simultaneously
# Test integration in browser
```

### Shared Component Updates

```bash
# Update shared component affects all
cd ~/projects/monorepo/packages/shared-components
# Edit Button.tsx

# See changes propagate to all worktrees
# Each worktree can test the change independently
```

**Benefit:** Develop multiple micro-frontends simultaneously, test integration easily.

---

## Example 9: Database Migration Testing

**Scenario:** Test database migration before applying to production.

### Setup

```bash
cd ~/projects/api

# Create migration test worktree
git worktree add ../worktrees/migration-test -b test/migration-v2.5

cd ../worktrees/migration-test
npm install

# Use separate test database
echo "DATABASE_URL=postgres://localhost/myapp_migration_test" > .env
```

### Test Migration

```bash
# Apply migration
npm run migrate

# Run tests
npm test

# Verify data integrity
npm run db:verify

# If migration fails, fix in worktree
# If migration succeeds, merge to main
```

**Benefit:** Test risky migrations in isolation without affecting development databases.

---

## Example 10: Long-Running Refactoring

**Scenario:** Major refactoring that takes weeks, ongoing while new features developed.

### Setup

```bash
cd ~/projects/legacy-app

# Refactoring worktree
git worktree add ../worktrees/refactor-architecture -b refactor/modular-architecture

# Continue feature development in main repo
# Main repo stays on main branch for new features
```

### Workflow

```bash
# Continuous refactoring over weeks
cd ~/projects/worktrees/refactor-architecture
# Incrementally refactor modules...

# Meanwhile, new features developed in main repo
cd ~/projects/legacy-app
git checkout -b feature/new-payment
# New features work on main branch

# Periodically merge main into refactor branch
cd ../worktrees/refactor-architecture
git merge main
# Resolve conflicts, continue refactoring
```

### Completion

```bash
# After weeks of refactoring
cd ~/projects/worktrees/refactor-architecture
git push origin refactor/modular-architecture

# Large PR reviewed in chunks
# After merge, cleanup
cd ~/projects/legacy-app
git worktree remove ../worktrees/refactor-architecture
```

**Benefit:** Long-running refactoring doesn't block new feature development.

---

## Summary of Example Benefits

| Example | Main Benefit |
|---------|-------------|
| Full-Stack Feature | No context switching |
| Urgent Bug Fix | Interrupt without disruption |
| Parallel Features | Simultaneous development |
| Code Review | Review without context loss |
| Experiments | Compare approaches easily |
| Documentation | Parallel doc writing |
| CI/CD | Isolated builds |
| Monorepo | Multi-app development |
| Migration Testing | Safe testing |
| Long Refactoring | Ongoing work + new features |

**Key Takeaway:** Worktrees enable parallel, isolated work streams without the overhead of multiple repository clones.
