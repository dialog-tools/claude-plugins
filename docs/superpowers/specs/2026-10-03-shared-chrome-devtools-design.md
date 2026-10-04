# Shared Chrome DevTools for agents — design

Date: 2026-10-03
Status: draft, awaiting review
Plugin: `dialog-workflow` 0.3.0 → 0.4.0

## Problem

Every Claude Code and Codex session starts its own `chrome-devtools-mcp` server, and by default
each one launches Chrome on the same profile (`~/.cache/chrome-devtools-mcp/chrome-profile`).
Only one Chrome can own a profile, so a second concurrent session fails, and servers orphaned by
exited sessions accumulate (128 orphaned processes / ~11 GB on 2026-09-08, ending in a macOS
out-of-memory dialog).

A working fix exists on one Mac only: a launchd-managed shared Chrome on port 9222, a zsh
launcher, a launchd reaper and hand-copied skills. Nothing about it reaches teammates or other
machines, and `dialog-app/.mcp.json` still hands teammates the old self-launching server.

## Goal

Every Dialog teammate's Mac, in Claude Code and Codex, in Dialog repos and personal repos, runs
the same Chrome DevTools setup, delivered by one package and updated in one place:

- one shared Chrome per machine; many agents use it concurrently
- the newest `chrome-devtools-mcp` release, without npx cache races
- orphaned servers are cleaned up
- the upstream Chrome DevTools skills, plus our shared-browser guidance

## Non-goals

- Linux, Windows, GitHub Actions (`claude-code-action`), Claude Code on the web, Codex cloud.
  The launcher exits with a clear message on non-macOS.
- Hiding agents' tabs from each other. `list_pages` shows every tab; isolation is by `pageId`
  routing (default on) and per-agent `isolatedContext`.
- Changing teammates' personal permission settings automatically.

## Design

### 1. Delivery: `dialog-workflow` plugin

Everything ships in `plugins/dialog-workflow/` of `dialog-tools/claude-plugins` (public repo,
already distributed to Claude via `dialog-app/.claude/settings.json` and to Codex via its
`dialog-tools` marketplace).

New files:

| Path (under `plugins/dialog-workflow/`) | Purpose |
|---|---|
| `bin/chrome-devtools-mcp-shared` | Launcher (zsh). The only entry point for both clients. |
| `.mcp.json` | Claude Code MCP definition |
| `.codex-plugin/plugin.json` | Codex manifest: skills, hooks, and `mcpServers: "./codex-mcp.json"` |
| `codex-mcp.json` | Codex MCP definition |
| `skills/{a11y-debugging,chrome-devtools,chrome-devtools-cli,cookie-debugging,debug-optimize-lcp,memory-leak-debugging,troubleshooting}/` | Upstream skills + overlay |

Repo-level: `scripts/sync-chrome-devtools-skills.mjs`, `tests/chrome-devtools-shared.test.mjs`.

**Claude** (`.mcp.json`):

```json
{ "mcpServers": { "chrome-devtools": { "command": "${CLAUDE_PLUGIN_ROOT}/bin/chrome-devtools-mcp-shared" } } }
```

