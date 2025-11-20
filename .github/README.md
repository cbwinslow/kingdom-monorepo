# GitHub CI/CD Infrastructure

Comprehensive CI/CD infrastructure for the Kingdom Monorepo, including workflows, actions, AI agents, and automation.

## 📚 Documentation

### Getting Started
- **[Setup Guide](SETUP.md)** - Complete setup instructions for CI/CD infrastructure
- **[Testing Guide](TESTING.md)** - How to test workflows and actions
- **[Rulesets Documentation](RULESETS.md)** - Branch protection and repository rules

### Quick Links
- [Workflows](#workflows)
- [Custom Actions](#custom-actions)
- [Templates](#templates)
- [Configuration](#configuration)
- [AI Agents](#ai-agents)

## 🔄 Workflows

### Core CI/CD

#### CI Workflow (`workflows/ci.yml`)
Comprehensive continuous integration with:
- **Change Detection**: Intelligent detection of modified components
- **Parallel Testing**: Node.js and Python testing in parallel
- **Multi-version Testing**: Tests across Node 18/20 and Python 3.11/3.12
- **Build Verification**: Ensures code builds successfully
- **Docker Validation**: Validates Dockerfiles

**Triggers**: Push to main/develop, Pull requests
**Runtime**: ~5-10 minutes

#### Security Workflow (`workflows/security.yml`)
Multi-layered security scanning:
- **CodeQL Analysis**: JavaScript and Python code analysis
- **Secret Scanning**: Gitleaks and TruffleHog
- **Dependency Review**: GitHub Dependency Review action
- **Vulnerability Scanning**: npm audit, pip safety, Trivy, OSV Scanner
- **Docker Security**: Dockerfile and image scanning

**Triggers**: Push to main/develop, Pull requests, Weekly schedule
**Runtime**: ~10-15 minutes

### Automation

#### Auto-Label (`workflows/auto-label.yml`)
Automatic labeling based on:
- **File Changes**: Labels by modified paths (apps/, libs/, docs/, etc.)
- **PR Size**: xs/small/medium/large/xl based on lines changed
- **Branch Names**: feature/*, fix/*, docs/*, etc.
- **Issue Content**: Bug, feature, documentation, etc.

**Triggers**: PR opened/edited, Issue opened/edited

#### Auto-Merge (`workflows/auto-merge.yml`)
Smart auto-merge for approved PRs:
- **Approval Check**: Verifies required approvals
- **Status Checks**: All CI checks must pass
- **Conflict Detection**: No merge conflicts
- **Dependabot Support**: Auto-approve and merge Dependabot PRs

**Triggers**: PR events, Check suite completion

#### Project Automation (`workflows/project-automation.yml`)
Automates project management:
- **Add to Project**: Auto-adds issues/PRs to project boards
- **Status Updates**: Updates project item status based on labels
- **Issue Linking**: Links PRs to related issues
- **Reviewer Assignment**: Assigns reviewers based on CODEOWNERS
- **TODO Tracking**: Creates issues from TODO comments
- **Stale Management**: Handles stale issues and PRs

**Triggers**: Issue/PR events, Manual dispatch

### AI-Powered

#### AI Code Review (`workflows/ai-code-review.yml`)
Multi-AI code review system:
- **Google Gemini**: Primary AI reviewer
- **OpenAI GPT**: Secondary review (optional)
- **CodeRabbit**: Additional AI insights
- **Auto-Fix**: Automatic code corrections for common issues
- **Suggestions**: AI-generated improvement suggestions

**Triggers**: PR opened/synchronized
**Runtime**: ~5-10 minutes

### Quality & Documentation

#### Code Quality (`workflows/code-quality.yml`)
Comprehensive code quality analysis:
- **Complexity Analysis**: Cyclomatic complexity, maintainability index
- **Duplication Detection**: Code duplication checking
- **Coverage Reports**: Test coverage tracking
- **Dependency Analysis**: Unused dependencies, circular dependencies
- **Technical Debt**: TODO/FIXME tracking, debt scoring

**Triggers**: PR events, Push to main/develop, Weekly schedule

#### Documentation (`workflows/documentation.yml`)
Documentation validation and publishing:
- **Markdown Linting**: Consistent markdown formatting
- **Link Checking**: Validates all links in docs
- **Spell Checking**: Catches typos and spelling errors
- **API Doc Generation**: TypeDoc, JSDoc, Sphinx
- **Site Building**: MkDocs site generation
- **GitHub Pages**: Automatic deployment

**Triggers**: Changes to docs/ or *.md files, Push to main

### Deployment

#### Docker Publish (`workflows/docker-publish.yml`)
Automated container builds:
- **Multi-arch**: linux/amd64 and linux/arm64
- **Registry**: GitHub Container Registry (ghcr.io)
- **Caching**: Layer caching for faster builds
- **Security Scanning**: Trivy vulnerability scanning
- **Attestation**: Build provenance attestation

**Triggers**: Push to main/develop, Tag creation

#### Release Management (`workflows/release.yml`)
Automated release process:
- **Changelog Generation**: Auto-generated from commits
- **Artifact Building**: Multi-platform artifacts
- **Release Notes**: Formatted release documentation
- **Asset Upload**: Automatic artifact upload
- **Announcement**: Creates announcement issue

**Triggers**: Tag push (v*), Manual dispatch

## 🎬 Custom Actions

### Gemini Code Review (`actions/gemini-code-review/`)
Google Gemini AI-powered code review:
- Analyzes PR diff
- Provides comprehensive feedback
- Posts review as PR comment
- Adds 'ai-reviewed' label

**Usage**:
```yaml
- uses: ./.github/actions/gemini-code-review
  with:
    gemini-api-key: ${{ secrets.GEMINI_API_KEY }}
    pr-number: ${{ github.event.pull_request.number }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### AI Code Suggestions (`actions/ai-code-suggestions/`)
Provides automated improvement suggestions:
- Formatting improvements
- Code quality tips
- Performance suggestions
- Security recommendations

**Usage**:
```yaml
- uses: ./.github/actions/ai-code-suggestions
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    pr-number: ${{ github.event.pull_request.number }}
```

### AI Auto-Fix (`actions/ai-auto-fix/`)
Automatically fixes common issues:
- Removes unused imports
- Sorts imports
- Formats code (Black, Prettier)
- Fixes ESLint issues

**Usage**:
```yaml
- uses: ./.github/actions/ai-auto-fix
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    pr-number: ${{ github.event.pull_request.number }}
```

### Monorepo Change Detector (`actions/monorepo-change-detector/`)
Detects changed workspaces in monorepo:
- Identifies modified packages
- Outputs JSON array of changes
- Optimizes CI runs

**Usage**:
```yaml
- uses: ./.github/actions/monorepo-change-detector
  id: changes
- run: echo "Changed: ${{ steps.changes.outputs.changed-workspaces }}"
```

## 📋 Templates

### Issue Templates

#### Bug Report (`ISSUE_TEMPLATE/bug_report.yml`)
Structured bug report form with:
- Description
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Log output
- Additional context

#### Feature Request (`ISSUE_TEMPLATE/feature_request.yml`)
Feature suggestion form with:
- Problem statement
- Proposed solution
- Alternatives considered
- Priority level
- Affected areas

### Pull Request Template

Comprehensive PR template (`PULL_REQUEST_TEMPLATE/pull_request_template.md`):
- Change description
- Type of change
- Related issues
- Testing checklist
- Screenshots
- Review checklist

## ⚙️ Configuration

### Dependabot (`dependabot.yml`)
Automated dependency updates:
- **npm**: Weekly updates for JavaScript packages
- **pip**: Weekly updates for Python packages
- **GitHub Actions**: Weekly action version updates
- **Docker**: Base image updates
- **Auto-merge**: Automatically merges compatible updates

### Labelers

#### Path-based (`labeler.yml`)
Labels based on file paths:
- `area: apps` - Changes in apps/
- `area: libs` - Changes in libs/
- `lang: python` - Python files
- `lang: javascript` - JavaScript files
- `documentation` - Documentation changes

#### Branch-based (`pr-labeler.yml`)
Labels based on branch names:
- `feature/*` → `type: feature`
- `fix/*` → `type: bug`
- `docs/*` → `documentation`

#### Content-based (`issue-labeler.yml`)
Labels based on issue content:
- Keywords: bug, feature, question
- Security terms
- Performance indicators

### Code Ownership (`CODEOWNERS`)
Automatic reviewer assignment:
```
# CI/CD
/.github/ @cbwinslow

# Python code
*.py @cbwinslow

# Documentation
*.md @cbwinslow
```

## 🤖 AI Agents

Located in `../agents/`:

### Code Review Crew
Multi-agent code review system:
- **Senior Reviewer**: Overall code quality
- **Security Expert**: Security vulnerabilities
- **Performance Analyst**: Performance optimization
- **Test Engineer**: Test coverage
- **Tech Writer**: Documentation quality

### Configuration
- `configs/code_reviewer_agent.yml`
- `configs/pr_handler_agent.yml`

### Tools
- `tools/github_tools.py` - GitHub API integration
- Custom agent tools

### Prompts
- `prompts/code_review_prompts.md` - Review templates
- `prompts/instruction_sets.md` - Task instructions

See [Agents README](../agents/README.md) for details.

## 🔐 Required Secrets

Configure in Repository Settings → Secrets and variables → Actions:

### Essential
- `GITHUB_TOKEN` - Automatically provided
- `GEMINI_API_KEY` - Google Gemini AI

### Optional
- `OPENAI_API_KEY` - OpenAI GPT models
- `ANTHROPIC_API_KEY` - Claude AI
- `SNYK_TOKEN` - Snyk security scanning
- `SONAR_TOKEN` - SonarQube analysis
- `CODECOV_TOKEN` - Code coverage

## 🛠️ Maintenance

### Regular Tasks

**Weekly**:
- Review Dependabot PRs
- Check security alerts
- Monitor workflow success rates

**Monthly**:
- Update action versions
- Review stale issues/PRs
- Optimize workflow performance

**Quarterly**:
- Update documentation
- Review and update rulesets
- Evaluate new features

### Validation

Run validation script:
```bash
.github/scripts/validate-workflows.sh
```

## 📊 Monitoring

### Workflow Status
```bash
# List recent runs
gh run list --limit 20

# View specific run
gh run view <run-id>

# Watch in real-time
gh run watch
```

### Metrics
- Success rate
- Average run time
- Actions usage
- Security alerts

## 🚀 Getting Started

1. **Read the setup guide**: [SETUP.md](SETUP.md)
2. **Configure secrets**: Add required API keys
3. **Enable workflows**: Workflows run automatically
4. **Create test PR**: Verify everything works
5. **Review results**: Check workflow runs

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
- [CrewAI Documentation](https://docs.crewai.com/)

## 🎓 Best Practices

1. **Keep workflows focused** - One concern per workflow
2. **Use caching** - Speed up builds
3. **Run in parallel** - Independent jobs run simultaneously
4. **Fail fast** - Quick checks first
5. **Monitor costs** - Track Actions usage
6. **Update regularly** - Keep actions current
7. **Document changes** - Update docs with workflow changes

## 🐛 Troubleshooting

See [TESTING.md](TESTING.md) for:
- Common issues and solutions
- Debugging workflows
- Local testing
- Performance optimization

## 📞 Support

- **Documentation**: Check this README and related docs
- **Issues**: Open a GitHub issue
- **Validation**: Run `.github/scripts/validate-workflows.sh`
- **Testing**: See [TESTING.md](TESTING.md)

---

*Last updated: 2024*
*Part of Kingdom Monorepo CI/CD Infrastructure*
