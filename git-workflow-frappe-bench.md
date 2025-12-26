# Git Workflow Guide for Frappe Bench Multi-App Development

## Table of Contents

1. [Introduction to Frappe-Bench Git Architecture](#introduction-to-frappe-bench-git-architecture)
2. [Pre-Workflow Safety Checks](#pre-workflow-safety-checks)
3. [Core Workflows](#core-workflows)
   - [When to Commit Before Pulling](#when-to-commit-before-pulling)
   - [Handling Diverged Branches](#handling-diverged-branches)
   - [Multi-App Coordination](#multi-app-coordination)
4. [Common Scenarios & Solutions](#common-scenarios--solutions)
5. [Recovery Procedures](#recovery-procedures)
6. [Automation & Helper Scripts](#automation--helper-scripts)
7. [Best Practices for Multi-App Development](#best-practices-for-multi-app-development)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Quick Reference](#quick-reference)

---

## Introduction to Frappe-Bench Git Architecture

### How Bench Manages Multiple Repositories

Frappe Bench is a command-line tool that manages multiple independent applications, each with its own Git repository. In a typical Frappe-bench installation, you may have:

- **frappe** - Core framework (always required)
- **erpnext** - ERP application (if installed)
- **Custom apps** - Your organization's applications
- **Third-party apps** - Community-developed applications

Each app in `/home/frappe/frappe-bench/apps/` is an independent Git repository with its own:
- Commit history
- Remote repositories
- Branches
- Git configuration

### Understanding App Dependencies

Apps in Frappe Bench have dependencies:
```
frappe (base framework)
  └── erpnext (depends on frappe)
      └── your_custom_app (may depend on erpnext)
```

**Important:** When updating apps, consider dependencies:
1. Update base dependencies first (frappe before erpnext)
2. Test after each update
3. Coordinate updates across dependent apps

### Branch Tracking Strategies

**Common Remote Naming Conventions:**
- `origin` - Your fork of the repository
- `upstream` - Original repository (authoritative source)

**Recommended Setup:**
```bash
# View your remotes
cd /home/frappe/frappe-bench/apps/your_app
git remote -v

# Typical output:
# origin    https://github.com/yourname/your_app.git (fetch)
# origin    https://github.com/yourname/your_app.git (push)
# upstream  https://github.com/orgname/your_app.git (fetch)
# upstream  https://github.com/orgname/your_app.git (push)
```

### Bench Update Awareness

The `bench update` command automatically runs `git pull` for all apps. Before running:

```bash
# Check status of all apps first
cd /home/frappe/frappe-bench/apps
for app in */; do
    echo "=== $(basename $app) ==="
    git -C "$app" status -sb 2>/dev/null || echo "Not a git repo"
done
```

---

## Pre-Workflow Safety Checks

Before any Git operation that modifies history or integrates changes, run these safety checks:

### 1. Check Working Tree Status

```bash
git status
```

**What to look for:**
- `nothing to commit, working tree clean` - Safe to proceed
- `Changes not staged for commit` - You have uncommitted modifications
- `Changes to be committed` - You have staged changes

### 2. Verify Remote Configuration

```bash
git remote -v
```

**Verify:**
- Remote URLs are correct
- You have both fetch and push URLs
- Remote names match your workflow (origin, upstream)

### 3. Check Branch Tracking

```bash
git branch -vv
```

**Output shows:**
- Current branch (marked with `*`)
- Tracking relationship (e.g., `[upstream/360-one: ahead 1, behind 2]`)
- Latest commit hash and message

### 4. Identify Divergence

```bash
git fetch upstream  # or origin
git status
```

**Divergence indicators:**
- `Your branch is ahead of 'upstream/branch' by X commits` - You have local commits
- `Your branch is behind 'upstream/branch' by Y commits` - Remote has new commits
- `Your branch and 'upstream/branch' have diverged` - Both have unique commits

### 5. Create Backup Before Risky Operations

```bash
# Create timestamped backup branch
git branch backup-$(git rev-parse --abbrev-ref HEAD)-$(date +%Y%m%d-%H%M%S)

# Verify backup created
git branch -l backup-*
```

**Always create backups before:**
- Rebasing
- Resetting
- Cherry-picking
- Force pushing
- Complex merges

---

## Core Workflows

### When to Commit Before Pulling

#### Decision Tree

```
Do you have uncommitted changes?
│
├─ YES → Are these changes important?
│         │
│         ├─ YES → Commit with meaningful message
│         │        git add <files>
│         │        git commit -m "feat: description"
│         │
│         └─ NO → Stash for later
│                  git stash save "WIP: description"
│
└─ NO → Check divergence status
         │
         ├─ Ahead + Behind → Handle divergence (see next section)
         ├─ Only Behind → Safe to pull directly
         ├─ Only Ahead → Consider pushing
         └─ Up to date → No action needed
```

#### Scenario A: Clean Working Tree, Branch Diverged

**Your situation:**
- `git status` shows working tree is clean
- `git status` shows "X ahead, Y behind"
- You have commits that remote doesn't have
- Remote has commits you don't have

**Solution:** Use rebase or merge (see Handling Diverged Branches)

#### Scenario B: Uncommitted Changes, Need to Pull

**Option 1: Commit First (Recommended for important work)**
```bash
# Stage your changes
git add .

# Commit with meaningful message
git commit -m "feat: Add user authentication module"

# Now handle divergence
git fetch upstream
git rebase upstream/main  # or merge
```

**Option 2: Stash (For work in progress)**
```bash
# Stash with descriptive message
git stash save "WIP: Working on authentication module"

# Pull changes
git pull upstream main

# Restore your work
git stash pop

# Resolve conflicts if any, then commit
```

#### Scenario C: Staged Changes, Remote Has Updates

```bash
# Check what's staged
git status

# Commit staged changes
git commit -m "your message"

# Then pull
git fetch upstream
git rebase upstream/main
```

#### Scenario D: Multiple Apps Need Coordination

```bash
# Check all apps first
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh  # Use helper script

# Commit changes in each app
cd apps/app1 && git add . && git commit -m "msg" && cd ../..
cd apps/app2 && git add . && git commit -m "msg" && cd ../..

# Then update all with bench update
bench update
```

### Handling Diverged Branches

When your branch has diverged (`X ahead, Y behind`), you have two main strategies:

#### Strategy 1: Rebase (Preferred for Clean History)

**When to use:**
- You want a linear commit history
- Your commits haven't been shared/pushed yet
- Working on feature branches
- Solo development or small team

**Step-by-Step Process:**

```bash
# Step 1: Ensure clean working tree
git status
# Must show: "nothing to commit, working tree clean"

# Step 2: Fetch latest remote changes
git fetch upstream

# Step 3: Preview incoming commits
git log HEAD..upstream/360-one --oneline
git log HEAD..upstream/360-one --stat  # See files changed

# Step 4: Preview your local commits
git log upstream/360-one..HEAD --oneline

# Step 5: Create backup (safety first!)
git branch backup-360-one-$(date +%Y%m%d-%H%M%S)

# Step 6: Execute rebase
git rebase upstream/360-one

# Step 7: Verify results
git log --oneline --graph -10
git status

# Step 8: Push (requires force push)
git push --force-with-lease upstream 360-one
```

**Visual Representation:**
```
Before Rebase:
    A---B---C  (upstream/360-one)
         \
          D---E  (your branch)

After Rebase:
    A---B---C  (upstream/360-one)
             \
              D'---E'  (your branch - commits rewritten)
```

**Handling Conflicts During Rebase:**

```bash
# If rebase stops due to conflicts:
git status  # Shows conflicted files

# Edit conflicted files (look for <<<<<<< markers)
# Remove conflict markers and keep desired changes

# Stage resolved files
git add resolved-file.js

# Continue rebase
git rebase --continue

# Repeat for each conflict, or abort:
git rebase --abort  # Returns to pre-rebase state
```

#### Strategy 2: Merge (Preserves Complete History)

**When to use:**
- You've already pushed commits to shared branch
- Working with multiple collaborators
- Want to preserve exact history of parallel development
- Release branches or main/master branches

**Step-by-Step Process:**

```bash
# Step 1: Ensure clean working tree
git status

# Step 2: Fetch latest remote changes
git fetch upstream

# Step 3: Preview incoming changes
git log HEAD..upstream/360-one --oneline

# Step 4: Execute merge
git merge upstream/360-one

# Step 5: If merge conflicts occur:
git status  # Shows conflicted files
# Edit files to resolve conflicts
git add resolved-file.js
git commit  # Completes the merge

# Step 6: Push merged changes
git push upstream 360-one
```

**Visual Representation:**
```
Before Merge:
    A---B---C  (upstream/360-one)
         \
          D---E  (your branch)

After Merge:
    A---B---C  (upstream/360-one)
         \   \
          D---E---M  (your branch with merge commit M)
```

#### Strategy 3: Reset and Re-apply (Nuclear Option)

**When to use:**
- Rebase failed irreparably
- History is severely tangled
- Starting fresh is simpler
- As last resort only

```bash
# Step 1: Save your work
git diff upstream/360-one > my-changes.patch
# Or identify your commit hashes
git log upstream/360-one..HEAD --oneline > my-commits.txt

# Step 2: Hard reset to remote
git fetch upstream
git reset --hard upstream/360-one

# Step 3: Re-apply changes
git apply my-changes.patch
# Or cherry-pick your commits
git cherry-pick <commit-hash>
```

#### Comparison: Rebase vs Merge

| Criteria | Rebase | Merge |
|----------|--------|-------|
| **History** | Linear, clean | Complete, branched |
| **Use Case** | Feature branches, local work | Shared branches, releases |
| **Commits** | Rewrites (new hashes) | Preserves original |
| **Conflicts** | Per commit | Once at merge |
| **Risk** | Higher (history rewrite) | Lower |
| **Team Size** | Solo/small | Any size |
| **Best for** | "Catch up with main" | "Integrate feature" |
| **Push Required** | Force push | Normal push |

### Multi-App Coordination

#### Checking Status Across All Apps

**Manual Method:**
```bash
cd /home/frappe/frappe-bench/apps
for app in */; do
    echo "========================================"
    echo "App: $(basename $app)"
    echo "========================================"
    cd "$app"
    if [ -d .git ]; then
        git status -sb
        git fetch --all --quiet 2>/dev/null
        echo "Divergence: $(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo 'N/A')"
    else
        echo "Not a Git repository"
    fi
    cd ..
    echo ""
done
```

**Using Helper Script:**
```bash
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh
```

#### Coordinated Updates

**Scenario: Update all apps to latest versions**

```bash
# Step 1: Check current state
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Step 2: Commit any pending changes
cd apps/your_app
git add .
git commit -m "WIP: Save current state before update"

# Step 3: Run bench update (pulls all apps)
cd /home/frappe/frappe-bench
bench update

# Step 4: If conflicts occur, resolve per app
cd apps/affected_app
git status
# Resolve conflicts
git add .
git rebase --continue  # or git merge --continue
```

#### Dependency-Aware Updates

```bash
# Update in dependency order:

# 1. Update frappe (base framework)
cd /home/frappe/frappe-bench/apps/frappe
git fetch upstream
git rebase upstream/version-15  # or your branch

# 2. Test frappe
cd /home/frappe/frappe-bench
bench --site your-site migrate
bench start
# Test core functionality

# 3. Update erpnext (depends on frappe)
cd apps/erpnext
git fetch upstream
git rebase upstream/version-15

# 4. Test erpnext
bench --site your-site migrate
# Test ERP functionality

# 5. Update custom apps (depend on erpnext/frappe)
cd apps/custom_app
git fetch upstream
git rebase upstream/main
```

---

## Common Scenarios & Solutions

### Scenario 1: "Your branch and upstream have diverged"

**Recognition:**
```bash
$ git status
On branch 360-one
Your branch and 'upstream/360-one' have diverged,
and have 1 and 2 different commits each, respectively.
```

**Solution: Rebase Workflow**
```bash
# Quick version
git status
git fetch upstream
git rebase upstream/360-one

# Detailed version with safety
git status                                      # Verify clean
git branch backup-360-one-$(date +%Y%m%d)       # Create backup
git fetch upstream                              # Get remote changes
git log HEAD..upstream/360-one --oneline        # Preview incoming
git rebase upstream/360-one                     # Rebase
git log --oneline --graph -10                   # Verify
git push --force-with-lease upstream 360-one    # Push
```

### Scenario 2: "Uncommitted changes + need to pull"

**Recognition:**
```bash
$ git status
On branch main
Changes not staged for commit:
  modified:   file1.py
  modified:   file2.js
```

**Solution A: Commit First**
```bash
git add .
git commit -m "WIP: Current work state"
git fetch upstream
git pull --rebase upstream main
```

**Solution B: Stash**
```bash
git stash save "WIP: Working on feature X"
git fetch upstream
git pull upstream main
git stash pop
# Resolve conflicts if any
```

### Scenario 3: "Multiple apps diverged"

**Recognition:**
```bash
$ ./apps/frappe_app/scripts/check-all-apps.sh
...
Apps with diverged branches: 3
  - compliance
  - custom_app
  - hrms
```

**Solution:**
```bash
# Handle each app individually
cd /home/frappe/frappe-bench/apps/compliance
git status && git fetch upstream && git rebase upstream/360-one

cd /home/frappe/frappe-bench/apps/custom_app
git status && git fetch origin && git rebase origin/main

cd /home/frappe/frappe-bench/apps/hrms
git status && git fetch upstream && git rebase upstream/develop

# Verify all apps
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh
```

### Scenario 4: "Rebase conflicts"

**Recognition:**
```bash
$ git rebase upstream/main
...
CONFLICT (content): Merge conflict in app.py
error: could not apply abc1234... commit message
```

**Solution:**
```bash
# Step 1: Check which files have conflicts
git status

# Step 2: Open conflicted files and look for:
# <<<<<<< HEAD
# remote version
# =======
# your version
# >>>>>>> your-commit-message

# Step 3: Edit files to resolve conflicts
# Remove markers and keep desired code

# Step 4: Stage resolved files
git add app.py

# Step 5: Continue rebase
git rebase --continue

# If you get stuck or want to start over:
git rebase --abort
```

### Scenario 5: "Accidentally committed to wrong branch"

**Recognition:**
```bash
$ git log -1
commit abc1234 (HEAD -> main)
# Oops! Should be on feature-branch
```

**Solution:**
```bash
# Method 1: Move commit to correct branch (commit not pushed)
git log --oneline -1              # Note the commit hash
git checkout -b correct-branch    # Create/switch to correct branch
git checkout main                 # Go back to wrong branch
git reset --hard HEAD~1           # Remove commit from wrong branch

# Method 2: Cherry-pick to correct branch (if already pushed)
git log --oneline -1              # Note commit hash
git checkout correct-branch       # Switch to correct branch
git cherry-pick abc1234           # Apply commit
git checkout main                 # Return to wrong branch
git reset --hard HEAD~1           # Remove from wrong branch (if not pushed)
# or
git revert abc1234                # Create revert commit (if pushed)
```

### Scenario 6: "Need to pull but bench update is running"

**Recognition:**
- Another terminal running `bench update`
- Git operations hang or show "locked" errors

**Solution:**
```bash
# Don't interrupt! Wait for bench update to complete

# In separate terminal, monitor progress:
ps aux | grep bench
tail -f /home/frappe/frappe-bench/logs/bench.log

# After completion, verify state:
cd /home/frappe/frappe-bench/apps/your_app
git status

# If index.lock file exists (rare):
rm .git/index.lock  # Only if bench update crashed
```

### Scenario 7: "Pushed to wrong remote"

**Recognition:**
```bash
$ git push
# Oops! Pushed to origin instead of upstream
```

**Solution:**
```bash
# Check what was pushed
git log origin/branch..HEAD

# If you have access to both remotes:
git push upstream branch         # Push to correct remote

# If wrong remote shouldn't have the commits:
# Coordinate with team first!
git push origin +HEAD~1:branch   # Move remote back (dangerous!)
```

### Scenario 8: "Want to update just one app"

**Recognition:**
- `bench update` updates all apps
- You only want to update specific app

**Solution:**
```bash
# Update single app manually
cd /home/frappe/frappe-bench/apps/frappe
git fetch upstream
git rebase upstream/version-15

# Run migrations for this app only
cd /home/frappe/frappe-bench
bench --site your-site migrate

# Build assets
bench build --app frappe

# Restart
bench restart
```

---

## Recovery Procedures

### Recovering from Failed Rebase

#### Abort Active Rebase

```bash
# If rebase is in progress and you want to cancel:
git rebase --abort

# This returns you to the exact state before rebase started
git status  # Verify you're back to normal
```

#### Reset to Backup Branch

```bash
# If rebase completed but results are wrong:
git reflog  # Find pre-rebase state
git branch  # List backups

# Reset to backup
git reset --hard backup-360-one-20241226-143000

# Verify
git log --oneline -5
```

#### Using Reflog to Recover

```bash
# View recent HEAD movements
git reflog

# Output shows:
# abc1234 HEAD@{0}: rebase finished: refs/heads/360-one
# def5678 HEAD@{1}: rebase: commit message
# ghi9012 HEAD@{2}: rebase: checkout upstream/360-one
# jkl3456 HEAD@{3}: commit: your commit  <- Pre-rebase state!

# Reset to pre-rebase state
git reset --hard HEAD@{3}

# Or use commit hash
git reset --hard jkl3456
```

### Recovering from Accidental Force Push

#### On Your Local Machine

```bash
# Your local reflog still has the old commits
git reflog

# Find the commit before force push
git reset --hard HEAD@{n}

# Re-push (coordinate with team first!)
git push --force-with-lease upstream branch
```

#### If Others Are Affected

```bash
# Communicate with team immediately!
# Each affected person should:

# 1. Save their work
git stash

# 2. Fetch the "wrong" state
git fetch upstream

# 3. If their local branch is correct:
git push --force-with-lease upstream branch

# 4. Or reset to correct state:
git reset --hard origin/branch  # If origin has correct state
```

### Recovering Lost Commits

```bash
# Scenario: Commits seem to have disappeared

# Step 1: Search reflog
git reflog | grep -i "relevant keyword"

# Step 2: Search all branches and reflog
git log --all --oneline | grep "commit message"

# Step 3: Use fsck to find dangling commits
git fsck --lost-found

# Step 4: Examine found commits
git show <commit-hash>

# Step 5: Recover to new branch
git checkout -b recovery-branch <commit-hash>

# Step 6: Cherry-pick if needed
git checkout original-branch
git cherry-pick <commit-hash>
```

### Recovering from Wrong Reset

```bash
# Scenario: Ran `git reset --hard` by mistake

# Step 1: Check reflog immediately
git reflog

# Step 2: Find the commit before reset
# Look for: "reset: moving to HEAD~1" or similar
# The entry BEFORE this is what you want

# Step 3: Recover
git reset --hard HEAD@{1}  # Or specific commit hash

# Step 4: Verify
git log --oneline -5
```

### Recovering from Deleted Branch

```bash
# Scenario: Accidentally deleted a branch

# Step 1: Find the branch in reflog
git reflog | grep -i "branch-name"

# Or find when it was checked out last
git reflog | grep "checkout: moving"

# Step 2: Recreate branch
git checkout -b branch-name <commit-hash>

# Step 3: Verify
git log --oneline -5
```

### Recovering from Complex Mess

```bash
# When situation is too complex:

# Step 1: Create a patch of your changes
git diff upstream/main > my-work.patch

# Step 2: List files you've modified
git status > modified-files.txt

# Step 3: Reset to known good state
git fetch upstream
git reset --hard upstream/main

# Step 4: Review and apply patch
cat my-work.patch  # Review changes
git apply my-work.patch  # Apply your work

# Step 5: Commit cleanly
git add .
git commit -m "Recovered work after resolving complex state"
```

---

## Automation & Helper Scripts

The `scripts/` directory in frappe_app contains helper scripts to automate common Git workflows across multiple apps.

### check-all-apps.sh

**Purpose:** Check Git status of all apps in Frappe bench

**Usage:**
```bash
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh
```

**Output:**
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

**Features:**
- Checks all apps in parallel
- Identifies uncommitted changes
- Identifies diverged branches
- Provides summary report
- Color-coded output (if terminal supports)

### safe-pull-rebase.sh

**Purpose:** Safely pull with rebase after running all safety checks

**Usage:**
```bash
cd /home/frappe/frappe-bench/apps/your_app
/home/frappe/frappe-bench/apps/frappe_app/scripts/safe-pull-rebase.sh
```

**What it does:**
1. Checks if directory is a Git repository
2. Verifies working tree is clean
3. Identifies remote (upstream or origin)
4. Fetches latest changes
5. Checks divergence status
6. Creates backup branch
7. Executes rebase
8. Provides next steps

**Output:**
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

### pre-commit-check.sh

**Purpose:** Run safety checks before committing

**Usage:**
```bash
cd /home/frappe/frappe-bench/apps/your_app
/home/frappe/frappe-bench/apps/frappe_app/scripts/pre-commit-check.sh
```

**Checks for:**
- Debugging statements (console.log, debugger, pdb.set_trace, etc.)
- TODO/FIXME comments (warning only)
- Large files (>1MB)
- Potential secrets (password, api_key, secret, token keywords)

**Output:**
```
Pre-Commit Safety Check
=======================
⚠️  Found TODO/FIXME comments (review recommended)
❌ Issues found:
  - Debugging statements found
  - Large files: dist/bundle.js (2048KB)

Continue anyway? (y/N)
```

### Creating Git Aliases for Quick Operations

Add to `~/.gitconfig` or `/home/frappe/.gitconfig`:

```ini
[alias]
    # Status shortcuts
    st = status
    sb = status -sb

    # Branch management
    br = branch
    co = checkout
    cob = checkout -b

    # Commit shortcuts
    ci = commit
    cam = commit -am
    amend = commit --amend --no-edit

    # Log variations
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    lol = log --oneline --graph --all
    recent = log --oneline -10

    # Diff shortcuts
    df = diff
    dfc = diff --cached
    dfs = diff --stat

    # Remote operations
    fetchall = fetch --all --prune
    pullr = pull --rebase
    pushf = push --force-with-lease

    # Divergence check
    diverge = "!f() { echo 'Local vs Remote:'; git rev-list --left-right --count HEAD...@{u}; }; f"
    incoming = log HEAD..@{u} --oneline
    outgoing = log @{u}..HEAD --oneline

    # Safety operations
    backup = "!f() { git branch backup-$(git rev-parse --abbrev-ref HEAD)-$(date +%Y%m%d-%H%M%S); }; f"
    undo = reset --soft HEAD~1
    unstage = reset HEAD --
```

**Using Aliases:**
```bash
git st              # Instead of: git status
git lg -10          # Pretty log
git pullr           # Pull with rebase
git pushf           # Safe force push
git diverge         # Check ahead/behind
git backup          # Create timestamped backup
```

---

## Best Practices for Multi-App Development

### 1. Regular Status Checks

**Daily Routine:**
```bash
# Morning: Check status of all apps
cd /home/frappe/frappe-bench
./apps/frappe_app/scripts/check-all-apps.sh

# Address any divergence immediately
# Don't let multiple apps diverge simultaneously
```

**Why:** Early detection prevents complex merge scenarios

### 2. Branch Strategy

**Feature Branches:**
- Keep feature branches short-lived (< 1 week)
- Merge or rebase frequently to stay current
- Delete after merging

**Branch Naming Convention:**
```bash
# Good names:
feature/user-authentication
fix/invoice-calculation-error
refactor/payment-module
hotfix/critical-security-patch

# Poor names:
my-branch
test
new-feature
update
```

**Creating Branches:**
```bash
# Always branch from updated main/master
git checkout main
git fetch upstream
git pull upstream main
git checkout -b feature/your-feature-name
```

### 3. Communication

**Before Force Pushing:**
```bash
# 1. Announce in team chat
# 2. Wait for acknowledgment
# 3. Then force push
git push --force-with-lease upstream branch
```

**After Major Operations:**
- Document in team wiki
- Update CHANGELOG if applicable
- Notify affected team members

### 4. Backup Strategy

**Always Create Backups Before:**
- Rebasing
- Resetting
- Cherry-picking multiple commits
- Force pushing
- Complex merges

**Backup Naming:**
```bash
# Good: Timestamped and descriptive
backup-360-one-before-rebase-20241226-143000

# Poor: Non-descriptive
backup
temp
old
```

**Cleanup Old Backups:**
```bash
# Keep only last 3 backups per branch
git branch | grep "backup-360-one" | head -n -3 | xargs git branch -d
```

### 5. Commit Hygiene

**Good Commit Messages:**
```bash
# Format: type: subject

# Examples:
git commit -m "feat: Add user authentication module"
git commit -m "fix: Correct invoice calculation for discounts"
git commit -m "refactor: Simplify payment processing logic"
git commit -m "docs: Update installation instructions"
git commit -m "test: Add unit tests for user model"

# Types: feat, fix, refactor, docs, test, chore, perf, style
```

**Atomic Commits:**
- One logical change per commit
- If you can't describe it in one sentence, split it
- Makes reverting easier
- Improves code review

**Before Committing:**
```bash
# Review what you're committing
git diff --cached

# Run pre-commit checks
./apps/frappe_app/scripts/pre-commit-check.sh

# Test your changes
bench --site your-site migrate
bench restart
# Manual testing
```

### 6. Remote Configuration

**Verify Remotes Regularly:**
```bash
# Check all apps
cd /home/frappe/frappe-bench/apps
for app in */; do
    echo "=== $app ==="
    git -C "$app" remote -v 2>/dev/null || echo "Not a git repo"
done
```

**Standard Setup:**
```bash
# For forked repositories:
git remote add origin https://github.com/yourname/repo.git
git remote add upstream https://github.com/orgname/repo.git

# Verify
git remote -v

# Fetch from upstream, push to origin
git fetch upstream
git push origin branch
```

### 7. Dependency Awareness

**Update Order:**
```
1. frappe (base)
2. erpnext (depends on frappe)
3. hrms (depends on erpnext)
4. custom apps (depend on above)
```

**Testing After Updates:**
```bash
# After each app update:
bench --site your-site migrate
bench build --app app-name
bench restart

# Test core functionality before proceeding to next app
```

### 8. Bench Update Best Practices

**Before Running Bench Update:**
```bash
# 1. Check all apps status
./apps/frappe_app/scripts/check-all-apps.sh

# 2. Commit or stash all changes
# 3. Create backup
bench backup

# 4. Run update
bench update

# 5. If issues occur, restore
bench restore /path/to/backup
```

**Monitoring Bench Update:**
```bash
# In separate terminal:
tail -f logs/bench.log
```

---

## Troubleshooting Guide

### Problem: "Your branch and 'X' have diverged"

**Cause:** Parallel commits on local and remote

**Solution:**
```bash
git fetch upstream
git rebase upstream/branch  # or git merge
```

**Prevention:** Fetch before starting work
```bash
git fetch upstream
git rebase upstream/branch  # Start with latest code
# Then make your changes
```

### Problem: "Rebase resulted in conflicts"

**Cause:** Overlapping changes in same files

**Solution:**
```bash
# Step 1: Identify conflicted files
git status

# Step 2: Open each file, look for:
# <<<<<<< HEAD
# remote version
# =======
# your version
# >>>>>>> commit-message

# Step 3: Edit to keep desired code
# Remove conflict markers

# Step 4: Stage resolved files
git add file.py

# Step 5: Continue
git rebase --continue

# If too complex, abort
git rebase --abort
```

**Prevention:**
- Rebase frequently to avoid large divergence
- Communicate with team about which files you're working on
- Pull before starting new features

### Problem: "Push rejected (non-fast-forward)"

**Full Error:**
```
! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'upstream'
hint: Updates were rejected because the tip of your current branch is behind
```

**Cause:** Remote has commits you don't have

**Solution:**
```bash
# Don't use --force!
# Instead, integrate remote changes first:

git fetch upstream
git rebase upstream/main  # or merge
git push upstream main
```

**When --force-with-lease is appropriate:**
- After rebasing (history rewrite)
- You're sure others won't be affected
- After coordinating with team

```bash
git push --force-with-lease upstream branch
```

### Problem: "Lost commits after rebase"

**Cause:** Commits aren't lost, just not visible

**Solution:**
```bash
# Commits are in reflog
git reflog

# Find your commit
git reflog | grep "commit message"

# Recover
git checkout -b recovery-branch <commit-hash>
# Or
git cherry-pick <commit-hash>
```

**Prevention:** Create backup branches before rebasing

### Problem: "Bench update failed on multiple apps"

**Error:**
```
bench update
...
Error: Could not update app compliance
Error: Could not update app custom_app
```

**Cause:** Multiple apps have diverged or conflicts

**Solution:**
```bash
# Handle each app individually

# Check which apps failed
./apps/frappe_app/scripts/check-all-apps.sh

# Fix each app
cd apps/compliance
git status
# Resolve conflicts or divergence
git add .
git rebase --continue  # or commit merge

cd ../custom_app
git status
# Repeat

# After all apps are clean, retry:
cd /home/frappe/frappe-bench
bench update
```

**Prevention:**
- Run check-all-apps.sh daily
- Address divergence immediately
- Don't let apps accumulate uncommitted changes

### Problem: "Accidentally committed sensitive data"

**Immediate Action (Before Push):**
```bash
# Remove last commit but keep changes
git reset --soft HEAD~1

# Remove sensitive data from files
# Edit files to remove secrets

# Recommit
git add .
git commit -m "commit message"
```

**If Already Pushed:**
```bash
# CRITICAL: Act immediately!

# Method 1: BFG Repo-Cleaner (recommended)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files secrets.txt
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Method 2: git filter-branch (complex)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret.txt" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (coordinate with team!)
git push --force --all
git push --force --tags
```

**Prevention:**
- Use `.gitignore` for sensitive files
- Run pre-commit-check.sh before committing
- Use environment variables for secrets
- Never commit `.env` files

### Problem: "Can't switch branches - uncommitted changes"

**Error:**
```
error: Your local changes to the following files would be overwritten by checkout:
        file.py
Please commit your changes or stash them before you switch branches.
```

**Solution:**
```bash
# Option 1: Stash
git stash save "WIP on current feature"
git checkout other-branch
# Work on other branch
git checkout original-branch
git stash pop

# Option 2: Commit
git add .
git commit -m "WIP: Save progress"
git checkout other-branch
# Later return and continue:
git checkout original-branch
# Continue work, then amend commit
git commit --amend
```

### Problem: "Merge conflicts are overwhelming"

**When conflicts are too complex:**

```bash
# Option 1: Abort and use different strategy
git merge --abort
# Try: git merge -X theirs  # Or -X ours

# Option 2: Use a merge tool
git mergetool

# Option 3: Abort and ask for help
git merge --abort
# Consult with team member who made conflicting changes

# Option 4: Start fresh
git merge --abort
git diff upstream/main > my-changes.patch
git reset --hard upstream/main
# Manually reapply changes with better understanding
```

---

## Quick Reference

### Check Divergence Status

```bash
cd /home/frappe/frappe-bench/apps/your_app

# Quick status
git status

# Detailed branch info
git branch -vv

# Fetch and check
git fetch upstream
git status

# Visualize
git log --oneline --graph -10

# See incoming commits
git log HEAD..upstream/360-one --oneline

# See outgoing commits
git log upstream/360-one..HEAD --oneline

# Count divergence
git rev-list --left-right --count HEAD...upstream/360-one
```

### Rebase Workflow (Quick)

```bash
# Prerequisites: Clean working tree
git status                          # Must be clean
git branch backup-$(date +%Y%m%d)   # Create backup
git fetch upstream                  # Get remote changes
git rebase upstream/360-one         # Rebase
git log --graph --oneline -10       # Verify
git push --force-with-lease upstream 360-one  # Push
```

### Merge Workflow (Quick)

```bash
git fetch upstream
git merge upstream/360-one
git push upstream 360-one
```

### Emergency Abort Commands

```bash
# During rebase
git rebase --abort

# During merge
git merge --abort

# During cherry-pick
git cherry-pick --abort

# View history of HEAD movements
git reflog

# Reset to previous state
git reset --hard HEAD@{n}  # Where n is the state number
```

### Multi-App Quick Checks

```bash
# One-liner status for all apps
cd /home/frappe/frappe-bench/apps && for app in */; do echo "=== $app ==="; git -C "$app" status -sb 2>/dev/null || echo "Not a git repo"; done

# Using helper script
/home/frappe/frappe-bench/apps/frappe_app/scripts/check-all-apps.sh

# Quick commit across multiple apps
cd /home/frappe/frappe-bench/apps
for app in app1 app2 app3; do
    cd "$app"
    git add .
    git commit -m "Sync: update message"
    cd ..
done
```

### Common Command Combinations

```bash
# Status + Fetch + Rebase (one-liner)
git status && git fetch upstream && git rebase upstream/main

# Backup + Rebase
git branch backup-$(date +%Y%m%d) && git rebase upstream/main

# Stash + Pull + Pop
git stash && git pull upstream main && git stash pop

# Add All + Commit + Push
git add . && git commit -m "message" && git push upstream branch

# Check + Rebase + Push
git status && git rebase upstream/main && git push --force-with-lease upstream main
```

### Git Aliases Quick Reference

If you added the aliases from the Automation section:

```bash
git st              # git status
git sb              # git status -sb
git br              # git branch
git co branch       # git checkout branch
git cob new-branch  # git checkout -b new-branch
git ci              # git commit
git cam "msg"       # git commit -am "msg"
git amend           # git commit --amend --no-edit
git lg -10          # Pretty log graph
git lol             # Log oneline graph all
git recent          # Last 10 commits
git df              # git diff
git dfc             # git diff --cached
git fetchall        # git fetch --all --prune
git pullr           # git pull --rebase
git pushf           # git push --force-with-lease
git diverge         # Show ahead/behind count
git incoming        # Show incoming commits
git outgoing        # Show outgoing commits
git backup          # Create timestamped backup branch
git undo            # Undo last commit (keep changes)
git unstage         # Unstage files
```

### Most Common Workflows Summary

**1. Daily Workflow:**
```bash
git fetch upstream
git rebase upstream/main
# Make changes
git add .
git commit -m "message"
git push upstream main
```

**2. Feature Branch Workflow:**
```bash
git checkout main
git pull upstream main
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "message"
git push origin feature/new-feature
# Create PR on GitHub
```

**3. Handle Divergence:**
```bash
git status  # See divergence
git fetch upstream
git rebase upstream/branch  # or merge
git push --force-with-lease upstream branch
```

**4. Save Work Temporarily:**
```bash
git stash save "Description"
# Do other work
git stash pop  # Restore work
```

**5. Undo Mistakes:**
```bash
git reflog  # Find correct state
git reset --hard HEAD@{n}  # Restore
```

---

## Additional Resources

### Official Documentation
- [Git Documentation](https://git-scm.com/doc)
- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [ERPNext Documentation](https://docs.erpnext.com)

### Related Files in This Repository
- [git-commands-reference.md](git-commands-reference.md) - Comprehensive Git command reference
- [bench_commands_reference.md](bench_commands_reference.md) - Bench command reference
- [ErpnextV15_Ubuntu24.04.md](ErpnextV15_Ubuntu24.04.md) - Installation guide with Git setup
- [scripts/README.md](scripts/README.md) - Helper scripts usage guide

### Getting Help

**In this repository:**
- Check [git-workflow-frappe-bench.md](git-workflow-frappe-bench.md) (this file)
- Check [Troubleshooting Guide](#troubleshooting-guide) section above
- Run helper scripts for automated checks

**Online:**
- Frappe Forum: https://discuss.frappe.io
- GitHub Issues for specific apps
- Stack Overflow with `frappe` or `erpnext` tags

**Team:**
- Consult with team lead before force pushing
- Ask in team chat for workflow questions
- Pair program for complex Git operations

---

**Document Version:** 1.0
**Last Updated:** 2024-12-26
**Maintained By:** DevOps Team

---

## Changelog

### Version 1.0 (2024-12-26)
- Initial comprehensive workflow guide
- Added all common scenarios and solutions
- Included helper scripts documentation
- Added recovery procedures and troubleshooting
- Documented multi-app coordination strategies
