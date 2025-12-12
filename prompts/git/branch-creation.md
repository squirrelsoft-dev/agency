# Git Operations: Branch Creation

Create feature/bugfix/refactor branches with proper naming conventions.

## When to Use

**Before starting implementation work**:
- Creating feature branches
- Creating bugfix branches
- Creating refactor/chore/docs branches
- Isolating experimental work

**Purpose**:
- Follow git branching best practices
- Maintain consistent naming conventions
- Avoid working directly on main/master
- Enable parallel development

---

## Pre-Flight Checks

**Before creating a branch, validate**:

```bash
# 1. Check current branch
git branch --show-current

# 2. Check if on main/master
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]]; then
  echo "✅ On main/master branch"
else
  echo "⚠️ Not on main/master. Currently on: $CURRENT_BRANCH"
  # Ask user if they want to switch to main first
fi

# 3. Check for uncommitted changes
git status --porcelain
# If output exists, there are uncommitted changes
# Warn user or stash changes before creating branch

# 4. Pull latest changes
git pull origin $(git branch --show-current)
```

**Quality Gate**:
- MUST be on main/master (or user-specified base branch)
- SHOULD have clean working directory
- MUST have latest changes from remote

---

## Branch Naming Conventions

**Standard Prefixes**:

```bash
# Feature branches (new functionality)
feat/feature-name
feat/issue-123-feature-name

# Bug fix branches
fix/bug-description
fix/issue-456-bug-description

# Refactoring branches
refactor/component-name
refactor/cleanup-auth-logic

# Documentation branches
docs/update-readme
docs/api-documentation

# Chore branches (maintenance, dependencies)
chore/update-dependencies
chore/configure-eslint

# Performance optimization
perf/optimize-database-queries
perf/reduce-bundle-size

# Testing branches
test/add-unit-tests
test/e2e-checkout-flow

# Hotfix branches (urgent production fixes)
hotfix/critical-security-patch
hotfix/production-crash
```

**Naming Rules**:
- Use lowercase
- Use hyphens, not underscores
- Keep concise but descriptive (max 50 chars)
- Include issue number if available: `feat/issue-123-user-auth`
- No special characters except `/` and `-`

**Examples**:
```bash
# Good
feat/user-authentication
fix/login-redirect-bug
refactor/api-client
docs/contributing-guide

# Bad (avoid)
Feature/User-Authentication    # Wrong case
fix_login_bug                  # Underscores
feat/add-the-new-user-authentication-system-with-jwt  # Too long
bug/issue#123                  # Special characters
```

---

## Branch Creation Commands

### Create and Switch to New Branch

```bash
# Method 1: Two-step (traditional)
git branch feat/user-authentication
git checkout feat/user-authentication

# Method 2: One-step (recommended)
git checkout -b feat/user-authentication

# Method 3: Modern git (if available)
git switch -c feat/user-authentication
```

### Create Branch from Specific Base

```bash
# Create from main branch
git checkout -b feat/new-feature main

# Create from specific commit
git checkout -b fix/bug-fix abc123

# Create from remote branch
git checkout -b feat/feature-name origin/develop
```

### With Issue Tracking

```bash
# Extract issue number from plan or context
ISSUE_NUMBER="123"
FEATURE_NAME="user-authentication"
BRANCH_NAME="feat/issue-${ISSUE_NUMBER}-${FEATURE_NAME}"

git checkout -b "$BRANCH_NAME"
```

---

## Validation After Creation

```bash
# Verify branch created successfully
git branch --show-current
# Expected output: feat/user-authentication

# Verify branch tracking
git branch -vv
# Should show new branch with no remote tracking yet

# Verify clean state
git status
# Expected: "On branch feat/user-authentication"
#           "nothing to commit, working tree clean"
```

---

## Common Error Handling

### Error: Branch Already Exists

```bash
# Error message:
# fatal: A branch named 'feat/user-auth' already exists.

# Solution 1: Switch to existing branch
git checkout feat/user-auth

# Solution 2: Delete and recreate (if safe)
git branch -D feat/user-auth
git checkout -b feat/user-auth

# Solution 3: Use different name
git checkout -b feat/user-authentication-v2
```

### Error: Uncommitted Changes

```bash
# Error message:
# error: Your local changes to the following files would be overwritten by checkout

# Solution 1: Stash changes
git stash push -m "WIP before creating branch"
git checkout -b feat/new-feature
git stash pop

# Solution 2: Commit changes first
git add .
git commit -m "WIP: work in progress"
git checkout -b feat/new-feature

# Solution 3: Force (careful, may lose changes)
# Not recommended - ask user first
```

### Error: Detached HEAD State

```bash
# Check if detached
git branch --show-current
# If empty output, you're in detached HEAD state

# Solution: Create branch from current state
git checkout -b feat/recovery-branch

# Or return to main
git checkout main
```

### Error: Not on Main/Master

```bash
# If user creates branch from feature branch
CURRENT=$(git branch --show-current)
if [[ "$CURRENT" != "main" ]] && [[ "$CURRENT" != "master" ]]; then
  echo "⚠️ WARNING: Creating branch from '$CURRENT', not main/master"
  echo "This will include changes from '$CURRENT'"
  # Ask user: "Continue anyway? (y/n)"
fi
```

---

## Integration with GitHub

### Using GitHub CLI

```bash
# Create branch and push to remote
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
# Get default branch name (main or master)

# Create and push
git checkout -b feat/user-authentication
git push -u origin feat/user-authentication

# Verify remote tracking
git branch -vv
# Should show: [origin/feat/user-authentication]
```

---

## Multi-Branch Workflow

**When creating multiple related branches**:

```bash
# Pattern for multi-specialist work
FEATURE_NAME="user-authentication"

# Backend branch
git checkout -b feat/backend-${FEATURE_NAME}
git push -u origin feat/backend-${FEATURE_NAME}
git checkout main

# Frontend branch
git checkout -b feat/frontend-${FEATURE_NAME}
git push -u origin feat/frontend-${FEATURE_NAME}
git checkout main

# Integration branch (optional)
git checkout -b feat/integration-${FEATURE_NAME}
```

---

## Best Practices

1. **Always branch from main/master** (unless explicitly different base needed)
2. **One branch per feature/fix** - keep scope focused
3. **Short-lived branches** - merge within days, not weeks
4. **Descriptive names** - future you will thank present you
5. **Include issue numbers** - enables traceability
6. **Push early** - backup your work to remote
7. **Clean up merged branches** - delete after PR merged

---

## Reporting Format

```markdown
## Branch Created

**Branch Name**: feat/user-authentication
**Base Branch**: main
**Created From**: abc123d (Latest commit on main)
**Status**: ✅ Clean working directory
**Remote Tracking**: ⚠️ Not yet pushed

**Next Steps**:
1. Start implementation work
2. Make commits following conventional commit format
3. Push to remote: `git push -u origin feat/user-authentication`
4. Create PR when ready
```

---

## Related Components

- `prompts/git/commit-formatting.md` - Create commits on this branch
- `prompts/git/pr-creation.md` - Create PR from this branch
- `prompts/git/status-validation.md` - Verify branch state
