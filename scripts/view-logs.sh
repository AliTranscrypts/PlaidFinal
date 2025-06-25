#!/bin/bash
# View PlaidFinal app logs

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Starting log stream for PlaidFinal...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Stream logs with colored output
xcrun simctl spawn booted log stream --predicate 'process == "PlaidFinal"' | \
grep -E "(🔵|❌|📤|📥|✅|Error|error|failed|Plaid|Supabase|Account|Connect|Success)" | \
while IFS= read -r line; do
    if [[ $line == *"Error"* ]] || [[ $line == *"error"* ]] || [[ $line == *"❌"* ]]; then
        echo -e "${RED}$line${NC}"
    elif [[ $line == *"Success"* ]] || [[ $line == *"✅"* ]]; then
        echo -e "${GREEN}$line${NC}"
    elif [[ $line == *"🔵"* ]] || [[ $line == *"📤"* ]] || [[ $line == *"📥"* ]]; then
        echo -e "${BLUE}$line${NC}"
    else
        echo "$line"
    fi
done 