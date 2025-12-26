# Git Helper Scripts for Frappe Bench

This directory contains automation scripts to help manage Git operations across multiple apps in Frappe Bench.

## Available Scripts

### 1. check-all-apps.sh

Check Git status of all apps in Frappe bench.

**Purpose:**
- Quickly identify apps with uncommitted changes
- Find apps with diverged branches
- Get overview of Git status across all 22+ apps

**Usage:**
```bash
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh
```

**Example Output:**
```
========================================
Frappe Bench Multi-App Git Status Check
========================================

Checking: frappe
  ✓ Clean and up-to-date

Checking: erpnext
  ✓ Clean and up-to-date

Checking: compliance
  🔀 Branch diverged: ## 360-one...upstream/360-one [ahead 1, behind 2]

Checking: custom_app
  ⚠️  Has uncommitted changes

========================================
SUMMARY
========================================
Apps with uncommitted changes: 1
  - custom_app

Apps with diverged branches: 1
  - compliance
```

**When to Use:**
- Daily before starting work
- Before running `bench update`
- After pulling changes in any app
- When coordinating updates across multiple apps

---

### 2. safe-pull-rebase.sh

Safely pull with rebase after running comprehensive safety checks.

**Purpose:**
- Automate the safe rebase workflow
- Prevent common mistakes (rebasing with uncommitted changes)
- Create automatic backups
- Provide clear next steps

**Usage:**
```bash
cd /home/frappe/frappe-bench/apps/your_app
/home/frappe/frappe-bench/apps/frappe_app/scripts/safe-pull-rebase.sh
```

**Example Output:**
```
Safe Pull with Rebase for: compliance
========================================
Current branch: 360-one
Remote: upstream
Fetching from upstream...
Status: 1 ahead, 2 behind
Branch has diverged. Creating backup...
Created backup: backup-360-one-20241226-143527
Rebasing...
✓ Rebase successful
To push: git push --force-with-lease upstream 360-one
```

**What It Does:**
1. Checks if directory is a Git repository
2. Verifies working tree is clean (no uncommitted changes)
3. Identifies remote (upstream or origin)
4. Fetches latest changes
5. Analyzes divergence status:
   - If up-to-date: Reports and exits
   - If only behind: Fast-forwards
   - If only ahead: Suggests pushing
   - If diverged: Creates backup and rebases
6. Provides next steps (push command if needed)

**Error Handling:**
- ❌ Not a git repository → Exits with error
- ❌ Uncommitted changes → Shows status and exits
- ❌ No remote found → Exits with error
- ❌ Rebase failed → Provides conflict resolution guidance

**When to Use:**
- When you see "X ahead, Y behind" in git status
- Before starting new work on a feature branch
- After finishing a feature, to catch up with main
- When coordinating with team changes

---

### 3. pre-commit-check.sh

Run safety checks before committing code.

**Purpose:**
- Catch common mistakes before they enter Git history
- Prevent committing debugging code
- Warn about large files
- Detect potential secrets

**Usage:**
```bash
cd /home/frappe/frappe-bench/apps/your_app

# Run before committing
./../../frappe_app/scripts/pre-commit-check.sh

# Or add to your workflow:
./../../frappe_app/scripts/pre-commit-check.sh && git commit
```

**Example Output (with issues):**
```
Pre-Commit Safety Check
=======================
⚠️  Found TODO/FIXME comments (review recommended)
❌ Issues found:
  - Debugging statements found
  - Large files: dist/bundle.js (2048KB)

Continue anyway? (y/N)
```

**Example Output (clean):**
```
Pre-Commit Safety Check
=======================
✓ All checks passed
```

**What It Checks:**

1. **Debugging Statements** (Error)
   - `console.log`
   - `debugger`
   - `pdb.set_trace`
   - `import ipdb`
   - `binding.pry`

2. **TODO/FIXME Comments** (Warning only)
   - `TODO`
   - `FIXME`
   - `XXX`

3. **Large Files** (Error)
   - Files larger than 1MB
   - Shows file name and size

4. **Potential Secrets** (Error)
   - `password =`
   - `api_key =`
   - `secret =`
   - `token =`

