#!/bin/bash

# Workflow Validation Script
# Validates GitHub Actions workflows before committing

set -e

echo "🔍 Validating GitHub Actions Workflows..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required for validation${NC}"
    exit 1
fi

# Install PyYAML if not available
python3 -c "import yaml" 2>/dev/null || pip install pyyaml

echo ""
echo "📋 Checking workflow files..."

# Validate each workflow file
for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        echo -n "  Checking $(basename $workflow)... "
        
        # Check YAML syntax
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ YAML syntax error${NC}"
            ((ERRORS++))
            python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>&1
        fi
        
        # Check for common issues
        if grep -q "secrets\\.GITHUB_TOKEN" "$workflow"; then
            # Check if permissions are set
            if ! grep -q "permissions:" "$workflow"; then
                echo -e "  ${YELLOW}⚠ Warning: Using GITHUB_TOKEN without explicit permissions${NC}"
                ((WARNINGS++))
            fi
        fi
        
        # Check for deprecated actions
        if grep -q "actions/checkout@v[12]" "$workflow"; then
            echo -e "  ${YELLOW}⚠ Warning: Using deprecated checkout action version${NC}"
            ((WARNINGS++))
        fi
        
        # Check for hardcoded values that should be secrets
        if grep -E "api[_-]?key.*[:=].*['\"]" "$workflow" | grep -v "secrets\\."; then
            echo -e "  ${YELLOW}⚠ Warning: Possible hardcoded API key${NC}"
            ((WARNINGS++))
        fi
    fi
done

echo ""
echo "📋 Checking action files..."

# Validate custom actions
for action in .github/actions/*/action.yml; do
    if [ -f "$action" ]; then
        echo -n "  Checking $(dirname $action | xargs basename)... "
        
        # Check YAML syntax
        if python3 -c "import yaml; yaml.safe_load(open('$action'))" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            
            # Validate action metadata
            python3 << EOF
import yaml
with open('$action') as f:
    action = yaml.safe_load(f)
    
required_fields = ['name', 'description', 'runs']
missing = [f for f in required_fields if f not in action]
if missing:
    print("  ${YELLOW}⚠ Warning: Missing required fields: " + ", ".join(missing) + "${NC}")
EOF
        else
            echo -e "${RED}✗ YAML syntax error${NC}"
            ((ERRORS++))
        fi
    fi
done

echo ""
echo "📋 Checking configuration files..."

# Validate dependabot.yml
if [ -f ".github/dependabot.yml" ]; then
    echo -n "  Checking dependabot.yml... "
    if python3 -c "import yaml; yaml.safe_load(open('.github/dependabot.yml'))" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ YAML syntax error${NC}"
        ((ERRORS++))
    fi
fi

# Validate labeler configurations
for labeler in .github/labeler.yml .github/pr-labeler.yml .github/issue-labeler.yml; do
    if [ -f "$labeler" ]; then
        echo -n "  Checking $(basename $labeler)... "
        if python3 -c "import yaml; yaml.safe_load(open('$labeler'))" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ YAML syntax error${NC}"
            ((ERRORS++))
        fi
    fi
done

echo ""
echo "📋 Checking for required secrets..."

# Extract secrets from workflows
SECRETS=$(grep -h "secrets\\..*" .github/workflows/*.yml | grep -v "GITHUB_TOKEN" | sed 's/.*secrets\.\([A-Z_]*\).*/\1/' | sort -u)

if [ -n "$SECRETS" ]; then
    echo "  Required secrets found in workflows:"
    for secret in $SECRETS; do
        echo "    - $secret"
    done
    echo ""
    echo "  ${YELLOW}ℹ Add these secrets in repository settings:${NC}"
    echo "    Repository → Settings → Secrets and variables → Actions"
else
    echo "  No additional secrets required (beyond GITHUB_TOKEN)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ No errors found${NC}"
else
    echo -e "${RED}✗ Found $ERRORS error(s)${NC}"
fi

if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ No warnings${NC}"
else
    echo -e "${YELLOW}⚠ Found $WARNINGS warning(s)${NC}"
fi

echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Validation failed. Please fix the errors above.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All workflows validated successfully!${NC}"
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Note: Please review the warnings above.${NC}"
    fi
    
    exit 0
fi
