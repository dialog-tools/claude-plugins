---
effort: medium
maxTurns: 15
description: Bootstrap the full dialog-workflow toolchain — companion plugins, hook interpreters, gh auth, MCP servers
---

Finish setting up the `dialog-workflow` plugin for this machine. Work through every
step, report what you found and what you changed, and never modify anything outside
Claude Code's own config (`~/.claude/`, `.claude/`) without asking.

## 1. Companion plugins

`dialog-workflow` is designed to run alongside these plugins from Anthropic's
built-in `claude-plugins-official` marketplace:

| Plugin | Why |
| --- | --- |
| `superpowers` | Process skills — brainstorming, planning, TDD, systematic debugging, subagent-driven development. `/ship`, `/stage`, and the planning docs assume it. |
| `code-review` | `/code-review` for PR review before `/ship`. |
| `frontend-design` | Pairs with the `dialog-design-v2` skill for UI work. |
| `typescript-lsp` | Go-to-definition / diagnostics for TypeScript repos. |

Run `claude plugin list --json` and compare against that table. For each missing
plugin, run `claude plugin install <name>@claude-plugins-official`. Do **not**
use `--scope project` unless the user asks — user scope is the default and the
right one for personal tooling. If an install fails, show the error and move on;
don't retry in a loop.

## 2. Hook interpreters

The plugin's safety hooks need `uv` (for `pre_tool_use.py`) and `python3` (for
`block-env.py`). Both hooks silently no-op if their interpreter is missing.

- `command -v uv` — if absent, tell the user to run `brew install uv` (macOS) or
  see https://docs.astral.sh/uv/ . Don't install it yourself.
- `command -v python3` — same; almost always present.

## 3. GitHub CLI

`/ship`, `/stage`, `/ci-check`, `/ci-merge`, `/cleanup` all drive `gh`. Run
`gh auth status`. If not authenticated, tell the user to run `gh auth login`
themselves (it's interactive) — suggest typing `! gh auth login` in this
session.

## 4. MCP servers (optional, per-command)

- `/prod-logs` needs the **Render** MCP server (user-scope OAuth). If
  `claude mcp list` doesn't show it, tell the user to add it via `/mcp` and
  that `/prod-logs` also expects a `.claude/prod-services.local.md` in the
  target repo (YAML frontmatter with `workspace_id` and one key per service).
  Don't create that file — it holds real service IDs and is gitignored.
- If the current project has a `.mcp.json`, note which servers reference
  `${ENV_VAR}` placeholders and check whether each variable is set in the
  environment; unset ones fail silently at launch.

## 5. Report

Finish with a short checklist: each plugin (installed / already present /
failed), each interpreter (found / missing), gh auth (ok / needs login), and
any MCP follow-ups for the user. Remind them that newly installed plugins load
on the next session.