**Interactive Mode:**
- If issues are found (except TODOs), you'll be prompted to continue or abort
- Type `y` to continue anyway
- Type `n` or press Enter to abort commit

**When to Use:**
- Before every commit (make it a habit)
- Before creating pull requests
- After debugging sessions
- When working with sensitive data

**Limitations:**
- Basic pattern matching (not comprehensive security scan)
- May have false positives
- Won't catch all security issues
- Should be used alongside code review

---

## Installation & Setup

### Making Scripts Accessible

**Option 1: Run from scripts directory (current setup)**
```bash
/home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh
```

**Option 2: Add to PATH**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/home/frappe/frappe-bench/apps/frappe_app/scripts"

# Reload shell
source ~/.bashrc

# Now run from anywhere:
check-all-apps.sh
```

**Option 3: Create aliases**
```bash
# Add to ~/.bashrc or ~/.zshrc
alias check-apps='/home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh'
alias safe-rebase='/home/frappe/frappe-bench/apps/frappe_app/scripts/safe-pull-rebase.sh'
alias pre-commit-check='/home/frappe/frappe-bench/apps/frappe_app/scripts/pre-commit-check.sh'

# Reload shell
source ~/.bashrc

# Now run from anywhere:
check-apps
```

**Option 4: Symlink to local bin**
```bash
mkdir -p ~/bin
ln -s /home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh ~/bin/check-apps
ln -s /home/frappe/frappe-bench/apps/frappe_app/scripts/safe-pull-rebase.sh ~/bin/safe-rebase
ln -s /home/frappe/frappe-bench/apps/frappe_app/scripts/pre-commit-check.sh ~/bin/pre-commit-check

# Add ~/bin to PATH if not already there
export PATH="$PATH:$HOME/bin"
```

### Verifying Installation

```bash
# Check if scripts are executable
ls -la /home/frappe/frappe-bench/apps/frappe_app/scripts/

# Should show:
# -rwxr-xr-x ... check-all-apps.sh
# -rwxr-xr-x ... safe-pull-rebase.sh
# -rwxr-xr-x ... pre-commit-check.sh

