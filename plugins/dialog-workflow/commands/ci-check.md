---
effort: medium
maxTurns: 6
disallowedTools:
  - Edit
  - Write
  - Agent
---

Investigate CI failures for the current branch or PR.

Steps:
1. Get current branch: `git branch --show-current`
2. Find the associated PR: `gh pr view --json number,url,statusCheckRollup`
3. If no PR found, check latest workflow runs: `gh run list --branch <branch> --limit 3`
4. Check CI status: `gh pr checks` or `gh run view <run-id>`
5. If failures found, fetch logs: `gh run view <run-id> --log-failed`
6. Categorize each failure:
   - **Lint**: ESLint/Prettier errors → suggest `npm run lint:fix`
   - **Typecheck**: TypeScript errors → show file:line locations
   - **Test**: Jest/Vitest failures → show failing test names and assertion details
   - **Build**: Compilation errors → show build output
   - **Baseline**: Stale baseline data warnings → suggest update command
7. Present: which checks failed, relevant error excerpts, and suggested fix for each
8. If all checks pass, report success with timing info

If argument provided (e.g., `/ci-check 130`), check that specific PR number.

Tip: Use `/loop 2m /ci-check` to continuously monitor CI until it passes.
