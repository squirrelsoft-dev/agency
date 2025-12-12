# Git Operations: Commit Formatting

Create well-formatted commits following conventional commit standards.

## When to Use

**During implementation work**:
- After completing a logical unit of work
- Before switching tasks or contexts
- At natural checkpoints in development
- Before running risky operations

**Purpose**:
- Maintain clean git history
- Enable automated changelog generation
- Support semantic versioning
- Improve code review experience

---

## Conventional Commit Format

**Standard Structure**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Required**: `<type>: <subject>`
**Optional**: `<scope>`, `<body>`, `<footer>`

---

## Commit Types

```bash
# feat: New feature for the user
feat: add user authentication with JWT
feat(api): implement login endpoint
feat(ui): add login form component

# fix: Bug fix
fix: prevent duplicate user registration
fix(auth): resolve token expiration issue
fix(ui): correct form validation errors

# refactor: Code change that neither fixes bug nor adds feature
refactor: restructure auth service for clarity
refactor(api): simplify error handling logic
refactor(db): optimize user query performance

# docs: Documentation only changes
docs: update API authentication guide
docs(readme): add installation instructions
docs(contributing): clarify PR process

# style: Code style changes (formatting, semicolons, etc)
style: format code with prettier
style(css): update button styling
style: fix eslint warnings

# test: Adding or updating tests
test: add unit tests for auth service
test(e2e): add login flow test
test(integration): test API endpoints

# chore: Maintenance tasks, dependency updates
chore: update dependencies
chore(deps): upgrade react to v18
chore(config): update eslint config

# perf: Performance improvements
perf: optimize database queries
perf(api): add response caching
perf(ui): reduce bundle size

# ci: CI/CD configuration changes
ci: add GitHub Actions workflow
ci(deploy): update deployment script
ci: configure automated testing

# build: Build system or external dependency changes
build: update webpack config
build(npm): update package scripts
build: configure production builds

# revert: Revert previous commit
revert: revert "feat: add user authentication"
```

---

## Commit Subject Guidelines

**Rules**:
1. **Max 50 characters** (hard limit: 72)
2. **Imperative mood** - "add" not "added" or "adds"
3. **No period at end**
4. **Lowercase** after colon
5. **Descriptive but concise**

**Good Examples**:
```bash
feat: add user registration endpoint
fix: resolve memory leak in event listeners
refactor: extract validation logic to utility
docs: update deployment instructions
test: add edge case tests for auth
```

**Bad Examples**:
```bash
feat: Added the new user registration endpoint with validation  # Too long, wrong tense
Fix: bug                                                        # Too vague
refactor: Refactoring code.                                     # Wrong tense, period
feat: implement feature                                         # Not descriptive
```

---

## Commit Scope (Optional but Recommended)

**Purpose**: Indicate which part of codebase is affected

```bash
# Component/module scopes
feat(auth): add login functionality
fix(user-profile): correct avatar upload
refactor(api-client): simplify request handling

# Layer scopes
feat(frontend): implement dashboard UI
fix(backend): resolve database connection issue
test(e2e): add checkout flow tests

# Feature area scopes
feat(billing): add subscription management
fix(notifications): resolve email delivery
refactor(search): optimize query performance
```

**When to omit scope**:
- Changes affect multiple areas equally
- Scope is obvious from context
- Global changes (build, ci, chore)

---

## Commit Body (Optional)

**When to include**:
- Change is complex and needs explanation
- Need to provide context for WHY change was made
- Breaking changes or important details

**Format**:
- Separate from subject with blank line
- Wrap at 72 characters per line
- Use imperative mood
- Explain WHAT and WHY, not HOW

**Example**:
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT-based authentication

Implement JWT token generation and validation for user
authentication. This replaces the previous session-based
approach to enable stateless authentication and better
scalability.

- Add JWT token generation on login
- Add middleware to validate tokens
- Add token refresh endpoint
- Update user model with token fields
EOF
)"
```

---

## Commit Footer (Optional)

**Breaking Changes**:
```bash
git commit -m "$(cat <<'EOF'
feat(api)!: change user endpoint response format

BREAKING CHANGE: User API endpoint now returns nested
user object instead of flat structure. Update client
code accordingly.

Before: { id, name, email }
After: { user: { id, name, email } }
EOF
)"
```

**Issue References**:
```bash
git commit -m "$(cat <<'EOF'
fix(auth): resolve login redirect issue

Fixes #123
Closes #456
Related to #789
EOF
)"
```

**Co-authors**:
```bash
git commit -m "$(cat <<'EOF'
feat: implement real-time notifications

Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>
EOF
)"
```

---

## Creating Commits

### Basic Commit Flow

```bash
# 1. Check status
git status

# 2. Stage changes
git add path/to/file.ts
# Or stage all changes
git add .

# 3. Create commit (simple)
git commit -m "feat: add user authentication"

# 4. Create commit (with body) - USE HEREDOC
git commit -m "$(cat <<'EOF'
feat(auth): add JWT authentication

Implement token-based authentication system to replace
session-based auth. This enables better scalability and
stateless API design.

Closes #123
EOF
)"
```

### Amending Commits

```bash
# Add forgotten changes to last commit
git add forgotten-file.ts
git commit --amend --no-edit

# Change last commit message
git commit --amend -m "feat: correct commit message"

