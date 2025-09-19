#!/bin/bash

# GitHub Pages Deployment Script for temprepo
# This script will create a GitHub repository and enable GitHub Pages

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

# Create the repository
echo "📦 Creating GitHub repository 'temprepo'..."
if gh repo create temprepo --public --description "Temporary repository for GitHub Pages" --clone=false; then
    echo "✅ Repository created successfully"
else
    echo "⚠️  Repository might already exist, continuing..."
fi

# Add remote origin
echo "🔗 Adding remote origin..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/$(gh api user --jq .login)/temprepo.git

# Push to main branch
echo "📤 Pushing to GitHub..."
git branch -M main
git push -u origin main

# Enable GitHub Pages
echo "🌐 Enabling GitHub Pages..."
gh api repos/$(gh api user --jq .login)/temprepo/pages \
    --method POST \
    --field source[branch]=main \
    --field source[path]="/" || echo "Pages might already be enabled"

# Wait a moment for GitHub to process
sleep 5

# Get the GitHub Pages URL
GITHUB_USERNAME=$(gh api user --jq .login)
PAGES_URL="https://${GITHUB_USERNAME}.github.io/temprepo"

echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo "Repository URL: https://github.com/${GITHUB_USERNAME}/temprepo"
echo "GitHub Pages URL: ${PAGES_URL}"
echo ""
echo "📝 Note: It may take a few minutes for your site to be available at the GitHub Pages URL."
echo "The deployment process can take 5-10 minutes to complete."

# Open the repository in browser (optional)
read -p "🌐 Would you like to open the repository in your browser? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh repo view --web
fi