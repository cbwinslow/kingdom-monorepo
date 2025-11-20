# CI/CD Testing Guide

This guide explains how to test the CI/CD workflows, actions, and automation before and after deployment.

## 🧪 Pre-Deployment Testing

### 1. Validate Workflow Syntax

Before committing workflows, validate their syntax:

```bash
# Run validation script
./.github/scripts/validate-workflows.sh
```

This checks:
- ✅ YAML syntax correctness
- ✅ Required fields in actions
- ✅ Deprecated action versions
- ✅ Missing permissions
- ✅ Required secrets

### 2. Local Workflow Testing with `act`

Install and use `act` to test workflows locally:

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# List available workflows
act -l

# Test CI workflow
act pull_request -j lint-node

# Test with secrets
act -j gemini-review -s GEMINI_API_KEY=your-test-key

# Test specific job
act -j build

# Dry run (shows what would happen)
act -n
```

### 3. YAML Linting

Use yamllint for additional validation:

```bash
# Install yamllint
pip install yamllint

# Lint all workflow files
yamllint .github/workflows/*.yml

# Lint with custom config
yamllint -d relaxed .github/workflows/
```

### 4. Action Testing

Test custom actions locally:

```bash
# Navigate to action directory
cd .github/actions/gemini-code-review

# Set up test environment
export GEMINI_API_KEY=test-key
export GITHUB_TOKEN=test-token
export PR_NUMBER=1
export MODEL=gemini-pro
export GITHUB_REPOSITORY=owner/repo

# Install dependencies
npm init -y
npm install @google/generative-ai @octokit/rest

# Run the script
node scripts/review.js
```

## 🚀 Post-Deployment Testing

### 1. Create Test Pull Request

Create a small test PR to trigger workflows:

```bash
# Create test branch
git checkout -b test/ci-workflows

# Make a small change
echo "# Test" >> TEST.md

# Commit and push
git add TEST.md
git commit -m "test: verify CI/CD workflows"
git push origin test/ci-workflows

# Create PR
gh pr create --title "Test: CI/CD Workflows" --body "Testing automated workflows"
```

### 2. Verify Workflow Execution

Check that workflows run correctly:

```bash
# List recent workflow runs
gh run list --limit 10

# View specific run
gh run view <run-id>

# Watch workflow in real-time
gh run watch

# Download logs for debugging
gh run download <run-id>
```

### 3. Test Auto-Labeling

Verify that labels are applied automatically:

```bash
# Check PR labels
gh pr view <pr-number> --json labels

# Expected labels based on changes:
# - size/* (based on lines changed)
# - area/* (based on files changed)
# - type/* (based on branch name)
```

### 4. Test AI Code Review

Verify AI review functionality:

1. Ensure `GEMINI_API_KEY` is set in repository secrets
2. Open a test PR with code changes
3. Check PR comments for AI review within 5-10 minutes
4. Verify review includes:
   - Summary of changes
   - Potential issues
   - Security concerns
   - Performance considerations
   - Code quality suggestions

### 5. Test Security Scanning

Verify security workflows:

```bash
# Check CodeQL results
gh api repos/:owner/:repo/code-scanning/alerts

# Check Dependabot alerts
gh api repos/:owner/:repo/dependabot/alerts

# Check secret scanning
gh api repos/:owner/:repo/secret-scanning/alerts
```

### 6. Test Dependabot

Verify Dependabot is working:

```bash
# Check Dependabot status
gh api repos/:owner/:repo/automated-security-fixes

# List Dependabot PRs
gh pr list --author "dependabot[bot]"

# Test auto-merge on Dependabot PR
gh pr edit <pr-number> --add-label "auto-merge"
```

### 7. Test Project Automation

Verify project board integration:

```bash
# Check if PR was added to project
gh pr view <pr-number> --json projectItems

# Verify issue linking
gh pr view <pr-number> --json body | grep -i "fixes\|closes"
```

## 📊 Monitoring and Validation

### Workflow Status Checks

Monitor workflow health:

```bash
# View workflow runs summary
gh run list --json conclusion,name,status

# Count failed runs
gh run list --json conclusion | jq '[.[] | select(.conclusion == "failure")] | length'

# Get failure rate
gh run list --json conclusion | jq -r '
  (map(select(.conclusion == "failure")) | length) as $failed |
  (length) as $total |
  ($failed / $total * 100 | floor) as $rate |
  "Failure rate: \($rate)%"
'
```

### Performance Metrics

Track workflow performance:

```bash
# Average run time
gh run list --json name,createdAt,updatedAt -q '
  .[] | 
  select(.name == "CI") | 
  {
    name: .name,
    duration: ((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601))
  }
' | jq -s 'map(.duration) | add / length'

# Workflow timing breakdown
gh run view <run-id> --json jobs -q '.jobs[] | {name: .name, duration: .conclusion}'
```

### Cost Analysis

Monitor GitHub Actions usage:

```bash
# Check Actions usage (requires admin access)
gh api repos/:owner/:repo/actions/billing/usage

# View workflow runs in last month
gh run list --created ">$(date -d '30 days ago' +%Y-%m-%d)"
```

## 🔍 Debugging Failed Workflows

### Step-by-Step Debugging

1. **Identify the failure**
   ```bash
   gh run list --status failure
   gh run view <run-id>
   ```

2. **Download logs**
   ```bash
   gh run download <run-id>
   # Logs will be in a directory named after the run
   ```

3. **Analyze logs**
   ```bash
   # Search for errors
   grep -r "Error\|ERROR\|Failed" run-*
   
   # Find specific job logs
   cat run-*/CI/1_Build.txt
   ```

4. **Check workflow syntax**
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
   ```

