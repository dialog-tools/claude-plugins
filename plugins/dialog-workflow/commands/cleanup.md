---
effort: low
maxTurns: 5
disallowedTools:
  - Edit
  - Write
  - Agent
---

After a PR has been merged and the remote branch deleted, clean up local git state:

1. Note the current branch name (this is the branch being cleaned up)
2. Confirm with the user before switching branches
3. Switch to main: `git checkout main`
4. Pull latest: `git pull origin main`
5. Prune stale remote-tracking refs: `git fetch --prune`
6. Delete the local feature branch: `git branch -d <branch-name>`
7. If `-d` fails (unmerged changes), warn the user — do NOT force delete without explicit confirmation
8. Show `git branch` to confirm clean state
9. Report: "Cleaned up. On main, up to date."

If an argument is provided (e.g., `/cleanup feat/my-branch`), delete that specific branch instead of the previously active one.
