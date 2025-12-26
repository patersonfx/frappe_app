#!/bin/bash
# pre-commit-check.sh
# Run safety checks before committing
# Usage: ./pre-commit-check.sh

echo "Pre-Commit Safety Check"
echo "======================="

# Check for common issues
ISSUES=()

# Check for debugging statements
if git diff --cached | grep -E "console\.log|debugger|pdb\.set_trace|import ipdb|binding\.pry" > /dev/null; then
    ISSUES+=("Debugging statements found")
fi

# Check for TODO/FIXME
if git diff --cached | grep -E "TODO|FIXME|XXX" > /dev/null; then
    echo "⚠️  Found TODO/FIXME comments (review recommended)"
fi

# Check for large files
LARGE_FILES=$(git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        # Get file size (cross-platform)
        SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        if [ "$SIZE" -gt 1048576 ]; then  # 1MB
            echo "$file ($(($SIZE / 1024))KB)"
        fi
    fi
done)

if [ -n "$LARGE_FILES" ]; then
    ISSUES+=("Large files: $LARGE_FILES")
fi

# Check for potential secrets (basic check)
if git diff --cached | grep -iE "password\s*=|api_key\s*=|secret\s*=|token\s*=" | grep -v "^-" > /dev/null; then
    ISSUES+=("Potential secrets found")
fi

# Report issues
if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "❌ Issues found:"
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ All checks passed"
fi
