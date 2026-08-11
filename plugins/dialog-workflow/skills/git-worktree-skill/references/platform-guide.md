# Git Worktree Platform-Specific Guide

Platform-specific considerations, paths, and optimizations for git worktrees on Windows, macOS, and Linux.

## Windows

### Path Syntax

Windows supports both forward slashes and backslashes:

```powershell
# Backslashes (Windows-style)
git worktree add ..\worktrees\feature-a -b feature-a

# Forward slashes (Unix-style, recommended)
git worktree add ../worktrees/feature-a -b feature-a

# Absolute paths in PowerShell
git worktree add C:\projects\worktrees\feature-a -b feature-a

# Git Bash paths (Unix-style)
git worktree add /c/projects/worktrees/feature-a -b feature-a
```

**Recommendation:** Use forward slashes for cross-platform compatibility.

### Symbolic Links

Windows 10+ supports symbolic links, but may require admin privileges:

```powershell
# Enable symbolic links in Git (one-time setup)
git config --global core.symlinks true

# May require running terminal as Administrator
# Or enable Developer Mode in Windows Settings
```

**Alternative:** Use directory junctions (no admin required):
```powershell
mklink /J C:\projects\worktrees\feature-a C:\actual\location
```

### Line Endings

Configure line endings to avoid issues across worktrees:

```powershell
# Set line ending handling (recommended)
git config --global core.autocrlf true

# Or per repository
git config core.autocrlf true
```

### PowerShell Functions

Add to `$PROFILE` (usually `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`):

```powershell
# Create worktree with auto-setup
function New-GitWorktree {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BranchName
    )

    $worktreePath = "..\worktrees\$BranchName"

    git worktree add $worktreePath -b $BranchName
    Set-Location $worktreePath

    if (Test-Path "package.json") {
        npm install
    }

    if (Test-Path "../.env.sample") {
        Copy-Item "../.env.sample" ".env"
    }
}

# Alias
Set-Alias -Name wt-create -Value New-GitWorktree

# List worktrees
function Get-GitWorktrees {
    git worktree list
}
Set-Alias -Name wt-list -Value Get-GitWorktrees
```

**Usage:**
```powershell
wt-create my-feature
wt-list
```

### Windows Defender Exclusions

Improve performance by excluding git directories from real-time scanning:

```powershell
# Run as Administrator
Add-MpPreference -ExclusionPath "C:\projects\myproject\.git"
Add-MpPreference -ExclusionPath "C:\projects\worktrees"
```

### WSL (Windows Subsystem for Linux)

**Recommendation:** Keep worktrees on same filesystem as main repo.

```bash
# GOOD: Both in WSL filesystem
cd ~/projects/myproject
git worktree add ../worktrees/feature-a -b feature-a

# AVOID: Mixed Windows/WSL filesystems
cd /mnt/c/projects/myproject  # Windows filesystem
git worktree add ~/worktrees/feature-a  # WSL filesystem
# Slow due to cross-filesystem operations
```

**Best practice:** Use WSL for development, Windows for IDE if needed:
```bash
# In WSL: Create worktree
git worktree add ../worktrees/feature-a -b feature-a

# In Windows: Open in VS Code
code \\wsl$\Ubuntu\home\user\projects\worktrees\feature-a
```

---

## macOS

### Path Syntax

macOS uses Unix-style paths:

```bash
# Tilde for home directory
git worktree add ~/projects/worktrees/feature-a -b feature-a

# Relative paths
git worktree add ../worktrees/feature-a -b feature-a

# Absolute paths
git worktree add /Users/username/projects/worktrees/feature-a -b feature-a
```

### Case Sensitivity

**Default:** macOS filesystem (APFS/HFS+) is case-insensitive but case-preserving.

```bash
# These are the same directory on default macOS
../worktrees/Feature-A
../worktrees/feature-a

# Potential issue: Git branches are case-sensitive
git worktree add ../worktrees/feature-a -b feature-a  # OK
git worktree add ../worktrees/Feature-A -b Feature-A  # Conflict!
```

**Recommendation:** Use consistent casing for branch names and paths.

**Optional:** Create case-sensitive volume for worktrees:
```bash
# Create case-sensitive APFS volume
diskutil apfs addVolume disk1 "Case-sensitive APFS" Projects -nomount
mkdir /Volumes/Projects

# Use for worktrees
git worktree add /Volumes/Projects/worktrees/feature-a -b feature-a
```

### Spotlight Indexing

Exclude worktree directories from Spotlight to improve performance:

```bash
# Add to Spotlight exclusions
# System Preferences > Spotlight > Privacy
# Add: ~/projects/worktrees

# Or via command line
sudo mdutil -i off ~/projects/worktrees
```

### Extended Attributes

macOS adds extended attributes (`.DS_Store`, etc.):

```bash
# Add to .gitignore
echo ".DS_Store" >> .gitignore

# Clean from worktrees
find ~/projects/worktrees -name ".DS_Store" -delete
```

### File Descriptor Limits

Increase file descriptor limits for large projects:

```bash
# Add to ~/.zshrc or ~/.bash_profile
ulimit -n 10240

# Or system-wide (requires admin)
sudo launchctl limit maxfiles 65536 200000
```

### Homebrew Integration

Git installed via Homebrew has latest features:

```bash
# Install/update Git
brew install git
brew upgrade git

# Verify version (2.25+ recommended for worktrees)
git --version
```

---

## Linux

### Path Syntax

Linux uses Unix-style paths:

```bash
# Tilde for home directory
git worktree add ~/projects/worktrees/feature-a -b feature-a

# Relative paths
git worktree add ../worktrees/feature-a -b feature-a

# Absolute paths
git worktree add /home/username/projects/worktrees/feature-a -b feature-a
```

### Filesystem Choices

**Recommended:** ext4 or btrfs for best performance.

```bash
# Check filesystem type
df -T ~/projects/worktrees

# ext4: Excellent performance, widely supported
# btrfs: Copy-on-write, snapshots, compression
# xfs: Good for large files
# tmpfs: RAM disk (very fast, not persistent)
```

**tmpfs for temporary worktrees:**
```bash
# Create RAM disk for CI builds
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk

# Use for fast temporary worktrees
git worktree add /mnt/ramdisk/ci-build --detach $COMMIT
```

### Permissions

Ensure proper permissions for worktree directories:

```bash
# Set permissions
chmod 755 ~/projects/worktrees

# If using shared directories
chmod 775 /shared/projects/worktrees
chown :developers /shared/projects/worktrees
```

### inotify Limits

Increase inotify limits for IDEs watching worktrees:

```bash
# Check current limits
cat /proc/sys/fs/inotify/max_user_watches

# Increase limits (add to /etc/sysctl.conf)
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512

# Apply
sudo sysctl -p
```

### SELinux / AppArmor

If using SELinux or AppArmor, ensure policies allow worktree access:

```bash
# SELinux: Check context
ls -Z ~/projects/worktrees

# If needed, set appropriate context
chcon -R -t user_home_t ~/projects/worktrees
```

### systemd Integration

Create systemd service for worktree cleanup:

```bash
# /etc/systemd/user/worktree-cleanup.service
[Unit]
Description=Weekly worktree cleanup

[Service]
Type=oneshot
ExecStart=/home/user/bin/wt-cleanup.sh

# /etc/systemd/user/worktree-cleanup.timer
[Unit]
Description=Run worktree cleanup weekly

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target

# Enable
systemctl --user enable worktree-cleanup.timer
systemctl --user start worktree-cleanup.timer
```

---

## Network Drives

### General Considerations

Worktrees on network drives (SMB/NFS/CIFS) have limitations:

**Performance Issues:**
- Slower file operations
- Increased latency
- Network interruptions can corrupt state

**Recommendations:**
1. **Avoid for active development** - Use local SSD
2. **Lock network worktrees** - Prevent corruption
3. **Use for CI/CD only** - Temporary builds

### SMB/CIFS (Windows Shares)

```bash
# Mount SMB share
sudo mount -t cifs //server/share /mnt/network -o username=user

# Create worktree with lock
git worktree add /mnt/network/worktrees/build -b build
git worktree lock /mnt/network/worktrees/build --reason "Network drive"

# After use
git worktree unlock /mnt/network/worktrees/build
git worktree remove /mnt/network/worktrees/build
```

### NFS

```bash
# Mount NFS share
sudo mount -t nfs server:/export/projects /mnt/nfs

# NFS has better locking support than SMB
git worktree add /mnt/nfs/worktrees/feature -b feature
```

### Repair After Network Issues

```bash
# If network disconnects and worktree becomes corrupted
git worktree repair

# If that fails, prune and recreate
git worktree prune
git worktree add <path> -b <branch>
```

---

## Docker Integration

### Mounting Worktrees in Containers

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    volumes:
      # Mount worktree directory
      - ~/projects/worktrees/feature-a:/app
    ports:
      - "3001:3000"  # Unique port per worktree
```

**Platform-specific volume syntax:**

**Windows:**
```yaml
volumes:
  - C:\projects\worktrees\feature-a:/app
```

**macOS/Linux:**
```yaml
volumes:
  - ~/projects/worktrees/feature-a:/app
```

### Performance Optimization

**macOS:** Use `:cached` or `:delegated` for better performance:
```yaml
volumes:
  - ~/projects/worktrees/feature-a:/app:cached
```

**Linux:** Use `:Z` for SELinux contexts:
```yaml
volumes:
  - ~/projects/worktrees/feature-a:/app:Z
```

---

## IDE-Specific Platform Notes

### VS Code

**Windows:**
```powershell
code C:\projects\worktrees\feature-a
```

**macOS:**
```bash
code ~/projects/worktrees/feature-a
```

**Linux:**
```bash
code ~/projects/worktrees/feature-a
```

**WSL from Windows:**
```bash
code \\wsl$\Ubuntu\home\user\projects\worktrees\feature-a
```

### JetBrains IDEs

**Windows:**
```powershell
idea C:\projects\worktrees\feature-a
```

**macOS:**
```bash
/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea ~/projects/worktrees/feature-a
```

**Linux:**
```bash
idea ~/projects/worktrees/feature-a
```

---

## Summary: Platform Recommendations

| Platform | Filesystem | Location | Performance |
|----------|-----------|----------|-------------|
| **Windows** | NTFS | C:\projects\worktrees | Good |
| **Windows** | NTFS on SSD | Best location | Excellent |
| **Windows** | WSL2 ext4 | ~/projects/worktrees | Excellent |
| **macOS** | APFS | ~/projects/worktrees | Excellent |
| **macOS** | APFS on SSD | Best location | Excellent |
| **Linux** | ext4/btrfs | ~/projects/worktrees | Excellent |
| **Linux** | tmpfs | /mnt/ramdisk (temp) | Fastest |
| **All** | Network drive | Avoid for dev | Poor |

**Key Takeaway:** Use local SSD with native filesystem for best performance.
