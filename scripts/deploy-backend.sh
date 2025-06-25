#!/bin/bash
# Deploy backend to Vercel

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Backend to Vercel...${NC}"

# Navigate to backend directory
cd backend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    npm install
fi

# Check if user is logged in to Vercel
if ! vercel whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Please log in to Vercel:${NC}"
    vercel login
fi

# Deploy to production
echo -e "${BLUE}🌐 Deploying to production...${NC}"
vercel --prod

echo -e "${GREEN}✅ Backend deployed successfully!${NC}"
echo -e "${YELLOW}⚠️  Remember to update the backend URL in ios/PlaidFinal/Config.swift if it changed${NC}"
echo -e "${BLUE}💡 To view logs: vercel logs --follow${NC}" 