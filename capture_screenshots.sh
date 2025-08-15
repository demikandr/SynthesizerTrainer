#!/bin/bash

# Screenshot capture script for SynthesizerTrainer app
# This script captures screenshots of the app in various states for commit documentation

set -e

# Configuration
APP_NAME="SynthesizerTrainer"
BUNDLE_ID="com.synthesizertrainer.app"
SIMULATOR_NAME="iPhone 16"
SCREENSHOTS_DIR="screenshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "uncommitted")

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Function to wait for simulator to be ready
wait_for_simulator() {
    echo "Waiting for simulator to be ready..."
    local timeout=30
    local count=0
    
    while [ $count -lt $timeout ]; do
        if xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -q "Booted"; then
            echo "Simulator is ready"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    echo "Error: Simulator not ready after $timeout seconds"
    return 1
}

# Function to capture screenshot
capture_screenshot() {
    local suffix=$1
    local filename="${SCREENSHOTS_DIR}/${TIMESTAMP}_${COMMIT_HASH}_${suffix}.png"
    
    echo "Capturing screenshot: $filename"
    xcrun simctl io booted screenshot "$filename"
    
    if [ -f "$filename" ]; then
        echo "✅ Screenshot saved: $filename"
    else
        echo "❌ Failed to capture screenshot: $filename"
        return 1
    fi
}

# Function to scroll down in app (simulate swipe gesture)
scroll_down() {
    echo "Scrolling down in app..."
    # Simulate swipe up gesture to scroll down content
    # iPhone 16 screen: ~393x852 points, swipe from bottom-center to top-center
    xcrun simctl io booted touch 200 700 --duration 0.5 --drag-end 200 300
    sleep 1  # Wait for scroll animation to complete
}

# Main execution
echo "🚀 Starting screenshot capture for $APP_NAME"
echo "Timestamp: $TIMESTAMP"
echo "Commit: $COMMIT_HASH"

# Check if simulator is running, if not start it
if ! xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -q "Booted"; then
    echo "Starting simulator: $SIMULATOR_NAME"
    xcrun simctl boot "$SIMULATOR_NAME"
    sleep 5
fi

# Wait for simulator to be ready
wait_for_simulator

# Launch the app if not already running
echo "Launching app: $BUNDLE_ID"
xcrun simctl launch booted "$BUNDLE_ID" || {
    echo "❌ Failed to launch app. Make sure the app is installed on the simulator."
    echo "Run: xcrun simctl install booted ./path/to/your/app.app"
    exit 1
}

# Wait for app to fully load
sleep 3

# Capture initial screenshot
capture_screenshot "app_state"

# Note: Scroll functionality to be implemented later with proper gesture automation
# For now, capturing single screenshot provides visual commit documentation

# Optional: Interact with UI elements and capture more screenshots
# You can add more specific interactions here based on your app's UI

echo ""
echo "📸 Screenshot capture complete!"
echo "Screenshots saved to: $SCREENSHOTS_DIR/"
echo ""
echo "Files created:"
ls -la "$SCREENSHOTS_DIR"/*"$TIMESTAMP"* 2>/dev/null || echo "No new screenshots found"

echo ""
echo "💡 To include these screenshots in your commit:"
echo "git add $SCREENSHOTS_DIR/"
echo "git commit -m \"Your commit message with visual documentation\""