#!/bin/bash

# PR Management Script
# This script will take a PR out of draft, approve it, and merge it

set -e

echo "🔄 PR Management Script"
echo "======================"

# Check if user is authenticated with GitHub CLI
if ! gh auth status &>/dev/null; then
    echo "❌ You need to authenticate with GitHub CLI first."
    echo "Please run: gh auth login"
    echo "Then run this script again."
    exit 1
fi

echo "✅ GitHub CLI authenticated"

# List all PRs to see what we're working with
echo "📋 Current Pull Requests:"
gh pr list --state all

# Get the draft PR (assuming there's only one or we want the first one)
DRAFT_PR=$(gh pr list --state open --draft --json number --jq '.[0].number')

if [ "$DRAFT_PR" = "null" ] || [ -z "$DRAFT_PR" ]; then
    echo "❌ No draft PR found. Looking for any open PR..."
    OPEN_PR=$(gh pr list --state open --json number --jq '.[0].number')
    
    if [ "$OPEN_PR" = "null" ] || [ -z "$OPEN_PR" ]; then
        echo "❌ No open PR found."
        exit 1
    else
        echo "📝 Found open PR #$OPEN_PR"
        PR_NUMBER=$OPEN_PR
    fi
else
    echo "📝 Found draft PR #$DRAFT_PR"
    PR_NUMBER=$DRAFT_PR
    
    # Take PR out of draft
    echo "🚀 Taking PR #$PR_NUMBER out of draft..."
    gh pr ready $PR_NUMBER
    echo "✅ PR #$PR_NUMBER is now ready for review"
fi

# Show PR details
echo "📄 PR Details:"
gh pr view $PR_NUMBER

# Approve the PR
echo "👍 Approving PR #$PR_NUMBER..."
gh pr review $PR_NUMBER --approve --body "Approved by automated script"
echo "✅ PR #$PR_NUMBER approved"

# Merge the PR
echo "🔀 Merging PR #$PR_NUMBER..."
gh pr merge $PR_NUMBER --squash --delete-branch
echo "✅ PR #$PR_NUMBER merged successfully"

echo ""
echo "🎉 PR Management Complete!"
echo "========================="
echo "PR #$PR_NUMBER has been:"
echo "- Taken out of draft (if applicable)"
echo "- Approved"
echo "- Merged with squash"
echo "- Source branch deleted"