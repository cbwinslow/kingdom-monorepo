# Repository Rulesets Configuration

This document describes the recommended branch protection rules and rulesets for the repository.

## 🛡️ Branch Protection Rules

### Main Branch Protection

**Target:** `main` branch

#### Required Status Checks
- ✅ All CI checks must pass
- ✅ Security scans must complete
- ✅ CodeQL analysis must pass
- ✅ Docker builds must succeed (if applicable)

#### Pull Request Requirements
- **Require pull request before merging**: ✅ Enabled
- **Required approving reviews**: 1 (minimum)
- **Dismiss stale pull request approvals**: ✅ Enabled
- **Require review from Code Owners**: ✅ Enabled
- **Restrict who can dismiss reviews**: Admins only

#### Additional Restrictions
- **Require status checks to pass**: ✅ Enabled
- **Require branches to be up to date**: ✅ Enabled
- **Require signed commits**: ⚠️ Optional (recommended)
- **Require linear history**: ⚠️ Optional
- **Include administrators**: ❌ Disabled (for emergency fixes)
- **Allow force pushes**: ❌ Disabled
- **Allow deletions**: ❌ Disabled

### Develop Branch Protection

**Target:** `develop` branch

#### Required Status Checks
- ✅ All CI checks must pass
- ✅ Build must succeed
- ✅ Tests must pass

#### Pull Request Requirements
- **Require pull request before merging**: ✅ Enabled
- **Required approving reviews**: 1 (minimum)
- **Dismiss stale pull request approvals**: ✅ Enabled

#### Additional Restrictions
- **Require status checks to pass**: ✅ Enabled
- **Require branches to be up to date**: ✅ Enabled
- **Allow force pushes**: ❌ Disabled
- **Allow deletions**: ❌ Disabled

### Feature Branch Pattern

**Target:** `feature/*`, `feat/*` branches

#### Requirements
- Must be created from `develop`
- Must be merged back to `develop` via PR
- Auto-delete after merge: ✅ Enabled

### Release Branch Pattern

**Target:** `release/*` branches

#### Requirements
- Must be created from `develop`
- Can be merged to both `main` and `develop`
- Requires 2 approving reviews
- All status checks must pass

### Hotfix Branch Pattern

**Target:** `hotfix/*`, `fix/*` branches

#### Requirements
- Can be created from `main` or `develop`
- Requires 1 approving review (expedited)
- Critical status checks must pass
- Must be merged to both `main` and `develop`

## 🔒 Rulesets Configuration

### Ruleset 1: Production Protection

**Enforcement:** Active
**Bypass:** Repository admins only

**Rules:**
1. ✅ Block force pushes
2. ✅ Block deletions
3. ✅ Require pull request
4. ✅ Require status checks
5. ✅ Require code review
6. ✅ Require signed commits (optional)
7. ✅ Block creation (only admins can create)

**Applies to:**
- `main` branch
- `production` branch (if exists)
- Tags matching `v*`

### Ruleset 2: Development Protection

**Enforcement:** Active
**Bypass:** Maintainers and admins

**Rules:**
1. ✅ Block force pushes
2. ✅ Require pull request
3. ✅ Require status checks
4. ✅ Require code review (1 approval)

**Applies to:**
- `develop` branch
- `staging` branch (if exists)

### Ruleset 3: Feature Branch Guidelines

**Enforcement:** Evaluate (warnings only)

**Rules:**
1. ⚠️ Require descriptive branch names
2. ⚠️ Encourage regular commits
3. ⚠️ Suggest linking to issues

**Applies to:**
- `feature/*` branches
- `feat/*` branches

### Ruleset 4: Tag Protection

**Enforcement:** Active
**Bypass:** Repository admins only

**Rules:**
1. ✅ Block tag deletion
2. ✅ Block tag updates
3. ✅ Require signed tags (optional)

**Applies to:**
- All tags matching `v*.*.*`

## 📋 Status Check Requirements

### Required Checks for Main Branch

```yaml
required_status_checks:
  strict: true
  contexts:
    - "CI / Lint Node.js"
    - "CI / Test Node.js"
    - "CI / Build"
    - "Security Scanning / CodeQL Analysis"
    - "Security Scanning / Secret Scanning"
    - "Security Scanning / Dependency Review"
    - "AI Code Review / Gemini Review"
```

### Required Checks for Develop Branch

```yaml
required_status_checks:
  strict: true
  contexts:
    - "CI / Lint Node.js"
    - "CI / Test Node.js"
    - "CI / Build"
```

