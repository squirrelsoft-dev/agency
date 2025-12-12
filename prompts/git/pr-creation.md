# Git Operations: Pull Request Creation

Create comprehensive pull requests using GitHub CLI with standardized templates.

## When to Use

**After implementation work is complete**:
- Feature is fully implemented and tested
- All commits are clean and following conventions
- Branch is ready for code review
- Quality gates have passed

**Purpose**:
- Request code review from team
- Enable CI/CD automation
- Document changes comprehensively
- Facilitate team collaboration

---

## Pre-Flight Checks

**Before creating PR, validate**:

```bash
# 1. Verify current branch is NOT main/master
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]]; then
  echo "❌ ERROR: Cannot create PR from main/master branch"
  exit 1
fi

# 2. Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️ WARNING: Uncommitted changes detected"
  echo "Commit or stash changes before creating PR"
  git status
fi

# 3. Verify remote tracking
REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
if [[ -z "$REMOTE_BRANCH" ]]; then
  echo "⚠️ Branch not pushed to remote"
  echo "Push with: git push -u origin $CURRENT_BRANCH"
fi

# 4. Check if up to date with remote
git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u} 2>/dev/null)
if [[ "$LOCAL" != "$REMOTE" ]]; then
  echo "⚠️ Local branch differs from remote"
  echo "Push changes: git push"
fi

# 5. Check if PR already exists
gh pr view --json number 2>/dev/null
# If exits successfully, PR already exists
```

**Quality Gates**:
- MUST NOT be on main/master
- SHOULD have clean working directory
- MUST be pushed to remote
- MUST be in sync with remote
- SHOULD NOT already have a PR

---

## Understanding the Feature Context

**Before writing PR description, analyze**:

```bash
# 1. Review all commits in the branch
git log main..HEAD --oneline
# Shows all commits since branching from main

# 2. View full diff from base branch
git diff main...HEAD
# Shows all changes in this PR

# 3. Check files changed
git diff --name-status main...HEAD
# Lists all files: A (added), M (modified), D (deleted)

# 4. Review commit messages for context
git log main..HEAD --format="%h - %s"
# Extract commit subjects for PR description

# 5. Check related issues
# Look for "Closes #123" or "Fixes #456" in commits
git log main..HEAD --grep="Closes\|Fixes\|Resolves"
```

**CRITICAL**: Analyze ALL commits, not just the latest one!

---

## PR Title Format

**Follow Conventional Commit Style**:
```
<type>(<scope>): <description>
```

**Examples**:
```bash
# Feature
feat: add user authentication with JWT
feat(api): implement real-time notifications
feat(ui): add dark mode toggle

# Bug Fix
fix: resolve login redirect issue
fix(auth): prevent duplicate user registration
fix(ui): correct form validation errors

# Refactor
refactor: restructure authentication service
refactor(api): simplify error handling
refactor(db): optimize user queries

# Multiple Scopes
feat(api,ui): add user profile management
fix(frontend,backend): resolve CORS issues
```

**Title Guidelines**:
- Max 72 characters
- Imperative mood
- No period at end
- Clear and descriptive
- Match primary commit type if single-purpose

---

## PR Description Template

**Standard Structure**:

```markdown
## Summary
[1-3 bullet points describing WHAT changed and WHY]

## Changes
[Detailed list of changes, organized by area]

### Backend
- [Change 1]
- [Change 2]

### Frontend
- [Change 1]
- [Change 2]

### Tests
- [Test additions/updates]

### Documentation
- [Doc updates]

## Test Plan
[How to test these changes]

- [ ] Step 1: [How to test]
- [ ] Step 2: [Expected result]
- [ ] Step 3: [Edge cases]

## Breaking Changes
[Only if applicable - describe what breaks and migration path]

## Screenshots
[Only if UI changes - add before/after screenshots]

## Related Issues
Closes #[issue-number]
Related to #[other-issue]

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] No secrets or credentials committed
```

---

## Creating PR with GitHub CLI

### Basic PR Creation

```bash
# Simple PR (opens editor for description)
gh pr create

# PR with title and body
gh pr create --title "feat: add user authentication" --body "Implement JWT-based auth"

# PR with HEREDOC (RECOMMENDED for complex PRs)
gh pr create \
  --title "feat(auth): add JWT authentication" \
  --body "$(cat <<'EOF'
## Summary
- Implement JWT-based authentication system
- Replace session-based auth for better scalability
- Add token refresh mechanism

## Changes

### Backend
- Add JWT token generation on login
- Add token validation middleware
- Add token refresh endpoint
- Update user model with token fields

### Frontend
- Add login form with token storage
- Add authentication context
- Add protected route wrapper
- Add automatic token refresh

### Tests
- Add unit tests for auth service
- Add integration tests for auth endpoints
- Add E2E tests for login flow

## Test Plan

- [ ] Register new user account
- [ ] Log in with valid credentials
- [ ] Verify token stored in localStorage
- [ ] Access protected route successfully
- [ ] Log out and verify token cleared
- [ ] Attempt access with expired token
- [ ] Verify token auto-refresh works

## Related Issues
Closes #123
Related to #456

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] No secrets committed
- [x] All quality gates passed
EOF
)"
```