5. **Verify secrets**
   ```bash
   # List required secrets
   grep -h "secrets\." .github/workflows/*.yml | sort -u
   ```

### Common Issues and Solutions

#### Issue: Workflow doesn't trigger

**Possible causes:**
- Branch name doesn't match trigger pattern
- File changes don't match path filters
- Workflow is disabled

**Solution:**
```bash
# Check workflow configuration
cat .github/workflows/ci.yml | grep -A 10 "on:"

# Manually trigger workflow
gh workflow run ci.yml
```

#### Issue: Job fails with "Resource not accessible"

**Possible causes:**
- Missing or incorrect permissions
- Invalid secrets

**Solution:**
```yaml
# Add permissions to workflow
permissions:
  contents: read
  pull-requests: write
```

#### Issue: Action not found

**Possible causes:**
- Typo in action name
- Action version doesn't exist
- Custom action path incorrect

**Solution:**
```bash
# Verify custom action exists
ls -la .github/actions/

# Check action syntax
python3 -c "import yaml; yaml.safe_load(open('.github/actions/my-action/action.yml'))"
```

#### Issue: Timeout

**Possible causes:**
- Long-running processes
- Inefficient builds
- Network issues

**Solution:**
```yaml
# Add timeout
jobs:
  build:
    timeout-minutes: 30
```

## 🧰 Testing Tools

### Required Tools

```bash
# GitHub CLI
brew install gh

# act (local workflow testing)
brew install act

# YAML linter
pip install yamllint

# JSON processor
brew install jq

# Python YAML parser
pip install pyyaml
```

### Optional Tools

```bash
# actionlint (workflow linter)
brew install actionlint

# ShellCheck (shell script linter)
brew install shellcheck

# hadolint (Dockerfile linter)
brew install hadolint
```

## 📋 Test Checklist

Use this checklist to verify all CI/CD components:

### Before Merging

- [ ] All workflow YAML files validated
- [ ] Custom actions validated
- [ ] Configuration files validated
- [ ] Required secrets documented
- [ ] Local testing completed with `act`
- [ ] YAML linting passed

### After Merging

- [ ] CI workflow runs successfully
- [ ] Security scanning completes
- [ ] Auto-labeling works
- [ ] AI code review posts comments
- [ ] Dependabot PRs created
- [ ] Project automation works
- [ ] Documentation builds
- [ ] Docker images build (if applicable)
- [ ] No unexpected failures
- [ ] Workflow timing acceptable

### Weekly Monitoring

- [ ] Review workflow failure rate
- [ ] Check security alerts
- [ ] Update action versions
- [ ] Review Dependabot PRs
- [ ] Clean up stale workflows
- [ ] Monitor Actions usage

## 📚 Test Scenarios

### Scenario 1: Feature PR

1. Create feature branch
2. Make code changes
3. Open PR
4. Verify:
   - CI runs
   - Linting passes
   - Tests run
   - Security scan completes
   - Labels applied
   - AI review posted
   - Reviewers assigned

### Scenario 2: Dependency Update

1. Dependabot creates PR
2. Verify:
   - Dependency review runs
   - Security scan completes
   - `dependencies` label applied
   - Auto-merge enabled (if configured)
   - Tests pass

### Scenario 3: Documentation Change

1. Update documentation
2. Verify:
   - Markdown linting runs
   - Link checker runs
   - Spell check runs
   - Documentation builds
   - Site deploys (if configured)

### Scenario 4: Security Fix

1. Create hotfix branch
2. Fix security issue
3. Verify:
   - Security scan confirms fix
   - Critical label applied
   - Fast-tracked review
   - Auto-assigned to security team

## 🎯 Performance Benchmarks

Expected workflow times:

- **CI (lint + test)**: 2-5 minutes
- **Security scanning**: 5-10 minutes
- **Docker build**: 5-15 minutes
- **AI code review**: 2-5 minutes
- **Documentation build**: 1-3 minutes
- **Auto-labeling**: < 30 seconds

If workflows exceed these times significantly, investigate:
- Caching effectiveness
- Dependency installation time
- Test suite efficiency
- Network issues

## 🐛 Reporting Issues

If you find issues with workflows:

1. **Collect information:**
   - Workflow run URL
   - Error messages
   - Log files
   - Expected vs actual behavior

2. **Create issue:**
   ```bash
   gh issue create \
     --title "CI: Workflow failure in <workflow-name>" \
     --label "ci/cd" \
     --body "..."
   ```

3. **Include:**
   - Steps to reproduce
   - Workflow run link
   - Error logs
   - Environment details

## ✅ Success Criteria

A successful CI/CD implementation should:

- ✅ All workflows run without errors
- ✅ Security scans complete successfully
- ✅ Auto-labeling works consistently
- ✅ AI reviews provide useful feedback
- ✅ Dependabot PRs created regularly
- ✅ Project automation functions correctly
- ✅ Documentation builds and deploys
- ✅ No false positives in security scans
- ✅ Workflow times within benchmarks
- ✅ No manual intervention required for standard PRs

---

*Last updated: 2024*
*For issues or questions, open a GitHub issue.*
