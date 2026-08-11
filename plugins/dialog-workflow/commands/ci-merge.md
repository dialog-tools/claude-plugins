---
effort: medium
maxTurns: 10
---

Monitor CI for the current branch's PR, and once all checks pass, merge and clean up.

Steps:
1. Get current branch: `git branch --show-current`
2. Find the associated PR: `gh pr view --json number,url,statusCheckRollup,mergeable`
3. Check CI status from the statusCheckRollup:
   - If any checks are **IN_PROGRESS** or **QUEUED**: report status and stop (the loop will re-run this)
   - If any checks **FAILED**: fetch logs with `gh run view <run-id> --log-failed`, categorize the failure (lint/typecheck/test/build), show error excerpts, and stop the loop with CronDelete
   - If **ALL checks passed**: proceed to step 4
4. Merge the PR: `gh pr merge --squash --delete-branch`
5. Clean up local git state:
   - `git checkout main`
   - `git pull origin main`
   - `git fetch --prune`
   - `git branch -d <feature-branch>`
   - If `-d` fails, warn but do NOT force delete
6. Cancel the CI monitoring loop (CronDelete the active job)
7. Report: PR merged, branch cleaned up, on main and up to date

If argument provided (e.g., `/ci-merge 195`), target that specific PR number.