### PR with Specific Base Branch

```bash
# Target different base branch (not main)
gh pr create --base develop --head feat/user-authentication

# Common scenarios
gh pr create --base staging  # For staging deployment
gh pr create --base release/v2.0  # For release branch
```

### PR with Reviewers and Labels

```bash
# Add reviewers
gh pr create --reviewer @username1,@username2

# Add assignees
gh pr create --assignee @username

# Add labels
gh pr create --label "feature,backend,needs-review"

# Combine all
gh pr create \
  --title "feat: add user authentication" \
  --body "..." \
  --reviewer @team-backend \
  --label "feature,high-priority" \
  --assignee @myself
```

### Draft PR

```bash
# Create draft PR (not ready for review)
gh pr create --draft

# Convert to ready for review later
gh pr ready
```

---

## Multi-Specialist PR Strategy

**When multiple specialists worked on feature**:

### Option 1: Single Integrated PR (RECOMMENDED)

```bash
# All specialists' work in one PR
git checkout main
git checkout -b feat/user-authentication

# Merge all specialist branches
git merge feat/backend-user-authentication
git merge feat/frontend-user-authentication

# Create single comprehensive PR
gh pr create \
  --title "feat: implement user authentication system" \
  --body "$(cat <<'EOF'
## Summary
- Full-stack user authentication implementation
- Backend API with JWT tokens
- Frontend login/register UI
- Complete test coverage

## Changes

### Backend (by @backend-dev)
- JWT token generation and validation
- Auth middleware
- User model updates
- Auth endpoints (login, register, refresh, logout)

### Frontend (by @frontend-dev)
- Login and registration forms
- Auth context and state management
- Protected route components
- Token storage and refresh logic

### Integration
- End-to-end authentication flow
- Consistent error handling
- Type-safe API contracts

## Test Plan

### Backend Tests
- [ ] Unit tests for auth service pass
- [ ] Integration tests for endpoints pass
- [ ] Token validation works correctly

### Frontend Tests
- [ ] Component tests pass
- [ ] E2E login flow works
- [ ] Token refresh works automatically

### Integration Tests
- [ ] Full authentication flow works
- [ ] Error states handled correctly
- [ ] CORS configured properly

## Related Issues
Closes #123

## Specialists Involved
- Backend: @backend-specialist
- Frontend: @frontend-specialist
- Review: @code-reviewer
EOF
)"
```

### Option 2: Separate PRs with Dependencies

```bash
# Create backend PR first
git checkout feat/backend-user-authentication
gh pr create --title "feat(backend): add authentication API"

# Note PR number, e.g., #456

# Create frontend PR depending on backend
git checkout feat/frontend-user-authentication
gh pr create \
  --title "feat(frontend): add authentication UI" \
  --body "$(cat <<'EOF'
## Summary
Frontend authentication implementation

## Dependencies
Depends on #456 (Backend authentication API)
Merge #456 first, then this PR.

...
EOF
)"
```

---

## PR Description Best Practices

### Summary Section

**Good**:
```markdown
## Summary
- Implement JWT-based authentication to replace session-based auth
- Add login, register, and token refresh endpoints
- Improve security with bcrypt password hashing
```

**Bad**:
```markdown
## Summary
- Added authentication
- Made changes to the code
- Fixed some issues
```

### Changes Section

**Good** (organized by area):
```markdown
## Changes

### Authentication Service
- Add JWT token generation with 1-hour expiration
- Add bcrypt password hashing with salt rounds of 10
- Add token refresh mechanism with refresh tokens

### API Endpoints
- POST /auth/login - User login with email/password
- POST /auth/register - New user registration
- POST /auth/refresh - Refresh access token
- POST /auth/logout - Invalidate refresh token

### Database
- Add refresh_token field to users table
- Add token_expires_at timestamp field
- Create index on refresh_token for performance
```

**Bad** (vague and unorganized):
```markdown
## Changes
- Added stuff to auth
- Updated database
- Fixed things
- Improved code
```

### Test Plan Section

