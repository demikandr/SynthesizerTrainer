#!/bin/bash

# Script to set up git hooks for automatic screenshot capture
# This script creates a pre-commit hook that captures screenshots before each commit

set -e

HOOKS_DIR=".git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

# Create .git/hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Create pre-commit hook
cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash

# Pre-commit hook for SynthesizerTrainer
# Automatically captures screenshots before each commit

echo "🔄 Running pre-commit screenshot capture..."

# Check if the app is built and ready
if [ ! -d "DerivedData" ] && [ ! -f "*.app" ]; then
    echo "⚠️  App not built yet. Building first..."
    
    # Build the app
    xcodebuild -project SynthesizerTrainer.xcodeproj -scheme SynthesizerTrainer -destination 'platform=iOS Simulator,name=iPhone 15' build
    
    if [ $? -ne 0 ]; then
        echo "❌ Build failed. Cannot capture screenshots."
        echo "Please fix build errors before committing."
        exit 1
    fi
fi

# Check if screenshot capture script exists
if [ -f "./capture_screenshots.sh" ]; then
    echo "📸 Capturing screenshots for commit..."
    
    # Run screenshot capture
    if ./capture_screenshots.sh; then
        echo "✅ Screenshots captured successfully"
        
        # Add screenshots to the current commit
        git add screenshots/ 2>/dev/null || echo "No screenshots to add"
        
    else
        echo "⚠️  Screenshot capture failed, but allowing commit to proceed"
        echo "You may want to capture screenshots manually"
    fi
else
    echo "⚠️  capture_screenshots.sh not found. Skipping screenshot capture."
fi

echo "✅ Pre-commit hook completed"
EOF

# Make the hook executable
chmod +x "$PRE_COMMIT_HOOK"

echo "✅ Git pre-commit hook installed successfully!"
echo ""
echo "📋 What this hook does:"
echo "• Runs before each commit"
echo "• Builds the app if needed"
echo "• Captures screenshots automatically"
echo "• Adds screenshots to the commit"
echo ""
echo "🛠  To disable the hook temporarily:"
echo "git commit --no-verify"
echo ""
echo "🗑  To remove the hook:"
echo "rm $PRE_COMMIT_HOOK"