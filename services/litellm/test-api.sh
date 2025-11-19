#!/bin/bash

# LiteLLM API Test Script
# Tests the proxy with various endpoints

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
LITELLM_URL=${LITELLM_URL:-http://localhost:4000}
LITELLM_API_KEY=${LITELLM_API_KEY:-$LITELLM_MASTER_KEY}

if [ -z "$LITELLM_API_KEY" ]; then
    echo -e "${RED}Error: LITELLM_API_KEY or LITELLM_MASTER_KEY must be set${NC}"
    echo "Run: export LITELLM_API_KEY=your-key"
    exit 1
fi

echo -e "${GREEN}Testing LiteLLM Proxy at $LITELLM_URL${NC}"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
if curl -s -f "$LITELLM_URL/health" > /dev/null; then
    echo -e "${GREEN}✓${NC} Health check passed"
else
    echo -e "${RED}✗${NC} Health check failed"
    exit 1
fi
echo ""

# Test 2: Model List
echo -e "${YELLOW}Test 2: Model List${NC}"
MODELS=$(curl -s "$LITELLM_URL/models" \
    -H "Authorization: Bearer $LITELLM_API_KEY")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Retrieved model list"
    echo "$MODELS" | jq -r '.data[].id' 2>/dev/null | head -5 || echo "$MODELS"
else
    echo -e "${RED}✗${NC} Failed to retrieve models"
fi
echo ""

# Test 3: Simple Chat Completion
echo -e "${YELLOW}Test 3: Chat Completion${NC}"
RESPONSE=$(curl -s -X POST "$LITELLM_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $LITELLM_API_KEY" \
    -d '{
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "user", "content": "Say hello in one word"}],
        "max_tokens": 10
    }')

if [ $? -eq 0 ]; then
    CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null)
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "null" ]; then
        echo -e "${GREEN}✓${NC} Chat completion successful"
        echo "Response: $CONTENT"
    else
        echo -e "${RED}✗${NC} Chat completion failed"
        echo "Response: $RESPONSE"
    fi
else
    echo -e "${RED}✗${NC} Request failed"
fi
echo ""

# Test 4: Streaming (if supported)
echo -e "${YELLOW}Test 4: Streaming${NC}"
echo -n "Testing streaming... "
curl -s -X POST "$LITELLM_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $LITELLM_API_KEY" \
    -d '{
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "user", "content": "Count to 3"}],
        "stream": true,
        "max_tokens": 20
    }' | head -5 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Streaming works"
else
    echo -e "${YELLOW}⚠${NC} Streaming test inconclusive"
fi
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Testing Complete!${NC}"
echo -e "${GREEN}================================${NC}"
