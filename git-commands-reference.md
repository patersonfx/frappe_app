# Git Commands Reference Guide

A comprehensive guide to essential Git commands for development workflows.

## Table of Contents

- [Configuration](#configuration)
- [Repository Initialization](#repository-initialization)
- [Basic Commands](#basic-commands)
- [Branching and Merging](#branching-and-merging)
- [Remote Repository Operations](#remote-repository-operations)
- [Stashing](#stashing)
- [Viewing History and Changes](#viewing-history-and-changes)
- [Undoing Changes](#undoing-changes)
- [Tagging](#tagging)
- [Advanced Operations](#advanced-operations)
- [Troubleshooting](#troubleshooting)

---

## Configuration

### Set User Information

```bash
# Set username globally
git config --global user.name "Your Name"

# Set email globally
git config --global user.email "your.email@example.com"

# Set username for current repository only
git config user.name "Your Name"

# Set email for current repository only
git config user.email "your.email@example.com"
```

### View Configuration

```bash
# List all configuration settings
git config --list

# Show specific configuration
git config user.name
git config user.email

# Show configuration with origin
git config --list --show-origin
```

### Configure Default Editor

```bash
# Set default editor (e.g., VS Code)
git config --global core.editor "code --wait"

# Set Vim as editor
git config --global core.editor "vim"

# Set Nano as editor
git config --global core.editor "nano"
```

### Configure Line Endings

```bash
# For Windows
git config --global core.autocrlf true

# For Mac/Linux
git config --global core.autocrlf input
```

---

## Repository Initialization

### Create New Repository

```bash
# Initialize new repository in current directory
git init

# Initialize repository with specific name
git init my-project

# Initialize bare repository (for servers)
git init --bare
```

### Clone Existing Repository

```bash
# Clone repository
git clone https://github.com/user/repository.git

# Clone to specific directory
git clone https://github.com/user/repository.git my-folder

# Clone specific branch
git clone -b branch-name https://github.com/user/repository.git

# Clone with depth (shallow clone)
git clone --depth 1 https://github.com/user/repository.git
```

---

## Basic Commands

### Check Status

```bash
# Show working tree status
git status

# Show status in short format
git status -s

# Show branch information
git status -b
```

### Add Files to Staging

```bash
# Add specific file
git add filename.js

# Add all files in current directory
git add .

# Add all files in repository
git add -A

# Add files interactively
git add -i

# Add only modified files (not new files)
git add -u

# Add files with wildcard
git add *.py
```

### Commit Changes

```bash
# Commit with message
git commit -m "Your commit message"

# Commit with detailed message
git commit -m "Title" -m "Detailed description"

# Commit all modified files (skip staging)
git commit -am "Your commit message"

# Amend last commit
git commit --amend

# Amend last commit message only
git commit --amend -m "New message"

# Amend without changing message
git commit --amend --no-edit
```

### Remove Files

```bash
# Remove file from Git and filesystem
git rm filename.js

# Remove file from Git only (keep in filesystem)
git rm --cached filename.js

# Remove directory recursively
git rm -r directory/

# Force remove (if file has changes)
git rm -f filename.js
```

### Move/Rename Files

```bash
# Rename file
git mv old-name.js new-name.js

# Move file to directory
git mv filename.js directory/
```

---

## Branching and Merging

### Branch Management

```bash
# List local branches
git branch

# List all branches (local and remote)
git branch -a

# List remote branches
git branch -r

# Create new branch
git branch new-branch

# Create and switch to new branch
git checkout -b new-branch

# Create branch from specific commit
git branch new-branch commit-hash

# Delete local branch
git branch -d branch-name

# Force delete local branch
git branch -D branch-name

# Delete remote branch
git push origin --delete branch-name

# Rename current branch
git branch -m new-branch-name

# Rename specific branch
git branch -m old-name new-name
```

### Switching Branches

```bash
# Switch to existing branch
git checkout branch-name

# Switch to branch (newer syntax)
git switch branch-name

# Create and switch to new branch
git switch -c new-branch

# Switch to previous branch
git checkout -

# Switch to remote branch
git checkout -b local-branch origin/remote-branch
```

### Merging

```bash
# Merge branch into current branch
git merge branch-name

# Merge with commit message
git merge branch-name -m "Merge message"

# Merge without fast-forward
git merge --no-ff branch-name

# Squash commits during merge
git merge --squash branch-name

# Abort merge in case of conflicts
git merge --abort

# Continue merge after resolving conflicts
git merge --continue
```

### Rebasing

```bash
# Rebase current branch onto another
git rebase branch-name

# Interactive rebase (last 3 commits)
git rebase -i HEAD~3

# Continue rebase after resolving conflicts
git rebase --continue

# Skip current commit during rebase
git rebase --skip

# Abort rebase
git rebase --abort

# Rebase onto remote branch
git rebase origin/main
```

---

## Remote Repository Operations

### Managing Remotes

```bash
# Show remote repositories
git remote

# Show remote repositories with URLs
git remote -v

# Add remote repository
git remote add origin https://github.com/user/repo.git

# Change remote URL
git remote set-url origin https://github.com/user/new-repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename old-name new-name

# Show detailed remote information
git remote show origin
```

### Fetching and Pulling

```bash
# Fetch from remote (doesn't merge)
git fetch origin

# Fetch all remotes
git fetch --all

# Fetch and prune deleted remote branches
git fetch --prune

# Pull from remote (fetch + merge)
git pull origin main

# Pull with rebase instead of merge
git pull --rebase origin main

# Pull from specific branch
git pull origin branch-name
```

### Pushing

```bash
# Push to remote branch
git push origin main

# Push and set upstream
git push -u origin main

# Push all branches
git push --all origin

# Push tags
git push --tags

# Force push (use with caution!)
git push --force origin main

# Force push with lease (safer)
git push --force-with-lease origin main

# Push specific tag
git push origin tag-name

# Delete remote branch
git push origin --delete branch-name
```

---

## Stashing

### Basic Stashing

```bash
# Stash current changes
git stash

# Stash with message
git stash save "Work in progress on feature X"

# List all stashes
git stash list

# Apply most recent stash
git stash apply

# Apply specific stash
git stash apply stash@{2}

# Apply and remove stash
git stash pop

# Remove most recent stash
git stash drop

# Remove specific stash
git stash drop stash@{1}

# Clear all stashes
git stash clear
```

### Advanced Stashing

```bash
# Stash including untracked files
git stash -u

# Stash including untracked and ignored files
git stash -a

# Create branch from stash
git stash branch new-branch stash@{0}

# Show stash contents
git stash show

# Show stash diff
git stash show -p stash@{0}
```

---

## Viewing History and Changes

### Log Commands

```bash
# Show commit history
git log

# Show one line per commit
git log --oneline

# Show last N commits
git log -n 5

# Show commits with file changes
git log --stat

# Show commits with diffs
git log -p

# Show graphical representation
git log --graph --oneline --all

# Show commits by author
git log --author="Author Name"

# Show commits in date range
git log --since="2024-01-01" --until="2024-12-31"

# Show commits affecting specific file
git log -- filename.js

# Show commits with specific message
git log --grep="bug fix"

# Show commits by date
git log --after="2024-01-01"
git log --before="2024-12-31"

# Beautiful format
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
```

### Viewing Changes

```bash
# Show unstaged changes
git diff

# Show staged changes
git diff --staged
git diff --cached

# Show changes between branches
git diff branch1..branch2

# Show changes between commits
git diff commit1 commit2

# Show changes for specific file
git diff filename.js

# Show word-level diff
git diff --word-diff

# Show changes with statistics
git diff --stat

# Show changes ignoring whitespace
git diff -w
```

### Show Specific Commit

```bash
# Show specific commit
git show commit-hash

# Show specific file from commit
git show commit-hash:path/to/file

# Show files changed in commit
git show --name-only commit-hash

# Show commit statistics
git show --stat commit-hash
```

### Blame

```bash
# Show who changed each line
git blame filename.js

# Show blame with line numbers
git blame -L 10,20 filename.js

# Show blame with email
git blame -e filename.js
```

---

## Undoing Changes

### Discard Changes

```bash
# Discard changes in working directory
git checkout -- filename.js

# Discard all changes in working directory
git checkout -- .

# Discard changes (newer syntax)
git restore filename.js

# Discard all changes
git restore .
```

### Unstage Files

```bash
# Unstage file
git reset HEAD filename.js

# Unstage all files
git reset HEAD

# Unstage file (newer syntax)
git restore --staged filename.js
```

### Reset Commits

```bash
# Soft reset - keep changes staged
git reset --soft HEAD~1

# Mixed reset - keep changes unstaged (default)
git reset HEAD~1

# Hard reset - discard all changes
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard commit-hash

# Reset single file to specific commit
git checkout commit-hash -- filename.js
```

### Revert Commits

```bash
# Revert specific commit (creates new commit)
git revert commit-hash

# Revert without committing
git revert -n commit-hash

# Revert merge commit
git revert -m 1 merge-commit-hash

# Continue revert after conflicts
git revert --continue

# Abort revert
git revert --abort
```

### Clean Untracked Files

```bash
# Show what would be deleted
git clean -n

# Delete untracked files
git clean -f

# Delete untracked files and directories
git clean -fd

# Delete untracked and ignored files
git clean -fdx
```

---

## Tagging

### Creating Tags

```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0 release"

# Tag specific commit
git tag -a v1.0.0 commit-hash -m "Tag message"

# List all tags
git tag

# List tags with pattern
git tag -l "v1.*"
```

### Managing Tags

```bash
# Show tag details
git show v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0

# Push specific tag
git push origin v1.0.0

# Push all tags
git push origin --tags

# Checkout tag
git checkout v1.0.0
```

---

## Advanced Operations

### Cherry Pick

```bash
# Apply specific commit to current branch
git cherry-pick commit-hash

# Cherry pick multiple commits
git cherry-pick commit1 commit2

# Cherry pick without committing
git cherry-pick -n commit-hash

# Continue cherry-pick after conflicts
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort
```

### Reflog

```bash
# Show reference log
git reflog

# Show reflog for specific branch
git reflog show branch-name

# Recover lost commit
git checkout commit-hash

# Recover deleted branch
git checkout -b recovered-branch commit-hash
```

### Submodules

```bash
# Add submodule
git submodule add https://github.com/user/repo.git path/to/submodule

# Initialize submodules after clone
git submodule init

# Update submodules
git submodule update

# Clone with submodules
git clone --recurse-submodules https://github.com/user/repo.git

# Update all submodules
git submodule update --remote

# Remove submodule
git submodule deinit path/to/submodule
git rm path/to/submodule
```

### Worktrees

```bash
# Create new worktree
git worktree add ../new-worktree branch-name

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../new-worktree

# Prune worktrees
git worktree prune
```

### Bisect (Find Bug Introduction)

```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark known good commit
git bisect good commit-hash

# Mark current commit as good
git bisect good

# Skip current commit
git bisect skip

# End bisect
git bisect reset
```

---

## Troubleshooting

### Resolve Conflicts

```bash
# Check conflicted files
git status

# After resolving conflicts in files
git add resolved-file.js

# Continue merge/rebase
git merge --continue
git rebase --continue

# Abort merge/rebase
git merge --abort
git rebase --abort

# Use theirs version
git checkout --theirs filename.js

# Use ours version
git checkout --ours filename.js
```

### Fix Common Issues

```bash
# Fix "detached HEAD" state
git checkout main

# Recover deleted branch (if you know commit hash)
git checkout -b recovered-branch commit-hash

# Undo last commit but keep changes
git reset --soft HEAD~1

# Remove file from last commit
git reset --soft HEAD~1
git reset HEAD filename.js
git commit -c ORIG_HEAD

# Change last commit author
git commit --amend --author="New Author <email@example.com>"

# Fix wrong branch commit
git checkout correct-branch
git cherry-pick commit-hash
git checkout wrong-branch
git reset --hard HEAD~1
```

### Cleanup and Maintenance

```bash
# Remove remote tracking branches that are deleted
git remote prune origin

# Cleanup unnecessary files
git gc

# Aggressive cleanup
git gc --aggressive

# Check repository integrity
git fsck

# Show repository size
git count-objects -vH

# Remove specific file from history (use with caution!)
git filter-branch --tree-filter 'rm -f passwords.txt' HEAD
```

### Configuration Issues

```bash
# Reset global config
git config --global --unset user.name
git config --global --unset user.email

# Edit config directly
git config --global --edit

# Check where config is coming from
git config --list --show-origin
```

---

## Useful Aliases

Add these to your `.gitconfig` file or use `git config --global alias.<name> '<command>'`:

```bash
# Common shortcuts
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Advanced aliases
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'
git config --global alias.amend 'commit --amend --no-edit'
git config --global alias.undo 'reset --soft HEAD~1'

# Complex aliases
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

---

## Best Practices

1. **Commit Often**: Make small, focused commits with clear messages
2. **Pull Before Push**: Always pull before pushing to avoid conflicts
3. **Branch Strategy**: Use feature branches for new development
4. **Clear Messages**: Write descriptive commit messages explaining "why" not "what"
5. **Review Before Commit**: Use `git diff` to review changes before committing
6. **Don't Commit Secrets**: Never commit passwords, API keys, or sensitive data
7. **Use .gitignore**: Properly configure .gitignore for your project
8. **Test Before Push**: Run tests before pushing to remote
9. **Rebase vs Merge**: Understand when to use each
10. **Protect Main Branch**: Use branch protection rules on important branches

---

## Quick Reference

### Common Workflow

```bash
# Start new feature
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Update with latest changes
git checkout main
git pull origin main
git checkout feature/new-feature
git rebase main

# Push to remote
git push -u origin feature/new-feature

# After merge, cleanup
git checkout main
git pull origin main
git branch -d feature/new-feature
```

### Emergency Fixes

```bash
# Undo last commit, keep changes
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# Recover deleted branch (within ~30 days)
git reflog
git checkout -b recovered-branch commit-hash

# Fix wrong branch
git stash
git checkout correct-branch
git stash pop
```

---

## Additional Resources

- [Official Git Documentation](https://git-scm.com/doc)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Interactive Git Tutorial](https://learngitbranching.js.org/)

---

**Version**: 1.0  
**Last Updated**: December 2024