## 🚀 Merge Strategies

### Recommended Settings

**For Main Branch:**
- Merge Method: Squash and merge (preferred)
- Commit message: Use PR title
- Auto-delete branch after merge: ✅

**For Develop Branch:**
- Merge Method: Merge commit (preferred) or Squash
- Auto-delete branch after merge: ✅

**For Feature Branches:**
- Merge Method: Squash and merge
- Auto-delete branch after merge: ✅

## 🔐 Security Requirements

### Dependency Management
- ✅ Dependabot enabled
- ✅ Security updates auto-merge (for minor versions)
- ✅ Vulnerability alerts enabled
- ✅ Code scanning enabled

### Secret Scanning
- ✅ Secret scanning enabled
- ✅ Push protection enabled
- ✅ Partner patterns enabled
- ✅ Alert on secret detection

### Code Analysis
- ✅ CodeQL analysis enabled
- ✅ Run on every PR
- ✅ Run on every push to main
- ✅ Weekly scheduled scan

## 👥 Team Permissions

### Repository Roles

**Admins:**
- Full access
- Can bypass branch protections (emergency only)
- Can manage settings
- Can delete repository

**Maintainers:**
- Can merge PRs
- Can manage issues and PRs
- Can create releases
- Cannot bypass branch protections

**Contributors:**
- Can create branches
- Can open PRs
- Can comment on issues/PRs
- Cannot merge without approval

**Read-only:**
- Can view repository
- Can clone repository
- Cannot push changes

## 📝 Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `perf`: Performance improvements
- `security`: Security fixes

### Examples

```
feat(auth): add OAuth2 authentication

Implement OAuth2 authentication flow using the authorization code grant.
Includes token refresh and revocation endpoints.

Closes #123
```

```
fix(api): resolve race condition in cache update

The cache update operation had a race condition that could cause stale
data to be served. Added proper locking mechanism.

Fixes #456
```

## 🔄 Release Process

### Version Tagging

Use semantic versioning: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Release Checklist

- [ ] All tests passing
- [ ] Security scans clean
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Documentation updated
- [ ] Release notes prepared
- [ ] Tag created
- [ ] GitHub release published
- [ ] Artifacts built and uploaded

## 🚨 Emergency Procedures

### Hotfix Process

1. Create `hotfix/*` branch from `main`
2. Make minimal fix
3. Open PR with `priority: critical` label
4. Request expedited review (1 approval minimum)
5. Merge to `main` after approval
6. Cherry-pick to `develop`
7. Create patch release

### Bypassing Branch Protection

Only repository admins can bypass protections.

**When to bypass:**
- Critical security fix
- Production outage
- CI/CD system failure

**Required documentation:**
- Reason for bypass
- What was changed
- Who approved the bypass
- Follow-up actions

## 📊 Automation

### Auto-merge Conditions

PRs will auto-merge when:
- ✅ All required checks pass
- ✅ Required approvals received
- ✅ No merge conflicts
- ✅ Has `auto-merge` label
- ✅ Not a draft PR

### Auto-labeling

PRs and issues are automatically labeled based on:
- Changed files
- Branch name
- Issue/PR title and body
- Size (lines changed)

### Auto-assignment

- Code owners are auto-assigned for review
- Issues are auto-assigned based on labels
- Load balancing across team members

## 🔧 Configuration API

### Creating Rulesets via API

```bash
# Example: Create main branch protection
curl -X PUT \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/OWNER/REPO/branches/main/protection \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": ["CI"]
    },
    "enforce_admins": false,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews": true
    },
    "restrictions": null
  }'
```

### Using GitHub CLI

```bash
# Enable branch protection
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_pull_request_reviews[required_approving_review_count]=1
```

## 📚 References

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)

## ✅ Setup Checklist

Use this checklist to configure your repository:

- [ ] Enable branch protection for `main`
- [ ] Enable branch protection for `develop`
- [ ] Configure required status checks
- [ ] Set up CODEOWNERS file
- [ ] Enable Dependabot
- [ ] Enable secret scanning
- [ ] Enable code scanning (CodeQL)
- [ ] Configure auto-merge settings
- [ ] Set up team permissions
- [ ] Configure merge strategies
- [ ] Enable auto-delete branches
- [ ] Set up vulnerability alerts
- [ ] Configure security advisories
- [ ] Enable GitHub Actions
- [ ] Configure notification settings

---

*Last updated: 2024*
*For questions or updates, please open an issue.*
