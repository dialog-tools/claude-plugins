---
effort: high
maxTurns: 8
disallowedTools:
  - Edit
  - Write
---

Fetch and analyze production logs from Render.

**Setup**: Service IDs are configured in `.claude/prod-services.local.md` (YAML frontmatter) in the current project directory.

Steps:
1. Read service config from `.claude/prod-services.local.md` in the current project directory
   - If the file doesn't exist, ask the user for the Render service ID directly
2. **Always select the Render workspace first** by calling `mcp__render__select_workspace` with the `workspace_id` from the config file. This must happen before any other Render MCP calls.
3. If an argument is provided (e.g., `/prod-logs api` or `/prod-logs db`), use that service's ID from the config
4. If no argument, default to the "api" service
5. Fetch recent logs via `mcp__render__list_logs` for the target service ID
6. Analyze the logs:
   - Count and categorize errors (auth, API, database, sprite/VM, timeout)
   - Identify the timestamp range
   - Extract the most critical error excerpts
7. Present a diagnostic summary:
   - Time range covered
   - Error count by category
   - Top 3 most critical errors with full context
   - Suggested investigation steps
8. If the user provided error text alongside the command, cross-reference it with the logs