**Codex** (`codex-mcp.json`): Codex does not interpolate `${CLAUDE_PLUGIN_ROOT}` in plugin MCP
configs (openai/codex#19582, open) and resolves relative paths from the session's working
directory (openai/codex#22842, open). The reported workaround is `"cwd": "."`, which anchors to
the plugin root:

```json
{ "mcpServers": { "chrome-devtools": { "command": "./bin/chrome-devtools-mcp-shared", "cwd": "." } } }
```

A separate file is used because a `.mcp.json` shaped for Codex would break Claude, and vice
versa. Adding `.codex-plugin/plugin.json` must not drop the skills, commands or hooks Codex loads
today from the Claude manifest; it declares them explicitly.

The launcher takes no required arguments; it owns the port and passes `--browserUrl` itself, so
the address lives in one place.

### 2. Launcher: `bin/chrome-devtools-mcp-shared`

zsh, macOS only, no dependencies beyond `node`/`npm` (already required by `npx`). It ends in
`exec`, so each session costs exactly one server process. Steps on every start:

1. **Guard.** Non-macOS → message on stderr, exit 1.
2. **Reap orphans.** Kill (SIGKILL; these ignore SIGTERM) every process tree rooted at a
   `chrome-devtools-mcp` server (node/npm, never a Chrome binary) whose parent is launchd
   (ppid 1). Also kill a Chrome on the legacy default profile
   (`--allow-pre-commit-input` + `~/.cache/chrome-devtools-mcp/chrome-profile`) whose parent is
   launchd, i.e. left behind by a dead self-launching server. Never matched: the shared Chrome or
   any hand-started Chrome, even when its profile lives under `~/.cache/chrome-devtools-mcp/`.
   Runs at most once per minute across sessions (stamp file), so concurrent starts don't each
   walk the process table.
3. **Stay current.** At most once a day, `npm view chrome-devtools-mcp@latest version`; install
   a new version into `versions/<v>/` via a temp dir + rename, under a `mkdir` lock (stale after
   10 min); record it in `current` with an atomic rename; keep the newest 3. Offline or failed
   checks fall back to the installed version. A cold start waits up to 2 min for another
   session's install.
4. **Ensure the shared Chrome.** If `http://127.0.0.1:9222/json/version` doesn't answer, take a
   lock and start Chrome through LaunchServices so it is parented to launchd, not to this
   session:
   `open -g -n -a "Google Chrome" --args --remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --user-data-dir=<state>/profile --no-first-run --no-default-browser-check --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding about:blank`.
   Wait up to 20 s for the endpoint. Chrome missing → clear error, exit 1. If 9222 is answered
   by some other Chrome, the server attaches to it (documented, not detected).
5. **Exec** `versions/<current>/node_modules/.bin/chrome-devtools-mcp --browserUrl=http://127.0.0.1:9222 "$@"`.

State lives in a fixed directory shared by both clients, `~/.cache/dialog-chrome-devtools/`
(`versions/`, `current`, `profile/`, `chrome.log`, lock and stamp files), rather than
`CLAUDE_PLUGIN_DATA`, which Codex doesn't set and which would give Claude and Codex separate
installs and separate browsers.

The shared Chrome outlives sessions by design and is restarted by the next session after a quit
or reboot. This replaces both launchd jobs.

`--check` runs steps 1, 3 and 4, prints Chrome path, endpoint status and server version, and
exits instead of exec'ing (used by `/setup`).

For tests, the launcher's pure decisions are reachable without side effects:
`--select-orphans` reads a `ps -axo pid=,ppid=,command=` table on stdin and prints the PIDs it
would kill; the state directory, port and the `npm`/`open`/`curl` binaries are overridable via
environment variables used only by tests.

### 3. Skills

`scripts/sync-chrome-devtools-skills.mjs [version]` (default `latest`): `npm pack` the release,
replace the seven skill directories, then apply the overlay:

- `chrome-devtools/SKILL.md`: replace the **Browser lifecycle** paragraph with the shared-browser
  description and add **Shared browser etiquette** (own `isolatedContext` per agent, only touch
  your own `pageId`s, no browser-wide side effects on others' pages, `close_page` when done).
- `troubleshooting/SKILL.md`: insert **Step 0: Check the shared Chrome** before Step 1 (curl
  9222, `chrome.log`, never "fix" by reverting to a self-launching or `--isolated` server).

The script fails loudly if an anchor is missing, so an upstream rewrite can't silently drop the
overlay. The existing `skill-links` CI check covers the imported skills.

### 4. Rollout

**Plugin repo** (`dialog-tools/claude-plugins`): the files above; version 0.4.0; README
"Chrome DevTools" section (how it works, install for Claude and Codex, permissions, how to
update skills); `/setup` gains a Chrome DevTools step that
- offers to disable `chrome-devtools-mcp@claude-plugins-official` (Claude and Codex) and to remove
  any user-level `chrome-devtools` MCP server, since either would run a second server,
- runs the launcher's self-check (`--check`: Chrome found, 9222 up, server version),
- prints the allow-list entries for the read-only tools plus `new_page`/`close_page`.

**Teammates**: install `dialog-workflow` at user scope in Claude
(`/plugin marketplace add dialog-tools/claude-plugins`, `/plugin install dialog-workflow@dialog-tools`)
and Codex (`codex plugin marketplace add dialog-tools/claude-plugins`,
`codex plugin add dialog-workflow@dialog-tools`), then run `/setup`. User scope covers every repo,
so the other five Dialog repos need no changes.

**`dialog-app`**: remove `chrome-devtools` from `.mcp.json`; in `.claude/settings.json` disable
`chrome-devtools-mcp@claude-plugins-official` and allow
`mcp__plugin_dialog-workflow_chrome-devtools__{list_pages,navigate_page,take_snapshot,take_screenshot,list_console_messages,list_network_requests,new_page,close_page}`.

**Chris's Mac**: after the plugin release is installed, remove the local setup so this machine
runs exactly what teammates run: both launchd agents (`launchctl bootout`, run by Chris), their
plists, `~/.local/bin/{chrome-devtools-mcp-shared,reap-chrome-devtools-mcp}`,
`~/.local/share/chrome-devtools-mcp/`, the copied skills in `~/.claude/skills` and their
`~/.agents/skills` links, the user-level `chrome-devtools` servers in `~/.claude.json` and
`~/.codex/config.toml`, and `disabledMcpjsonServers` in `~/.claude/settings.json`; rename the
allow-list entries to the plugin tool names; enable `dialog-workflow` at user scope in Claude.

## Testing

- **Unit** (`node --test`, added to CI next to `skill-links`): orphan selection over fixture
  `ps` tables (orphaned npx/node trees, a live session's server, the shared Chrome, a hand-started
  Chrome under `~/.cache/chrome-devtools-mcp/`, a legacy orphaned Chrome); version pruning;
  stale-lock recovery; the sync script's overlay and missing-anchor failure.
- **Integration (local)**: with Chrome down, a cold start brings it up parented to launchd; three
  simultaneous cold starts produce one install and three working servers; two servers share the
  browser with separate `isolatedContext`s.
- **Real clients**: `claude -p` and `codex exec` with `dialog-workflow` installed from a local
  marketplace pointing at the branch checkout: each opens, lists and closes a tab, and sees the
  seven skills; then again from a released install.

## Risks

- **Codex `cwd` workaround is unofficial.** If it fails, Codex falls back to a user-level
  `[mcp_servers.chrome-devtools]` pointing at the installed launcher path, written by `/setup`.
- **Plugin updates aren't automatic** for third-party marketplaces; teammates run
  `/plugin marketplace update dialog-tools` (README and `/setup` say so). The server itself stays
  current through the launcher regardless.
- **Shared visibility**: agents can see each other's tabs; mitigated by the skill guidance only.
