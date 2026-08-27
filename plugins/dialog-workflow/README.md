# dialog-workflow

Dialog team workflow plugin for Claude Code: the ship/stage PR flow, CI babysitting, prod log
triage, two safety hooks, and three supporting skills.

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
| `/git-status` | One-shot summary of branch, uncommitted changes, diff vs `main`, and open PR |
| `/setup` | Post-install bootstrap: installs companion plugins, checks `uv`/`python3`/`gh`, flags MCP gaps |

## Hooks

Two safety-only `PreToolUse` hooks (guarded so they no-op if `uv`/`python3` aren't on `PATH`,
and also no-op when the same script already exists at `~/.claude/hooks/` — so users who carry
these hooks in their personal dotfiles don't run them twice):

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
- **`dialog-design-v2`** — the app's v2 design system (tokens, components, v1→v2 migration rules).
  Triggers when writing or reviewing UI inside a `data-ds="v2"` scope.

## Install

```
/plugin marketplace add dialog-tools/claude-plugins
/plugin install dialog-workflow@dialog-tools
```

Then, in a fresh session, let the agent finish the job:

```
/dialog-workflow:setup
```

`/setup` installs the companion plugins below, checks that the hook interpreters and
`gh` are present, and tells you what (if anything) is left to do by hand. If you'd rather
drive it by prompt, paste this instead:

> Install and enable the dialog-workflow plugin from the `dialog-tools/claude-plugins`
> marketplace, then run `/dialog-workflow:setup` and follow its checklist.

### Companion plugins

Claude Code plugins can't declare dependencies, so `dialog-workflow` doesn't pull these in
automatically — `/setup` does. All are from Anthropic's built-in `claude-plugins-official`
marketplace:

| Plugin | Used for |
| --- | --- |
| `superpowers` | Process skills: brainstorming, planning, TDD, systematic debugging, subagent-driven development |
| `code-review` | `/code-review` before shipping |
| `frontend-design` | Pairs with the `dialog-design-v2` skill for UI work |
| `typescript-lsp` | TypeScript go-to-definition and diagnostics |

Teams using this plugin in a shared repo can also list them under `enabledPlugins` in the
repo's `.claude/settings.json` so every teammate is prompted to install them on first launch.

### Requirements

- `uv` and `python3` on `PATH` for the safety hooks (they no-op without them)
- `gh` authenticated for the PR-flow commands
- Render MCP server (via `/mcp`) only if you use `/prod-logs`