# If not executable, run:
chmod +x /home/frappe/frappe-bench/apps/frappe_app/scripts/*.sh
```

### Testing Scripts

```bash
# Test check-all-apps.sh
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Test safe-pull-rebase.sh (from any app directory)
cd /home/frappe/frappe-bench/apps/frappe
/home/frappe/frappe-bench/apps/frappe_app/scripts/safe-pull-rebase.sh

# Test pre-commit-check.sh
cd /home/frappe/frappe-bench/apps/your_app
# Make some changes and stage them
git add .
/home/frappe/frappe-bench/apps/frappe_app/scripts/pre-commit-check.sh
```

---

## Common Workflows

### Daily Workflow

```bash
# Morning: Check status of all apps
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Address any diverged apps
cd apps/compliance
../../frappe_app/scripts/safe-pull-rebase.sh

# Before committing changes
../../frappe_app/scripts/pre-commit-check.sh
git add .
git commit -m "feat: your message"
```

### Before Bench Update

```bash
# Check all apps status
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Commit any uncommitted changes
cd apps/your_app
git add .
../../frappe_app/scripts/pre-commit-check.sh
git commit -m "WIP: Save before update"

# Resolve any diverged branches
../../frappe_app/scripts/safe-pull-rebase.sh

# Now safe to run bench update
cd /home/frappe/frappe-bench
bench update
```

### Feature Branch Workflow

```bash
# Start new feature
cd /home/frappe/frappe-bench/apps/your_app
git checkout main
../../frappe_app/scripts/safe-pull-rebase.sh  # Ensure up-to-date
git checkout -b feature/new-feature

# Work on feature...
# Make changes

# Before committing
../../frappe_app/scripts/pre-commit-check.sh
git add .
git commit -m "feat: implement new feature"

# Before pushing, catch up with main
git checkout main
../../frappe_app/scripts/safe-pull-rebase.sh
git checkout feature/new-feature
git rebase main
git push origin feature/new-feature
```

### Multi-App Update

```bash
# Check which apps need updates
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Update each diverged app
for app in compliance custom_app hrms; do
    echo "Updating $app..."
    cd "apps/$app"
    ../../frappe_app/scripts/safe-pull-rebase.sh
    cd ../..
done

# Verify all clean
./apps/frappe_app/scripts/check-all-apps.sh
```

---

## Troubleshooting

### "Permission denied" Error

**Problem:**
```bash
$ ./check-all-apps.sh
bash: ./check-all-apps.sh: Permission denied
```

**Solution:**
```bash
chmod +x /home/frappe/frappe-bench/apps/frappe_app/scripts/*.sh
```

### Scripts Not Finding Apps

**Problem:**
Scripts can't find apps directory

**Solution:**
Ensure `BENCH_PATH` in scripts matches your installation:
```bash
# Edit script and verify:
BENCH_PATH="/home/frappe/frappe-bench/apps"

# Or set environment variable:
export BENCH_PATH="/your/custom/path/apps"
```

### safe-pull-rebase.sh Fails with "No remote found"

**Problem:**
App doesn't have `upstream` or `origin` remote

**Solution:**
```bash
cd /home/frappe/frappe-bench/apps/your_app

# Check remotes
git remote -v

# Add missing remote
git remote add upstream https://github.com/org/repo.git

# Or
git remote add origin https://github.com/yourname/repo.git
```

### pre-commit-check.sh Shows False Positives

**Problem:**
Script flags legitimate code (e.g., password validation function)

**Solution:**
```bash
# Review the flagged code
git diff --cached

# If it's legitimate, bypass the check:
git commit --no-verify -m "message"

# Or fix the script to exclude your pattern
```

---

## Advanced Usage

### Integrate with Git Hooks

**Pre-commit hook:**
```bash
# Create .git/hooks/pre-commit
#!/bin/bash
/home/frappe/frappe-bench/apps/frappe_app/scripts/pre-commit-check.sh
```

**Make it executable:**
```bash
chmod +x .git/hooks/pre-commit
```

**Now it runs automatically on every commit!**

### Customize Scripts

All scripts are in:
```
/home/frappe/frappe-bench/apps/frappe_app/scripts/
```

Feel free to modify them for your needs:
- Add more checks to pre-commit-check.sh
- Change backup naming in safe-pull-rebase.sh
- Add filters to check-all-apps.sh

### Combine with Other Tools

**With cron for daily checks:**
```bash
# Add to crontab
0 9 * * * /home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh | mail -s "Git Status Report" you@example.com
```

**With custom bench commands:**
```python
# In frappe_app/frappe_app/commands.py
import click
import subprocess

@click.command('check-apps')
def check_apps():
    """Check Git status of all apps"""
    subprocess.run(['/home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh'])
```

---

## Best Practices

1. **Run check-all-apps.sh daily** - Make it part of your morning routine

2. **Use safe-pull-rebase.sh instead of manual rebase** - Automatic backups save time

3. **Run pre-commit-check.sh before every commit** - Catch issues early

4. **Create aliases** - Make scripts easy to access

5. **Review script output** - Don't just glance, actually read what scripts tell you

6. **Keep scripts updated** - As your workflow evolves, update scripts

7. **Share with team** - Ensure everyone uses same workflow

8. **Backup before risky operations** - Scripts create backups, but you can create more

---

## Related Documentation

- [git-workflow-frappe-bench.md](../git-workflow-frappe-bench.md) - Comprehensive Git workflow guide
- [git-commands-reference.md](../git-commands-reference.md) - Git commands reference
- [ErpnextV15_Ubuntu24.04.md](../ErpnextV15_Ubuntu24.04.md) - Installation guide with Git setup

---

## Contributing

Found a bug or want to improve a script?

1. Test your changes thoroughly
2. Document any new features
3. Update this README if needed
4. Share with the team

---

## Support

- Check [git-workflow-frappe-bench.md](../git-workflow-frappe-bench.md) for detailed Git workflows
- Review script source code - they're well commented
- Ask in team chat for workflow questions

---

**Last Updated:** 2024-12-26
**Maintained By:** DevOps Team
