---
allowed-tools: Bash(git:*), Bash(gh pr view:*)
description: Summarize the current state of the git repository (status, diff vs main, branch, open PR)
---

Summarize the current state of the repository from the output below. Keep it short:
branch, what's uncommitted, what's ahead of `main`, and whether a PR is open.

- Current branch: !`git branch --show-current`
- Status: !`git status --short --branch`
- Diff vs origin/main (stat): !`git diff --stat origin/main...HEAD`
- Recent commits: !`git log --oneline -5`
- Open PR for this branch: !`gh pr view --json number,url,state,statusCheckRollup 2>/dev/null || echo "no PR"`
