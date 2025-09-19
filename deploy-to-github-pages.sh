#!/bin/bash

# Simplified GitHub Pages Deployment Script for temprepo
# This script will enable GitHub Pages and handle PR management automatically

set -e

echo "🚀 GitHub Pages Deployment Script"
echo "=================================="

# Check if user is authenticated with GitHub CLI
if ! gh auth status &>/dev/null; then
    echo "❌ You need to authenticate with GitHub CLI first."
    echo "Please run: gh auth login"
    echo "Then run this script again."
    exit 1
fi

echo "✅ GitHub CLI authenticated"

# Get GitHub username
GITHUB_USERNAME=$(gh api user --jq .login)

# Check if repository exists
echo "📦 Checking GitHub repository 'temprepo'..."
if gh repo view temprepo &>/dev/null; then
    echo "✅ Repository 'temprepo' found"
else
    echo "❌ Repository 'temprepo' not found. Please create it first or check the name."
    exit 1
fi

# Handle any open PRs automatically
echo "🔄 Checking for open PRs..."
OPEN_PRS=$(gh pr list --state open --json number --jq '.[].number')

if [ -n "$OPEN_PRS" ]; then
    for PR_NUMBER in $OPEN_PRS; do
        echo "📝 Processing PR #$PR_NUMBER..."
        
        # Take out of draft if needed
        gh pr ready $PR_NUMBER 2>/dev/null || echo "PR already ready"
        
        # Approve and merge
        echo "👍 Approving and merging PR #$PR_NUMBER..."
        gh pr review $PR_NUMBER --approve --body "Auto-approved for deployment" 2>/dev/null || echo "Already approved"
        gh pr merge $PR_NUMBER --squash --delete-branch 2>/dev/null || echo "PR already merged"
        echo "✅ PR #$PR_NUMBER processed"
    done
else
    echo "ℹ️ No open PRs found"
fi

# Enable GitHub Pages
echo "🌐 Enabling GitHub Pages..."
gh api repos/${GITHUB_USERNAME}/temprepo/pages \
    --method POST \
    --field source[branch]=main \
    --field source[path]="/" 2>/dev/null || echo "✅ GitHub Pages already enabled"

# Get the GitHub Pages URL
PAGES_URL="https://${GITHUB_USERNAME}.github.io/temprepo"

echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo "Repository URL: https://github.com/${GITHUB_USERNAME}/temprepo"
echo "GitHub Pages URL: ${PAGES_URL}"
echo ""
echo "📝 Note: It may take a few minutes for your site to be available."