# ONLY amend if:
# - Commit hasn't been pushed yet
# - You are the author of the commit
# - No one else is working on this branch
```

### Interactive Staging

```bash
# Stage parts of a file
git add -p path/to/file.ts
# Use 'y' to stage hunks, 'n' to skip, 's' to split

# Review staged changes before commit
git diff --staged
```

---

## Commit Message Templates

### Feature Addition
```bash
git commit -m "$(cat <<'EOF'
feat(<scope>): add <feature-name>

Implement <brief description of feature>.

- <Detail 1>
- <Detail 2>
- <Detail 3>

Closes #<issue-number>
EOF
)"
```

### Bug Fix
```bash
git commit -m "$(cat <<'EOF'
fix(<scope>): resolve <bug-description>

Fix issue where <description of problem>.

Root cause: <brief explanation>
Solution: <brief explanation>

Fixes #<issue-number>
EOF
)"
```

### Refactoring
```bash
git commit -m "$(cat <<'EOF'
refactor(<scope>): <description>

Restructure <what was refactored> to improve <benefit>.

No functional changes.
EOF
)"
```

### Documentation
```bash
git commit -m "docs(<scope>): <description>"
```

### Test Addition
```bash
git commit -m "$(cat <<'EOF'
test(<scope>): add tests for <feature>

- Add unit tests for <function/component>
- Add edge case tests
- Increase coverage to <percentage>%
EOF
)"
```

---

## Commit Frequency Best Practices

**Good Commit Frequency**:
- Commit after each logical unit of work
- Typically 3-10 commits per feature
- Each commit should be buildable and testable

**Atomic Commits**:
- One logical change per commit
- Should be able to revert without side effects
- Easier to review and understand

**Examples**:
```bash
# Good (atomic commits)
git commit -m "feat(auth): add user model"
git commit -m "feat(auth): add login endpoint"
git commit -m "feat(auth): add JWT token generation"
git commit -m "test(auth): add auth service tests"

# Bad (too large, multiple concerns)
git commit -m "feat: add entire authentication system with tests and docs"
```

---

## Validation Before Commit

**Pre-Commit Checks**:
```bash
# 1. Verify changes are intentional
git diff --staged

# 2. Check for common issues
# - console.log statements
# - TODO/FIXME comments
# - Hardcoded secrets or API keys
# - Debug code
# - Large binary files

# 3. Run linter
npm run lint

# 4. Run tests
npm test

# 5. Type check (TypeScript)
npm run type-check
```

**Never Commit**:
- ❌ `.env` files
- ❌ `node_modules/`
- ❌ Build artifacts
- ❌ API keys or secrets
- ❌ Personal configuration files
- ❌ Large binary files (images, videos)
- ❌ Temporary files

---

## Common Commit Scenarios

### Work in Progress (WIP)
```bash
# During development, need to save state
git commit -m "wip: user authentication in progress"

# Later, amend or squash before push
git commit --amend -m "feat: add user authentication"
```

### Multiple Files, Single Logical Change
```bash
# Add related files together
git add src/auth/service.ts
git add src/auth/types.ts
git add src/auth/utils.ts
git commit -m "feat(auth): add authentication service"
```

### Separate Changes in Same File
```bash
# Use interactive staging
git add -p src/utils.ts
# Stage first change
git commit -m "feat: add validation utility"

# Stage second change
git add -p src/utils.ts
git commit -m "refactor: extract helper function"
```

---

## Error Handling

### Error: Empty Commit Message
```bash
# Git will abort if message is empty
# Always provide descriptive message
```

### Error: Pre-commit Hook Fails
```bash
# Common hooks: linting, testing
# Fix issues before committing
npm run lint -- --fix
npm test

# Override ONLY if absolutely necessary (not recommended)
git commit --no-verify -m "feat: urgent hotfix"
```

### Error: Nothing to Commit
```bash
# No staged changes
git status
# Stage changes first
git add <files>
```

---

## Integration with GitHub

### Linking Commits to Issues

```bash
# Close issue when PR merges
git commit -m "feat: implement feature

Closes #123"

# Reference without closing
git commit -m "feat: add partial implementation

Related to #123"

# Multiple issues
git commit -m "fix: resolve bugs

Fixes #123, #456
Related to #789"
```

### GitHub-Specific Keywords
- `Closes #123`, `Fixes #123`, `Resolves #123` - Close issue
- `Related to #123`, `See #123`, `Ref #123` - Reference issue
- Works in commit message body and PR description

---

## Quality Checklist

Before committing:
- [ ] Changes are logical and atomic
- [ ] Message follows conventional commit format
- [ ] Subject is clear and under 50 characters
- [ ] No secrets or sensitive data included
- [ ] Linter passes
- [ ] Tests pass (if applicable)
- [ ] Only intentional changes staged
- [ ] Breaking changes documented if any

---

## Reporting Format

```markdown
## Commit Created

**Type**: feat
**Scope**: auth
**Message**: add JWT authentication
**Files Changed**: 3 files (+247, -18 lines)
**Status**: ✅ Committed successfully

**Commit Hash**: abc123d
**Branch**: feat/user-authentication

**Changes**:
- src/auth/service.ts (added)
- src/auth/types.ts (added)
- src/middleware/auth.ts (modified)

**Next Steps**:
- Continue implementation
- Run tests
- Push to remote when ready
```

---

## Related Components

- `prompts/git/branch-creation.md` - Create branch before committing
- `prompts/git/status-validation.md` - Check status before commit
- `prompts/git/pr-creation.md` - Create PR after commits
