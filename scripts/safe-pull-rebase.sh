#!/bin/bash
# safe-pull-rebase.sh
# Safely pull with rebase after running safety checks
# Usage: cd /path/to/app && /path/to/safe-pull-rebase.sh

APP_PATH=$(pwd)
APP_NAME=$(basename "$APP_PATH")

echo "Safe Pull with Rebase for: $APP_NAME"
echo "========================================"

# Check if in git repo
if [ ! -d .git ]; then
    echo "❌ Not a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "❌ You have uncommitted changes. Please commit or stash them first."
    git status -s
    exit 1
fi

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $BRANCH"

# Get remote name (check for upstream first, then origin)
if git remote | grep -q "^upstream$"; then
    REMOTE="upstream"
elif git remote | grep -q "^origin$"; then
    REMOTE="origin"
else
    echo "❌ No remote found (upstream or origin)"
    exit 1
fi
echo "Remote: $REMOTE"

# Fetch
echo "Fetching from $REMOTE..."
git fetch "$REMOTE"

# Check divergence
STATUS=$(git rev-list --left-right --count HEAD..."$REMOTE/$BRANCH" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Cannot compare with remote branch $REMOTE/$BRANCH"
    exit 1
fi

AHEAD=$(echo "$STATUS" | cut -f1)
BEHIND=$(echo "$STATUS" | cut -f2)

echo "Status: $AHEAD ahead, $BEHIND behind"

if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
    echo "✓ Already up-to-date"
    exit 0
elif [ "$AHEAD" -eq 0 ]; then
    echo "Fast-forwarding..."
    git pull "$REMOTE" "$BRANCH"
elif [ "$BEHIND" -eq 0 ]; then
    echo "✓ Local is ahead, consider pushing"
    echo "To push: git push $REMOTE $BRANCH"
else
    echo "Branch has diverged. Creating backup..."
    BACKUP_BRANCH="backup-$BRANCH-$(date +%Y%m%d-%H%M%S)"
    git branch "$BACKUP_BRANCH"
    echo "Created backup: $BACKUP_BRANCH"

    echo "Rebasing..."
    git rebase "$REMOTE/$BRANCH"

    if [ $? -eq 0 ]; then
        echo "✓ Rebase successful"
        echo "To push: git push --force-with-lease $REMOTE $BRANCH"
    else
        echo "❌ Rebase failed. Resolve conflicts and run: git rebase --continue"
        echo "Or abort with: git rebase --abort"
        exit 1
    fi
fi
