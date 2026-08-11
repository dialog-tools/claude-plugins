# dialog-workflow

Dialog team workflow plugin for Claude Code: the ship/stage PR flow, CI babysitting, prod log
triage, two safety hooks, and two supporting skills.

## Commands

| Command | Purpose |
| --- | --- |
| `/ship` | Commit, push, open a PR, and kick off an auto-merging CI watch loop |
| `/stage` | Commit, push, open a PR, and watch CI without auto-merging (keep iterating) |
| `/ci-check` | One-shot investigation of CI failures for the current branch/PR |
| `/ci-merge` | Poll CI for the current branch's PR; merge + clean up once green |
| `/cleanup` | After a PR merges, reset local git state back to a clean `main` |
| `/prod-logs` | Fetch and triage production logs from Render (needs `.claude/prod-services.local.md`) |
| `/prime` | Load codebase context (structure + README) for a new agent session |

## Hooks

Two safety-only `PreToolUse` hooks (guarded so they no-op if `uv`/`python3` aren't on `PATH`):

- **`pre_tool_use.py`** — blocks dangerous `rm -rf`-style commands and blocks writes to `.env`
  files (reading `.env` is still allowed).
- **`block-env.py`** — blocks `git add`/`git commit` operations that would stage an
  un-gitignored `.env` file.

This is intentionally a small v1 slice. The broader personal observability hook set
(`post_tool_use`, `session_start`, `subagent_stop`, `pre_compact`, `user_prompt_submit` logging)
stays in Chris's personal dotfiles and can be promoted into this plugin later if the team wants it.

## Skills

- **`git-worktree-skill`** — create/list/switch/remove git worktrees for parallel development.
- **`composio-cli`** — operate the Composio CLI (tool search, `composio link`, `composio run`,
  `composio proxy`, etc.).

## Install

```
/plugin marketplace add dialog-tools/claude-plugins
/plugin install dialog-workflow@dialog-tools
```
