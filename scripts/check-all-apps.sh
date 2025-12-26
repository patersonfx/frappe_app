#!/bin/bash
# check-all-apps.sh
# Check Git status for all apps in Frappe bench
# Usage: ./check-all-apps.sh

BENCH_PATH="/home/frappe/frappe-bench/apps"
APPS_WITH_CHANGES=()
APPS_DIVERGED=()

echo "========================================"
echo "Frappe Bench Multi-App Git Status Check"
echo "========================================"
echo ""

cd "$BENCH_PATH" || exit 1

for app in */; do
    app=${app%/}  # Remove trailing slash
    echo "Checking: $app"
    cd "$BENCH_PATH/$app" || continue

    # Check if it's a git repository
    if [ ! -d .git ]; then
        echo "  ⚠️  Not a git repository"
        echo ""
        continue
    fi

    # Fetch to update remote info (silently)
    git fetch --quiet 2>/dev/null

    # Get status
    STATUS=$(git status -sb 2>/dev/null)

    # Check for uncommitted changes
    if git status --porcelain | grep -q '^'; then
        echo "  ⚠️  Has uncommitted changes"
        APPS_WITH_CHANGES+=("$app")
    fi

    # Check for divergence
    if echo "$STATUS" | grep -q "ahead\|behind"; then
        echo "  🔀 Branch diverged: $STATUS"
        APPS_DIVERGED+=("$app")
    else
        echo "  ✓ Clean and up-to-date"
    fi

    echo ""
done

# Summary
echo "========================================"
echo "SUMMARY"
echo "========================================"
echo "Apps with uncommitted changes: ${#APPS_WITH_CHANGES[@]}"
for app in "${APPS_WITH_CHANGES[@]}"; do
    echo "  - $app"
done

echo ""
echo "Apps with diverged branches: ${#APPS_DIVERGED[@]}"
for app in "${APPS_DIVERGED[@]}"; do
    echo "  - $app"
done
