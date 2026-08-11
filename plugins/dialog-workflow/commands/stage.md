---
effort: medium
maxTurns: 10
disallowedTools:
  - Agent
---

Stage current changes as a pull request without merging. Use for features you want to keep iterating on.

1. Run `git status` and `git diff --stat` to show what has changed
2. Ask the user what to stage (specific files or all changes). Never stage .env files.
3. Stage the approved files
4. Draft a concise commit message summarizing the changes — show to user for approval
5. Commit the changes (include Co-Authored-By trailer)
6. Push to remote: `git push -u origin <current-branch>`
7. Create PR via `gh pr create` with:
   - Short title (under 70 chars)
   - Body with ## Summary (bullet points) and ## Test plan
8. Return the PR URL
9. Start a CI watch loop that only monitors — does NOT merge: `/loop 2m /ci-check`

**Important**: Do NOT start `/ci-merge` — this PR should stay open for continued iteration.

If called with an argument (e.g., `/stage fix auth bug`), use that as the PR title hint.
If not on a feature branch, ask the user to confirm before creating one.
