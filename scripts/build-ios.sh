#!/bin/bash
# Build and run PlaidFinal iOS app

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building PlaidFinal iOS App...${NC}"

# Navigate to iOS directory
cd ios

# Resolve packages
echo -e "${BLUE}📦 Resolving Swift packages...${NC}"
swift package resolve

# Build the app
echo -e "${BLUE}🏗 Building for iPhone 16 Pro...${NC}"
xcodebuild -scheme PlaidFinal \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  build

# Boot simulator if not already running
echo -e "${BLUE}📱 Booting simulator...${NC}"
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true

# Open Simulator app
open -a Simulator

# Wait for simulator to boot
sleep 3

# Find the app bundle
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "PlaidFinal.app" | grep Debug-iphonesimulator | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Error: Could not find built app${NC}"
    exit 1
fi

# Install the app
echo -e "${BLUE}📲 Installing app...${NC}"
xcrun simctl install booted "$APP_PATH"

# Launch the app
echo -e "${BLUE}🚀 Launching PlaidFinal...${NC}"
xcrun simctl launch booted com.plaidfinal.app

echo -e "${GREEN}✅ App launched successfully!${NC}"
echo -e "${BLUE}💡 Tip: To view logs, run: ./scripts/view-logs.sh${NC}" 