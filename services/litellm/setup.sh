#!/bin/bash

# LiteLLM Proxy Setup Script
# This script helps set up the LiteLLM proxy on a new machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}LiteLLM Proxy Setup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ -f .env ]; then
    echo -e "${YELLOW}Warning: .env file already exists${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing .env file"
        ENV_EXISTS=true
    fi
fi

if [ -z "$ENV_EXISTS" ]; then
    echo -e "${GREEN}Creating .env file from template...${NC}"
    cp .env.example .env
    
    # Generate secure keys
    MASTER_KEY="sk-$(openssl rand -hex 32)"
    UI_PASSWORD=$(openssl rand -base64 16)
    POSTGRES_PASSWORD=$(openssl rand -base64 16)
    
    # Update .env with generated values
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|LITELLM_MASTER_KEY=.*|LITELLM_MASTER_KEY=$MASTER_KEY|g" .env
        sed -i '' "s|LITELLM_UI_PASSWORD=.*|LITELLM_UI_PASSWORD=$UI_PASSWORD|g" .env
        sed -i '' "s|POSTGRES_PASSWORD:-litellm_password}|POSTGRES_PASSWORD:-$POSTGRES_PASSWORD}|g" .env
    else
        # Linux
        sed -i "s|LITELLM_MASTER_KEY=.*|LITELLM_MASTER_KEY=$MASTER_KEY|g" .env
        sed -i "s|LITELLM_UI_PASSWORD=.*|LITELLM_UI_PASSWORD=$UI_PASSWORD|g" .env
        sed -i "s|POSTGRES_PASSWORD:-litellm_password}|POSTGRES_PASSWORD:-$POSTGRES_PASSWORD}|g" .env
    fi
    
    echo -e "${GREEN}✓${NC} Generated secure credentials"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Save these credentials!${NC}"
    echo "Master Key: $MASTER_KEY"
    echo "UI Username: admin"
    echo "UI Password: $UI_PASSWORD"
    echo ""
    echo "These have been saved to .env file"
    echo ""
fi

# Prompt for API keys
echo -e "${YELLOW}API Key Configuration${NC}"
echo "You need at least one LLM provider API key."
echo ""

read -p "Do you have an OpenAI API key? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your OpenAI API key: " OPENAI_KEY
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_KEY|g" .env
    else
        sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_KEY|g" .env
    fi
    echo -e "${GREEN}✓${NC} OpenAI API key configured"
fi

read -p "Do you have an Anthropic API key? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Anthropic API key: " ANTHROPIC_KEY
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=$ANTHROPIC_KEY|g" .env
    else
        sed -i "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=$ANTHROPIC_KEY|g" .env
    fi
    echo -e "${GREEN}✓${NC} Anthropic API key configured"
fi

read -p "Do you have a Google Gemini API key? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Gemini API key: " GEMINI_KEY
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|GEMINI_API_KEY=.*|GEMINI_API_KEY=$GEMINI_KEY|g" .env
    else
        sed -i "s|GEMINI_API_KEY=.*|GEMINI_API_KEY=$GEMINI_KEY|g" .env
    fi
    echo -e "${GREEN}✓${NC} Gemini API key configured"
fi

echo ""
echo -e "${GREEN}Starting LiteLLM services...${NC}"
docker-compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓${NC} Services are running"
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Setup Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "Access the LiteLLM proxy at:"
    echo "  - API: http://localhost:4000"
    echo "  - Web UI: http://localhost:4000/ui"
    echo "  - Health: http://localhost:4000/health"
    echo ""
    echo "View logs with: docker-compose logs -f"
    echo "Stop services with: docker-compose down"
    echo ""
    echo -e "${YELLOW}Don't forget to save your credentials from above!${NC}"
else
    echo -e "${RED}Error: Services failed to start${NC}"
    echo "Check logs with: docker-compose logs"
    exit 1
fi
