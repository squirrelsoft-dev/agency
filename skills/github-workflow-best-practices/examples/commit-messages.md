# Commit Message Examples

## Good Commit Messages

### Feature Additions

```
feat(auth): add OAuth2 authentication

Implement OAuth2 flow with Google and GitHub providers.
Includes token refresh mechanism and session management.

- Add OAuth2 provider configuration
- Implement callback handler
- Add token refresh middleware
- Update user model with provider fields

Closes #123
```

```
feat(dashboard): add real-time chart updates

Enable WebSocket connection for live data updates on dashboard charts.
Charts now refresh automatically without page reload.

Closes #456
```

### Bug Fixes

```
fix(login): resolve infinite redirect loop

Fix redirect loop that occurred when user's session expired
during navigation. Now properly redirects to login with return URL.

The issue was caused by the auth middleware redirecting to login
while the login route was also checking auth, creating a loop.

Fixes #789
```

```
fix(api): handle null values in user profile

Prevent 500 error when user profile fields are null.
Add null checks and default values for optional fields.

Before: 500 error on null bio
After: Returns empty string for null fields

Closes #234
```

### Refactoring

```
refactor(auth): extract validation logic into service

Move authentication validation logic from controllers into
dedicated AuthService for better reusability and testing.

- Create AuthService class
- Move validation methods to service
- Update controllers to use service
- Add unit tests for service

No functional changes.
```

```
refactor(components): split large UserProfile component

Break down 500-line UserProfile component into smaller,
focused components for better maintainability.

- UserProfileHeader
- UserProfileInfo
- UserProfileSettings
- UserProfileActivity

All props and functionality remain the same.
```

### Performance Improvements

```
perf(queries): add database indexes for user searches

Add indexes on users.email and users.username columns to
improve search query performance.

Before: ~800ms query time
After: ~50ms query time

Migration included.
```

```
perf(rendering): memoize expensive chart calculations

Use React.useMemo for chart data transformations to prevent
unnecessary recalculations on every render.

Reduces re-render time from 120ms to 15ms.
```

### Documentation

```
docs(api): add authentication endpoint examples

Add code examples for all authentication endpoints in API docs.
Include request/response samples and error handling.

Examples added for:
- POST /auth/login
- POST /auth/register
- POST /auth/refresh
- POST /auth/logout
```

```
docs(readme): update installation instructions

Update README with new environment variable requirements
and Docker setup instructions for version 2.0.

Closes #567
```

### Tests

```
test(auth): add integration tests for OAuth flow

Add comprehensive integration tests covering the complete
OAuth2 authentication flow including error cases.

- Test successful authentication
- Test invalid provider
- Test expired tokens
- Test token refresh

Coverage increased from 65% to 92%.
```

```
test(api): add edge case tests for user endpoints

Add tests for edge cases that were previously uncovered:
- Empty request body
- Malformed JSON
- SQL injection attempts
- XSS payloads

Closes #890
```

### Chores

```
chore(deps): update dependencies to latest versions

Update all non-breaking dependencies to their latest versions.
Run full test suite to ensure compatibility.

Major updates:
- react 18.2.0 → 18.3.0
- next 14.0.0 → 14.1.0
- typescript 5.2.0 → 5.3.0

All tests pass.
```

```
chore(config): update ESLint rules for TypeScript

Update ESLint configuration to use recommended TypeScript rules
and fix all linting errors.

- Enable @typescript-eslint/recommended
- Fix 45 linting errors
- Update .eslintignore

No functional changes.
```

## Bad Commit Messages (Don't Do This)

### Too Vague

❌ **Bad**:
```
fix stuff
```

✅ **Good**:
```
fix(auth): resolve session timeout issue

Fix bug where sessions were expiring after 1 hour instead of
the configured 24 hours due to incorrect TTL calculation.

Closes #123
```

---

❌ **Bad**:
```
update code
```

✅ **Good**:
```
refactor(api): extract validation logic to middleware

Move request validation from route handlers to reusable
middleware for better code organization and testability.

No functional changes.
```

### Missing Context

❌ **Bad**:
```
fix bug
```

✅ **Good**:
```
fix(checkout): prevent duplicate order creation

Fix race condition that allowed users to submit the same
order multiple times by rapid clicking.

Add debounce to submit button and server-side idempotency check.

Fixes #456
```

---

❌ **Bad**:
```
improve performance
```

✅ **Good**:
```
perf(database): optimize product query with eager loading

Replace N+1 query with eager loading for product categories
and images, reducing query count from 100+ to 3.

Query time reduced from 2.5s to 150ms for product list page.

Closes #789
```

### Multiple Unrelated Changes

❌ **Bad**:
```
feat: add dark mode, fix login bug, update dependencies

- Implement dark mode toggle
- Fix login redirect issue
- Update React to 18.3
- Add new user avatar component
- Update README
```

✅ **Good** (separate commits):
```
feat(theme): add dark mode toggle

Implement dark mode with theme provider and toggle switch.
Persists user preference in localStorage.

Closes #123
```

```
fix(auth): resolve login redirect issue

Fix bug where login redirect URL was not preserved
when session expired.

Fixes #456
```

```
chore(deps): update React to 18.3.0

Update React and React-DOM to latest version.
All tests pass, no breaking changes.
```

