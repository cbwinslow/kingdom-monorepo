# CI/CD Setup Guide

Complete guide for setting up and configuring the CI/CD infrastructure for Kingdom Monorepo.

## 🚀 Quick Start

### Prerequisites

- GitHub repository admin access
- Node.js 18+ installed locally
- Python 3.11+ installed locally
- Docker (optional, for container workflows)

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/cbwinslow/kingdom-monorepo.git
   cd kingdom-monorepo
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up AI agents** (optional but recommended)
   ```bash
   cd agents
   ./scripts/install_agents.sh
   source venv/bin/activate
   ```

## 🔐 Required Secrets

Configure these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

### Essential Secrets

| Secret Name | Purpose | How to Get |
|------------|---------|------------|
| `GITHUB_TOKEN` | GitHub API access | Automatically provided by GitHub Actions |
| `GEMINI_API_KEY` | Google Gemini AI for code review | [Get from Google AI Studio](https://makersuite.google.com/app/apikey) |

### Optional Secrets

| Secret Name | Purpose | How to Get |
|------------|---------|------------|
| `OPENAI_API_KEY` | OpenAI GPT models | [OpenAI API Keys](https://platform.openai.com/api-keys) |
| `ANTHROPIC_API_KEY` | Claude AI models | [Anthropic Console](https://console.anthropic.com/) |
| `SNYK_TOKEN` | Security scanning | [Snyk Account](https://app.snyk.io/account) |
| `SONAR_TOKEN` | Code quality analysis | [SonarCloud](https://sonarcloud.io/) |
| `SONAR_HOST_URL` | SonarQube server URL | Your SonarQube instance |
| `CODECOV_TOKEN` | Code coverage reporting | [Codecov](https://codecov.io/) |

### Setting Secrets

```bash
# Using GitHub CLI
gh secret set GEMINI_API_KEY

# Or via GitHub web interface:
# Repository → Settings → Secrets and variables → Actions → New repository secret
```

## ⚙️ Workflow Configuration

### Enable/Disable Workflows

All workflows are enabled by default. To disable a workflow:

1. Go to `.github/workflows/[workflow-name].yml`
2. Comment out the triggers or delete the file
3. Commit and push

### Workflow Triggers

Most workflows are triggered on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual dispatch (via GitHub Actions UI)
- Schedule (for periodic tasks)

### Customizing Workflows

Each workflow can be customized by editing the YAML file:

```yaml
# Example: Change CI to run only on main branch
on:
  push:
    branches: [ main ]  # Remove 'develop' if not needed
```

## 🛡️ Branch Protection

### Recommended Settings for Main Branch

1. Navigate to: Settings → Branches → Add rule

2. **Branch name pattern**: `main`

3. **Enable these protections**:
   - ✅ Require a pull request before merging
   - ✅ Require approvals: 1
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require review from Code Owners
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Require conversation resolution before merging
   - ❌ Do not allow bypassing the above settings (except for emergencies)
   - ✅ Restrict who can push to matching branches (only admins)

4. **Required status checks**:
   - `CI / Lint Node.js`
   - `CI / Test Node.js`
   - `CI / Build`
   - `Security Scanning / CodeQL Analysis`

### Setting Up via GitHub CLI

```bash
# Enable branch protection
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true
```

## 🤖 AI Agent Configuration

### Google Gemini Setup

1. **Get API Key**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Copy the key

2. **Add to GitHub Secrets**
   ```bash
   gh secret set GEMINI_API_KEY
   # Paste your API key when prompted
   ```

3. **Test the integration**
   - Open a test PR
   - The Gemini review should run automatically
   - Check the PR comments for AI review

### OpenAI/ChatGPT Setup (Optional)

1. **Get API Key**
   - Go to [OpenAI API Keys](https://platform.openai.com/api-keys)
   - Create a new secret key
   - Copy the key

2. **Add to GitHub Secrets**
   ```bash
   gh secret set OPENAI_API_KEY
   ```

3. **Configure model** (in `.github/workflows/ai-code-review.yml`):
   ```yaml
   - name: OpenAI Code Review
     uses: anc95/ChatGPT-CodeReview@main
     env:
       OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
     with:
       model: gpt-4  # or gpt-3.5-turbo
   ```

### Local Agent Testing

```bash
# Activate virtual environment
cd agents
source venv/bin/activate

# Set up environment variables
cp .env.example .env
# Edit .env and add your API keys

# Test code review
python scripts/run_agent.py review-code path/to/file.py

# Test PR review
python scripts/run_agent.py review-pr 123 --repo owner/repo
```

## 📋 Dependabot Configuration

Dependabot is configured to:
- Check npm dependencies weekly
- Check pip dependencies weekly
- Check GitHub Actions weekly
- Check Docker base images weekly
- Auto-create PRs with `auto-merge` label
- Auto-assign to repository owner

### Customize Dependabot

Edit `.github/dependabot.yml`:

```yaml
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"  # Change from weekly to daily
    open-pull-requests-limit: 20  # Increase limit
```

## 🏷️ Auto-Labeling Configuration

### Path-Based Labels

Edit `.github/labeler.yml` to customize which labels are applied based on file paths:

```yaml
'my-custom-label':
  - 'my-custom-path/**/*'
```

### Size-Based Labels

PR size labels are automatically applied:
- `size/xs`: 0-10 lines
- `size/s`: 11-100 lines
- `size/m`: 101-500 lines
- `size/l`: 501-1000 lines
- `size/xl`: 1000+ lines

Customize in `.github/workflows/auto-label.yml`.

### Branch-Based Labels

Edit `.github/pr-labeler.yml`:

```yaml
'my-feature-label': 'feature/my-*'
```

## 🔄 Auto-Merge Configuration

Auto-merge is enabled for PRs with:
- All required checks passing
- Required approvals received
- No merge conflicts
- `auto-merge` label applied
- Not a draft PR

### Enable for a PR

```bash
# Add auto-merge label
gh pr edit 123 --add-label "auto-merge"

# Or manually in GitHub UI
```

### Disable Auto-Merge

To disable auto-merge globally, delete or comment out `.github/workflows/auto-merge.yml`.

## 📊 Project Board Automation

### Setup GitHub Projects

1. **Create a project**
   - Go to repository Projects tab
   - Create a new Project (V2)
   - Note the project URL

2. **Update workflow**
   Edit `.github/workflows/project-automation.yml`:
   ```yaml
   - name: Add to project
     uses: actions/add-to-project@v0.5.0
     with:
       project-url: YOUR_PROJECT_URL_HERE
   ```

3. **Custom project fields**
   Projects V2 supports custom fields that can be automated via API.

## 🐳 Docker Configuration

### Registry Setup

By default, images are pushed to GitHub Container Registry (ghcr.io).

**To use Docker Hub instead**:

1. Add secrets:
   ```bash
   gh secret set DOCKERHUB_USERNAME
   gh secret set DOCKERHUB_TOKEN
   ```

2. Update `.github/workflows/docker-publish.yml`:
   ```yaml
   env:
     REGISTRY: docker.io
     IMAGE_NAME: your-dockerhub-username/${{ github.repository }}
   ```

### Multi-Architecture Builds

Currently configured for:
- linux/amd64
- linux/arm64

To add more platforms, edit `docker-publish.yml`:
```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

## 📚 Documentation Site

### Enable GitHub Pages

1. Go to: Settings → Pages
2. Source: GitHub Actions
3. The documentation site will be built and deployed automatically

### Customize Documentation

Edit `mkdocs.yml` (created by workflow) or modify `.github/workflows/documentation.yml`.

## 🔍 Security Scanning

### CodeQL

- Automatically scans JavaScript and Python
- Runs on every push to main/develop
- Runs on all PRs
- Weekly scheduled scan

**To add more languages**:
Edit `.github/workflows/security.yml`:
```yaml
matrix:
  language: [ 'javascript', 'python', 'java', 'go' ]
```

### Secret Scanning

**Enable push protection**:
1. Settings → Code security and analysis
2. Enable "Push protection for secret scanning"

### Dependency Scanning

Uses multiple tools:
- GitHub Dependency Review
- npm audit
- pip safety check
- Trivy
- OSV Scanner

## 🎯 Custom Actions

### Using Custom Actions

```yaml
# In your workflow
- name: Run custom action
  uses: ./.github/actions/gemini-code-review
  with:
    gemini-api-key: ${{ secrets.GEMINI_API_KEY }}
    pr-number: ${{ github.event.pull_request.number }}
```

### Creating New Actions

1. Create directory: `.github/actions/my-action/`
2. Create `action.yml` with metadata
3. Implement action logic
4. Use in workflows

## 🧪 Testing Workflows Locally

### Using `act`

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test a workflow
act -j test-node

# Test with secrets
act -j gemini-review -s GEMINI_API_KEY=your-key
```

### Validation

```bash
# Validate workflow syntax
npm install -g yaml-lint
yaml-lint .github/workflows/*.yml

# Or use GitHub CLI
gh workflow view
```

## 📈 Monitoring and Debugging

### View Workflow Runs

```bash
# List recent workflow runs
gh run list

# View specific run
gh run view RUN_ID

# Download logs
gh run download RUN_ID
```

### Common Issues

#### Workflow not triggering
- Check branch name in `on` section
- Verify file paths in path filters
- Check if workflows are enabled

#### Action failing
- Check secrets are set correctly
- Review action logs in GitHub UI
- Test locally with `act`

#### Rate limits
- GitHub Actions: 1000 API requests per hour per repository
- External APIs: Varies by service
- Use caching to reduce API calls

## 🔄 Maintenance

### Regular Tasks

**Weekly**:
- Review Dependabot PRs
- Check security alerts
- Review workflow run times

**Monthly**:
- Update action versions
- Review and close stale issues/PRs
- Clean up old workflow runs

**Quarterly**:
- Review and update documentation
- Evaluate new GitHub Actions features
- Optimize workflow performance

### Updating Actions

```bash
# Find actions in use
grep -r "uses:" .github/workflows/

# Update to latest version
# Change: uses: actions/checkout@v3
# To: uses: actions/checkout@v4
```

## 📞 Support and Resources

### Documentation Links

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [CrewAI Docs](https://docs.crewai.com/)
- [LangChain Docs](https://python.langchain.com/)

### Getting Help

1. Check workflow logs
2. Review error messages
3. Search GitHub Actions marketplace
4. Open an issue in the repository
5. Check GitHub Community forums

## 🎓 Best Practices

### Workflow Design

1. **Keep workflows focused**: One workflow per concern
2. **Use caching**: Cache dependencies to speed up builds
3. **Fail fast**: Run quick checks first
4. **Parallel execution**: Run independent jobs in parallel
5. **Conditional execution**: Skip unnecessary jobs

### Security

1. **Minimize secrets**: Only use what's necessary
2. **Scope tokens**: Use fine-grained tokens when possible
3. **Review dependencies**: Check action sources before using
4. **Enable security features**: Dependabot, CodeQL, secret scanning
5. **Regular updates**: Keep actions and dependencies current

### Performance

1. **Cache aggressively**: Dependencies, build artifacts
2. **Optimize Docker builds**: Multi-stage builds, layer caching
3. **Selective testing**: Run only affected tests when possible
4. **Timeout limits**: Set reasonable timeouts
5. **Resource allocation**: Choose appropriate runner sizes

## ✅ Post-Setup Checklist

- [ ] All required secrets configured
- [ ] Branch protection enabled for main
- [ ] Dependabot enabled and configured
- [ ] AI code review tested with sample PR
- [ ] Documentation site deployed
- [ ] Team members added to CODEOWNERS
- [ ] Project board created and linked
- [ ] Notification preferences set
- [ ] Custom labels created
- [ ] Workflow runs verified
- [ ] Security scanning enabled
- [ ] Docker registry configured (if needed)
- [ ] Release workflow tested
- [ ] Monitoring set up

## 🎉 You're All Set!

Your CI/CD infrastructure is now fully configured. Create a PR to see all the automation in action!

For questions or issues, open an issue in the repository or consult the documentation links above.

---

*Last updated: 2024*
*For the latest updates, check the repository.*