**Good** (specific, actionable):
```markdown
## Test Plan

### Manual Testing
- [ ] Register new user with email "test@example.com"
- [ ] Verify user created in database
- [ ] Log in with registered credentials
- [ ] Verify JWT token returned in response
- [ ] Access protected endpoint /api/profile with token
- [ ] Verify profile data returned successfully
- [ ] Wait for token expiration (or manually expire)
- [ ] Use refresh token to get new access token
- [ ] Log out and verify refresh token invalidated

### Edge Cases
- [ ] Login with invalid credentials returns 401
- [ ] Register with existing email returns 409
- [ ] Access protected endpoint without token returns 401
- [ ] Use expired token returns 401
- [ ] Use revoked refresh token returns 401
```

**Bad**:
```markdown
## Test Plan
- Test the feature
- Make sure it works
- Try different scenarios
```

---

## Common PR Scenarios

### Feature PR
```bash
gh pr create \
  --title "feat(module): add new feature" \
  --label "feature,enhancement"
```

### Bug Fix PR
```bash
gh pr create \
  --title "fix(module): resolve critical bug" \
  --label "bug,high-priority"
```

### Refactoring PR
```bash
gh pr create \
  --title "refactor(module): improve code structure" \
  --label "refactor,tech-debt"
```

### Hotfix PR
```bash
# Urgent production fix
gh pr create \
  --title "hotfix: resolve critical production issue" \
  --label "hotfix,critical" \
  --base main \
  --reviewer @team-leads
```

### Documentation PR
```bash
gh pr create \
  --title "docs: update API documentation" \
  --label "documentation"
```

---

## Error Handling

### Error: No Remote Branch

```bash
# Error: no remote tracking branch
# Solution: Push first
git push -u origin $(git branch --show-current)
gh pr create
```

### Error: PR Already Exists

```bash
# Error: pull request already exists
# View existing PR
gh pr view

# Update existing PR (push more commits)
git push

# Or close and recreate if needed
gh pr close
gh pr create
```

### Error: No Commits Ahead of Base

```bash
# Error: no commits between base and head
# Check branch status
git log main..HEAD

# If no commits, you may be on wrong branch
git branch --show-current
```

### Error: GITHUB_TOKEN Not Set

```bash
# Error: authentication required
# Login to GitHub CLI
gh auth login

# Follow prompts to authenticate
```

### Error: Branch Behind Main

```bash
# Warning: branch is behind main
# Update branch first
git fetch origin
git rebase origin/main

# Or merge
git merge origin/main

# Then push and create PR
git push
gh pr create
```

---

## Post-PR Creation

### View PR in Browser

```bash
# Open PR in browser
gh pr view --web

# View PR details in terminal
gh pr view

# View PR diff
gh pr diff
```

### Monitor PR Status

```bash
# Check PR status (checks, reviews)
gh pr checks

# View PR reviews
gh pr reviews

# View PR comments
gh pr view --comments
```

### Update PR After Creation

```bash
# Push more commits (PR updates automatically)
git commit -m "fix: address review feedback"
git push

# Edit PR description
gh pr edit --body "Updated description"

# Add labels
gh pr edit --add-label "ready-for-review"

# Request review
gh pr edit --add-reviewer @username
```

---

## Quality Checklist

Before creating PR:
- [ ] All commits follow conventional commit format
- [ ] Branch is pushed to remote
- [ ] Branch is up to date with main
- [ ] No uncommitted changes
- [ ] All quality gates passed (build, tests, lint)
- [ ] Code reviewed by reality-checker
- [ ] PR title is clear and descriptive
- [ ] PR description is comprehensive
- [ ] Test plan is detailed and actionable
- [ ] Related issues are linked
- [ ] Breaking changes documented (if any)
- [ ] Screenshots added (if UI changes)

---

## Reporting Format

```markdown
## Pull Request Created

**PR Number**: #789
**Title**: feat(auth): add JWT authentication
**Branch**: feat/user-authentication → main
**Status**: ✅ Open

**URL**: https://github.com/org/repo/pull/789

**Summary**:
- JWT-based authentication implementation
- Login, register, and token refresh endpoints
- Frontend authentication UI and state management

**Files Changed**: 23 files (+1,847, -124 lines)
**Commits**: 12 commits
**Reviewers**: @backend-team, @security-team
**Labels**: feature, backend, frontend, high-priority

**Checks Status**:
- Build: ✅ Passing
- Tests: ✅ Passing (127/127)
- Linter: ✅ Passing
- Coverage: ✅ 89%

**Next Steps**:
1. Wait for CI/CD checks to complete
2. Address reviewer feedback
3. Request final approval
4. Merge when approved
```

---

## Related Components

- `prompts/git/branch-creation.md` - Create branch for PR
- `prompts/git/commit-formatting.md` - Format commits in PR
- `prompts/git/status-validation.md` - Validate before PR
- `prompts/code-review/reality-checker-spawn.md` - Review before PR