```
feat(profile): add user avatar component

Add reusable Avatar component with support for
images, initials, and placeholder states.

Closes #789
```

### Work-in-Progress Messages

❌ **Bad**:
```
WIP
```

```
temp commit
```

```
save progress
```

```
asdfasdf
```

✅ **Good** (either squash these or write properly):
```
feat(dashboard): implement chart widget (WIP)

Initial implementation of chart widget component.
Still needs data integration and error handling.

Part of #123
```

Then squash before merging or complete and rewrite:
```
feat(dashboard): add interactive chart widget

Implement fully-featured chart widget with data binding,
error handling, and responsive design.

Closes #123
```

## Commit Message Templates

### Feature Template

```
feat(<scope>): <brief description>

<detailed description explaining what and why>

<implementation details if needed>
- Detail 1
- Detail 2
- Detail 3

Closes #<issue-number>
```

### Bug Fix Template

```
fix(<scope>): <brief description>

<describe the bug and its impact>

<explain the fix>
Before: <previous behavior>
After: <new behavior>

Fixes #<issue-number>
```

### Breaking Change Template

```
feat(<scope>)!: <brief description>

<description of new behavior>

BREAKING CHANGE: <describe what breaks and why>
<provide migration path>

Before:
<old usage example>

After:
<new usage example>

Migration:
1. Step 1
2. Step 2

Closes #<issue-number>
```

### Multi-paragraph Template

```
<type>(<scope>): <brief description>

<paragraph 1: what changed>

<paragraph 2: why it changed>

<paragraph 3: implementation details>

<related issues>
Closes #123
Relates to #456
Blocked by #789
```

## Subject Line Patterns

### Use Imperative Mood

✅ **Good**:
- "Add feature"
- "Fix bug"
- "Update documentation"
- "Remove deprecated code"

❌ **Bad**:
- "Added feature"
- "Fixes bug"
- "Updating documentation"
- "Removed deprecated code"

### Keep Under 50 Characters

✅ **Good**:
```
feat(auth): add OAuth2 integration
```

❌ **Bad**:
```
feat(auth): add OAuth2 integration with Google and GitHub providers including token refresh
```

Better:
```
feat(auth): add OAuth2 integration

Implement OAuth2 with Google and GitHub providers.
Includes automatic token refresh mechanism.
```

### Capitalize First Letter

✅ **Good**:
```
feat(api): Add rate limiting
```

❌ **Bad**:
```
feat(api): add rate limiting
```

### No Period at End

✅ **Good**:
```
fix(login): resolve redirect issue
```

❌ **Bad**:
```
fix(login): resolve redirect issue.
```

## Scope Examples

### Frontend Scopes

```
feat(components): add Button variants
feat(hooks): add useLocalStorage hook
feat(pages): add dashboard page
feat(styles): update theme colors
feat(utils): add date formatting helpers
```

### Backend Scopes

```
feat(api): add user endpoints
feat(database): add users table migration
feat(middleware): add rate limiting
feat(services): add email service
feat(models): add User model
```

### Infrastructure Scopes

```
feat(ci): add test workflow
feat(docker): update Dockerfile
feat(deploy): add staging environment
chore(config): update TypeScript config
```

## Co-author Examples

### Pair Programming

```
feat(auth): implement 2FA authentication

Add two-factor authentication using TOTP.
Users can enable 2FA in security settings.

Co-authored-by: Jane Doe <jane@example.com>
```

### Multiple Contributors

```
feat(dashboard): redesign user dashboard

Complete redesign of user dashboard with new layout,
improved navigation, and real-time updates.

Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>
Co-authored-by: Alice Johnson <alice@example.com>
```

## References

### Linking Issues

```
Closes #123
Fixes #123
Resolves #123
```

Multiple issues:
```
Closes #123, #456, #789
```

### Relating Without Closing

```
Relates to #123
Part of #123
See also #123
Blocked by #123
```

### Cross-repository References

```
Closes owner/repo#123
Relates to organization/another-repo#456
```

## Commit Message Tools

### Commitizen

Interactive commit message creator:
```bash
npm install -g commitizen
cz
```

### Commitlint

Enforce conventional commits:
```bash
npm install -g @commitlint/cli @commitlint/config-conventional
```

### Git Hooks

Pre-commit hook to validate messages:
```bash
#!/bin/sh
# .git/hooks/commit-msg

MESSAGE=$(cat $1)
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|ci|build)(\(.+\))?: .{1,50}"

if ! echo "$MESSAGE" | grep -qE "$PATTERN"; then
  echo "Invalid commit message format."
  echo "Use: <type>(<scope>): <subject>"
  exit 1
fi
```

## Best Practices Summary

1. ✅ Use conventional commits format
2. ✅ Write in imperative mood
3. ✅ Keep subject under 50 characters
4. ✅ Separate subject and body with blank line
5. ✅ Explain what and why, not how
6. ✅ Reference issues
7. ✅ Make atomic commits
8. ❌ Don't combine unrelated changes
9. ❌ Don't use vague messages
10. ❌ Don't commit commented code

---

**Remember**: Good commit messages help your future self and teammates understand the codebase evolution. Invest time in writing them well.
