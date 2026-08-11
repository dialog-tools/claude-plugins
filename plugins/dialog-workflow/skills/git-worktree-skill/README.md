# Git Worktree Manager Skill

A comprehensive Claude Skill for managing git worktrees and enabling parallel AI-assisted development workflows.

## What This Skill Does

This skill teaches Claude how to:
- Create and manage git worktrees efficiently
- Set up proper development environments in each worktree
- Handle common worktree issues and conflicts
- Enable parallel Claude Code sessions for concurrent development
- Provide best practices for worktree organization

## Installation

### Option 1: Manual Installation (Claude.ai web interface)

1. Create a ZIP file of this directory:
   ```bash
   cd git-worktree-skill
   zip -r ../git-worktree-skill.zip .
   ```

2. Go to https://claude.ai/settings/capabilities
3. Click "Upload a Skill"
4. Upload the `git-worktree-skill.zip` file
5. Enable the skill in your capabilities

### Option 2: CLI Installation (if using Claude Code)

If Claude Code supports local skills:
1. Copy this directory to `~/.claude/skills/git-worktree-skill/`
2. The skill should be automatically available

## How to Use

Once installed, Claude will automatically invoke this skill when you:
- Ask about git worktrees
- Want to work on multiple branches simultaneously
- Need help with parallel development workflows
- Mention context-switching issues with branches

### Example Prompts

```
"Create a new worktree for the dashboard feature"
"I want to work on multiple features at once, how do I set that up?"
"List all my current worktrees"
"Help me set up parallel Claude sessions"
"How do I manage multiple branches without constant switching?"
```

## What's Included

- **Skill.md**: Complete skill definition with:
  - Worktree creation and management commands
  - Environment setup checklists for different project types
  - Best practices and naming conventions
  - Claude Code integration workflows
  - Common issues and solutions
  - Quick reference templates

## Benefits

- **Eliminate context switching** - Work on multiple features simultaneously
- **Parallel AI development** - Run multiple Claude instances on different tasks
- **Clean organization** - Systematic approach to managing multiple branches
- **Comprehensive guidance** - Covers setup, usage, troubleshooting, and cleanup

## Requirements

- Git 2.5+ (for worktree support)
- Basic understanding of git branches
- Claude.ai account or Claude Code CLI

## Skill Metadata

- **Name**: Git Worktree Manager
- **Version**: 1.0.0
- **Description**: Manage git worktrees for parallel development workflows
- **Dependencies**: None (uses standard git commands)

## Contributing

To improve this skill:
1. Edit `Skill.md` with enhanced instructions or examples
2. Test with various workflows
3. Update version number in frontmatter
4. Re-package and upload

## License

This skill is provided as-is for use with Claude. Feel free to modify and adapt for your needs.

## Support

For issues or questions:
- Check the official Git documentation: https://git-scm.com/docs/git-worktree
- Review Claude Code worktree docs: https://code.claude.com/docs/en/common-workflows
- Refer to the comprehensive guidance in Skill.md
