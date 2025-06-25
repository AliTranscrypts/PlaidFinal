#!/bin/bash
# Quick start script for PlaidFinal

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 PlaidFinal Quick Start${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed. Please install from App Store.${NC}"
    exit 1
fi

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install from https://nodejs.org${NC}"
    exit 1
fi

# Check for Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}⚠️  Vercel CLI not installed. Installing...${NC}"
    npm install -g vercel
fi

echo -e "${GREEN}✅ All prerequisites met!${NC}"
echo ""

# Backend setup
echo -e "${BLUE}🔧 Setting up backend...${NC}"
cd backend
if [ ! -d "node_modules" ]; then
    npm install
fi
cd ..
echo -e "${GREEN}✅ Backend ready!${NC}"
echo ""

# iOS setup
echo -e "${BLUE}📱 Setting up iOS app...${NC}"
cd ios
swift package resolve
cd ..
echo -e "${GREEN}✅ iOS app ready!${NC}"
echo ""

# Instructions
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Deploy backend:     ${YELLOW}./scripts/deploy-backend.sh${NC}"
echo "2. Build & run iOS:    ${YELLOW}./scripts/build-ios.sh${NC}"
echo "3. View logs:          ${YELLOW}./scripts/view-logs.sh${NC}"
echo ""
echo -e "${BLUE}📖 For detailed instructions, see README.md${NC}" 