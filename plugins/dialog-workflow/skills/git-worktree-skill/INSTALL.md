# Installation Guide

## Quick Start

### For Claude.ai Web Interface

1. **Package the skill:**
   ```bash
   cd git-worktree-skill
   zip -r git-worktree-skill.zip Skill.md README.md REFERENCE.md scripts/
   ```

2. **Upload to Claude:**
   - Go to https://claude.ai/settings/capabilities
   - Click "Upload a Skill"
   - Select `git-worktree-skill.zip`
   - Enable the skill in your capabilities

3. **Start using:**
   ```
   Ask Claude: "Create a new worktree for my dashboard feature"
   ```

### For Claude Code CLI (if supported)

1. **Copy to skills directory:**
   ```bash
   mkdir -p ~/.claude/skills/
   cp -r git-worktree-skill ~/.claude/skills/
   ```

2. **Verify installation:**
   ```bash
   # Skill should be automatically available in Claude Code
   claude
   # Ask: "List available skills" or "Help me with git worktrees"
   ```

## Optional: Install Helper Script

The included `worktree-helper.sh` script provides convenient command-line shortcuts:

### Installation

```bash
# Option 1: Add to PATH
sudo cp git-worktree-skill/scripts/worktree-helper.sh /usr/local/bin/wt
sudo chmod +x /usr/local/bin/wt

# Option 2: Create alias in your shell
echo 'alias wt="~/path/to/git-worktree-skill/scripts/worktree-helper.sh"' >> ~/.bashrc
source ~/.bashrc
# or for zsh: ~/.zshrc
```

### Usage

```bash
# Create worktree with automatic setup
wt create my-feature

# List worktrees
wt list

# Start Claude in a worktree
wt claude my-feature

# Remove worktree
wt remove my-feature

# Cleanup stale references
wt cleanup
```

## Verification

### Test Claude can use the skill:

1. Open Claude (web or CLI)
2. Ask: "How do I create a git worktree?"
3. Claude should provide detailed guidance from the skill

### Test the skill is loaded:

Look for Claude mentioning:
- Specific worktree commands
- Environment setup checklists
- Best practices for organization
- References to the skill content

## Troubleshooting

### Skill not loading

**Web interface:**
- Check file upload completed successfully
- Verify skill is enabled in Settings > Capabilities
- Try refreshing the page

**CLI:**
- Check directory location: `~/.claude/skills/git-worktree-skill/`
- Verify Skill.md has proper YAML frontmatter
- Restart Claude Code

### Skill not being invoked

The skill triggers on keywords like:
- "worktree"
- "parallel development"
- "multiple branches"
- "work on multiple features"

Try being more explicit: "Use the git worktree skill to help me..."

### Permission errors with helper script

```bash
# Make sure script is executable
chmod +x /path/to/worktree-helper.sh

# If copying to system location, use sudo
sudo cp worktree-helper.sh /usr/local/bin/wt
```

## Updating the Skill

### Web interface:

1. Make changes to Skill.md
2. Re-package: `zip -r git-worktree-skill.zip .`
3. Upload new version to Claude.ai
4. Increment version number in Skill.md frontmatter

### CLI:

1. Make changes to Skill.md
2. Copy updated files to `~/.claude/skills/git-worktree-skill/`
3. Restart Claude Code

## Uninstallation

### Web interface:

1. Go to https://claude.ai/settings/capabilities
2. Find "Git Worktree Manager" skill
3. Click disable or remove

### CLI:

```bash
rm -rf ~/.claude/skills/git-worktree-skill
```

### Helper script:

```bash
# If installed to PATH
sudo rm /usr/local/bin/wt

# If aliased, remove from shell config
# Edit ~/.bashrc or ~/.zshrc and remove the alias line
```

## Advanced Setup

### Team Sharing

Share this skill with your team:

1. Commit the skill directory to your project:
   ```bash
   git add .claude/skills/git-worktree-skill/
   git commit -m "Add git worktree management skill"
   ```

2. Team members can install from the repo:
   ```bash
   cp -r .claude/skills/git-worktree-skill ~/.claude/skills/
   ```

### Custom Configuration

Modify Skill.md to add:
- Company-specific naming conventions
- Custom environment setup steps
- Project-specific worktree patterns
- Additional automation scripts

## Support

For issues or questions:
- Review README.md for overview
- Check REFERENCE.md for advanced topics
- Consult Skill.md for complete documentation
- Visit: https://support.claude.com/en/articles/12512198-how-to-create-custom-skills
