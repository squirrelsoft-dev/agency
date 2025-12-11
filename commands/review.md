---
description: Comprehensive multi-aspect code review (security, quality, performance, testing)
argument-hint: pr-number, URL, or file-path
allowed-tools: [Read, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Code Review: $ARGUMENTS

Multi-aspect code review with parallel specialist evaluation and aggregated recommendations.

## Your Mission

Review: **$ARGUMENTS**

Perform comprehensive multi-aspect code review: security → quality → performance → testing → architecture.

---

## Critical Instructions

### 1. Activate Code Review Standards

**IMMEDIATELY** activate the code review standards skill:
```
Use the Skill tool to activate: code-review-standards
```

This skill contains critical review patterns, security checklists, and quality standards you MUST follow.

---

## Phase 1: Review Target Detection (2-3 min)

### Auto-Detect Source

Analyze `$ARGUMENTS` to determine what to review:

**GitHub Pull Request** if:
- Numeric only: `123` → Assumes current repo
- GitHub PR URL: `https://github.com/owner/repo/pull/123`
- PR reference: `#123`, `PR 123`, `pull/123`

**GitLab Merge Request** if:
- GitLab MR URL: `https://gitlab.com/owner/repo/-/merge_requests/123`
- MR reference: `!123`, `MR 123`

**Bitbucket Pull Request** if:
- Bitbucket PR URL: `https://bitbucket.org/owner/repo/pull-requests/123`

**Local Files** if:
- File path: `src/components/Button.tsx`
- Directory path: `src/features/auth/`
- Glob pattern: `src/**/*.ts`

### Fetch PR/MR Details

**For GitHub**:
```bash
# Get PR details
gh pr view $ARGUMENTS --json number,title,body,state,author,files

# Get PR diff
gh pr diff $ARGUMENTS

# Get changed files list
gh pr view $ARGUMENTS --json files --jq '.files[].path'
```

**For GitLab**:
```bash
# Assuming glab CLI is installed
glab mr view $ARGUMENTS

glab mr diff $ARGUMENTS
```

**For Bitbucket**:
```bash
# Use Bitbucket API via curl
curl -u user:token https://api.bitbucket.org/2.0/repositories/owner/repo/pullrequests/$ARGUMENTS
```

**For Local Files**:
```bash
# Use git diff to see changes
git diff main -- $ARGUMENTS

# Or if uncommitted
git diff -- $ARGUMENTS
```

### Extract Review Context

From the PR/MR/files, gather:
- **Title**: What change is being made?
- **Description**: Why is this change needed?
- **Changed Files**: Which files are affected?
- **Lines Changed**: How much code changed? (+X, -Y)
- **Author**: Who made the changes?
- **Base Branch**: What branch is this merging into?
- **Status**: Draft, ready, approved, etc.

---

## Phase 2: Changed Files Analysis (3-5 min)

### Categorize Files

Group changed files by type:

**Frontend Files**:
- `*.tsx`, `*.jsx`, `*.ts`, `*.js` (in components/, pages/, app/)
- `*.css`, `*.scss`, `*.module.css`
- React, Vue, Angular, Svelte files

**Backend Files**:
- `*.ts`, `*.js` (in api/, server/, lib/, services/)
- Database migration files
- API route handlers
- Server configuration

**Configuration Files**:
- `package.json`, `tsconfig.json`, `.env*`
- `next.config.js`, `vite.config.ts`
- `.eslintrc`, `.prettierrc`
- Docker files, CI/CD configs

**Test Files**:
- `*.test.ts`, `*.test.tsx`, `*.spec.ts`
- `*.test.js`, `__tests__/*`

**Documentation**:
- `*.md`, `README`, `CHANGELOG`

**Other**:
- Assets, images, fonts
- Build outputs (should not be in PR)

### Calculate Complexity

Assess review complexity:

**Simple** (< 100 lines, 1-3 files):
- Quick review, 1-2 aspects
- Single reviewer sufficient
- ~10-15 min review time

**Medium** (100-500 lines, 4-10 files):
- Standard review, 3-4 aspects
- 2-3 specialized reviewers
- ~20-40 min review time

**Complex** (> 500 lines, > 10 files):
- Deep review, all 5 aspects
- 4-5 specialized reviewers
- ~60-120 min review time

**Very Complex** (> 1000 lines, > 20 files):
- Break into chunks, comprehensive review
- All specialized reviewers + architecture review
- ~2-4 hours review time

### Determine Review Aspects Needed

Based on changed files:

**Security Review** - ALWAYS for:
- Backend code (API, database, auth)
- User input handling
- File uploads
- Authentication/authorization changes
- Environment variable changes
- Dependency updates

**Quality Review** - ALWAYS for:
- All code changes
- Refactoring
- New features

**Performance Review** - When:
- Backend/API changes
- Database queries/migrations
- Large data processing
- Frontend rendering logic
- Image/asset handling

**Testing Review** - When:
- Test coverage < 80%
- New features without tests
- Critical business logic
- Test files modified

**Architecture Review** - When:
- > 20 files changed
- New patterns introduced
- Major refactoring
- Cross-cutting concerns
- Breaking changes

---

## Phase 3: Parallel Multi-Aspect Review (10-30 min)

### Launch Review Agents in Parallel

**IMPORTANT**: Spawn ALL relevant agents in parallel (single message, multiple Task calls) for maximum efficiency.

#### Security Review (ALWAYS)

```bash
Task tool with:
- subagent_type: backend-architect
- description: "Security review for PR $ARGUMENTS"
- prompt: "Perform comprehensive security review focusing on:

  **OWASP Top 10 Vulnerabilities**:
  1. Injection (SQL, NoSQL, Command, LDAP)
  2. Broken Authentication
  3. Sensitive Data Exposure
  4. XML External Entities (XXE)
  5. Broken Access Control
  6. Security Misconfiguration
  7. Cross-Site Scripting (XSS)
  8. Insecure Deserialization
  9. Using Components with Known Vulnerabilities
  10. Insufficient Logging & Monitoring

  **Specific Checks**:
  - Input validation on all user inputs
  - SQL injection prevention (parameterized queries)
  - XSS prevention (sanitization, escaping)
  - CSRF token usage for state-changing operations
  - Proper authentication checks on protected routes
  - Authorization checks (user can only access their data)
  - Secrets not hardcoded (use env vars)
  - Secure password hashing (bcrypt, scrypt, argon2)
  - HTTPS enforcement
  - Rate limiting on APIs
  - Proper error messages (no stack traces in production)

  Files to review: [backend/API files list]

  Severity levels:
  - CRITICAL: Immediate security risk, blocks merge
  - HIGH: Security vulnerability, must fix before merge
  - MEDIUM: Security concern, should fix
  - LOW: Security best practice, nice to fix

  Report CRITICAL and HIGH issues ONLY."
```

#### Quality Review (ALWAYS)

```bash
Task tool with:
- subagent_type: testing-reality-checker
- description: "Quality review for PR $ARGUMENTS"
- prompt: "Perform comprehensive quality review focusing on:

  **Code Quality**:
  - Readability: Clear variable names, logical structure
  - Maintainability: DRY principle, single responsibility
  - Complexity: Cyclomatic complexity reasonable
  - Error Handling: Proper try/catch, error boundaries
  - Type Safety: No 'any' types, proper TypeScript
  - Comments: Code is self-documenting, minimal comments needed

  **Bugs & Logic Errors**:
  - Off-by-one errors
  - Null/undefined checks
  - Race conditions
  - Memory leaks (closures, event listeners)
  - Edge cases handled
  - Async/await used correctly

  **Best Practices**:
  - Follows project coding standards
  - Consistent with existing codebase patterns
  - No code duplication
  - No magic numbers (use constants)
  - No TODO/FIXME left in PR
  - No console.log/debugger statements

  Files to review: [all code files]

  Severity levels:
  - CRITICAL: Blocks merge, introduces bugs
  - HIGH: Should fix, impacts quality
  - MEDIUM: Consider fixing
  - LOW: Nice to have

  Report CRITICAL and HIGH issues ONLY."
```

#### Performance Review (IF NEEDED)

```bash
Task tool with:
- subagent_type: performance-benchmarker
- description: "Performance review for PR $ARGUMENTS"
- prompt: "Perform performance review focusing on:

  **Backend Performance**:
  - Database query efficiency (N+1 queries, missing indexes)
  - API response time (< 200ms for simple, < 1s for complex)
  - Caching strategy (Redis, in-memory, CDN)
  - Background jobs for heavy operations
  - Connection pooling
  - Rate limiting to prevent abuse

  **Frontend Performance**:
  - Bundle size impact (lazy loading, code splitting)
  - Re-render optimization (React.memo, useMemo, useCallback)
  - Image optimization (next/image, lazy loading)
  - Core Web Vitals impact (LCP, FID, CLS)
  - Unnecessary dependencies added

  **Algorithm Efficiency**:
  - Time complexity reasonable (avoid O(n²) if avoidable)
  - Space complexity reasonable
  - Proper data structures used

  Files to review: [backend/database/frontend files]

  Severity levels:
  - CRITICAL: Major performance regression
  - HIGH: Noticeable performance impact
  - MEDIUM: Minor performance concern
  - LOW: Optimization opportunity

  Report CRITICAL and HIGH issues ONLY."
```

#### Testing Review (IF NEEDED)

```bash
Task tool with:
- subagent_type: test-results-analyzer
- description: "Testing review for PR $ARGUMENTS"
- prompt: "Perform testing review focusing on:

  **Test Coverage**:
  - New features have tests (unit + integration)
  - Modified code has tests updated
  - Target: 80%+ coverage for new code
  - Critical paths fully tested

  **Test Quality**:
  - Tests are meaningful, not just for coverage
  - Tests actually test behavior, not implementation
  - Edge cases covered
  - Error cases covered
  - Mocking used appropriately

  **Test Patterns**:
  - Arrange-Act-Assert (AAA) pattern
  - Descriptive test names
  - Independent tests (no shared state)
  - Fast tests (< 100ms for unit tests)

  **Missing Tests**:
  - New functions without tests
  - New API endpoints without tests
  - New React components without tests
  - Error handling paths without tests

  Files to review: [code files + test files]

  Severity levels:
  - CRITICAL: Critical feature untested
  - HIGH: Important feature lacks tests
  - MEDIUM: Test coverage below target
  - LOW: Minor test improvements

  Report CRITICAL and HIGH issues ONLY."
```

#### Architecture Review (IF NEEDED)

```bash
Task tool with:
- subagent_type: [selected-specialist based on domain]
- description: "Architecture review for PR $ARGUMENTS"
- prompt: "Perform architecture review focusing on:

  **Architectural Concerns**:
  - New patterns consistent with existing architecture
  - Separation of concerns maintained
  - Dependencies flow in correct direction
  - No circular dependencies introduced
  - Abstraction layers appropriate

  **Breaking Changes**:
  - Public API changes documented
  - Backwards compatibility considered
  - Migration path provided if breaking
  - Deprecation warnings added

  **Cross-Cutting Concerns**:
  - Logging strategy consistent
  - Error handling strategy consistent
  - Configuration management consistent
  - Dependency injection patterns followed

  **Scalability**:
  - Design scales with user growth
  - No hardcoded limits that won't scale
  - Stateless design where appropriate

  Files to review: [all files]

  Severity levels:
  - CRITICAL: Architecture violation, major refactor needed
  - HIGH: Architectural concern, should address
  - MEDIUM: Design improvement recommended
  - LOW: Minor architectural suggestion

  Report CRITICAL and HIGH issues ONLY."
```

### Wait for All Reviews to Complete

All review agents run in parallel. Wait for all to finish before proceeding to aggregation.

---

## Phase 4: Review Aggregation (5-7 min)

### Collect All Findings

From each reviewer agent, extract:
- **Aspect**: Security, Quality, Performance, Testing, Architecture
- **Severity**: CRITICAL, HIGH, MEDIUM, LOW
- **File**: Which file has the issue
- **Line**: Specific line number (if applicable)
- **Issue**: What is the problem
- **Recommendation**: How to fix it

### Categorize by Severity and File

Organize findings:

**By Severity**:
```
CRITICAL Issues: X
- [Security] File.ts:123 - SQL injection vulnerability
- [Quality] File.tsx:45 - Null pointer dereference

HIGH Issues: Y
- [Performance] API.ts:67 - N+1 query problem
- [Testing] Feature.tsx - No tests for new feature

MEDIUM Issues: Z
- [Quality] Component.tsx:12 - Complex function, consider refactoring
- [Performance] Page.tsx:89 - Unoptimized re-renders

LOW Issues: W
- [Architecture] Service.ts - Consider using dependency injection
```

**By File**:
```
src/api/users.ts
- CRITICAL [Security] Line 45: SQL injection via unsanitized input
- HIGH [Performance] Line 67: N+1 query, use JOIN

src/components/UserProfile.tsx
- HIGH [Testing] Missing tests for new feature
- MEDIUM [Quality] Line 123: Complex conditional, refactor

src/lib/auth.ts
- CRITICAL [Security] Line 89: Hardcoded API key
```

### Generate Unified Report

Create comprehensive review report structure:

```markdown
# Code Review Report: [PR/MR Title or Files]

**Reviewer**: Agency Multi-Aspect Review
**Date**: [Current date]
**Review Target**: $ARGUMENTS
**Changed Files**: [X] files, [+Y] additions, [-Z] deletions
**Review Complexity**: [Simple/Medium/Complex/Very Complex]

---

## Executive Summary

**Overall Assessment**: ✅ APPROVED / ⚠️ APPROVED WITH COMMENTS / ❌ CHANGES REQUIRED

**Review Aspects Evaluated**:
- ✅ Security: [X] issues found
- ✅ Quality: [X] issues found
- ✅ Performance: [X] issues found
- ✅ Testing: [X] issues found
- ✅ Architecture: [X] issues found

**Severity Breakdown**:
- CRITICAL: [X] (must fix before merge)
- HIGH: [X] (should fix before merge)
- MEDIUM: [X] (consider fixing)
- LOW: [X] (optional improvements)

---

## Critical Issues (Must Fix Before Merge)

### 1. [Aspect] [File:Line] - [Issue Title]

**Severity**: CRITICAL
**Category**: [Security/Quality/Performance/Testing/Architecture]
**File**: `path/to/file.ts:123`

**Issue**:
[Detailed description of the problem]

**Risk**:
[What could go wrong if not fixed]

**Recommendation**:
[Specific steps to fix]

```code
// Example fix if applicable
```

---

[Repeat for each critical issue]

---

## High Priority Issues (Should Fix Before Merge)

[Same structure as Critical Issues]

---

## Medium Priority Issues (Consider Fixing)

[Condensed format]:
1. **[File:Line]** - [Brief issue description] → [Brief fix recommendation]
2. **[File:Line]** - [Brief issue description] → [Brief fix recommendation]

---

## Low Priority Issues (Optional Improvements)

[Brief list]:
- [File]: [Issue] → [Fix]

---

## File-by-File Breakdown

### `src/api/users.ts` ([+X, -Y] lines)

**Issues Found**: [X]
- CRITICAL: [Issue]
- HIGH: [Issue]
- MEDIUM: [Issue]

**Strengths**:
- [Positive observations]

---

[Repeat for significant files]

---

## Positive Observations

- ✅ [Good practice 1]
- ✅ [Good practice 2]
- ✅ [Good practice 3]

---

## Recommendations Summary

**Before Merge** (Required):
1. Fix [X] critical issues
2. Fix [X] high priority issues
3. Verify fixes don't introduce new issues

**Future Improvements** (Optional):
1. [Recommendation]
2. [Recommendation]

---

## Review Metrics

- **Files Reviewed**: [X]
- **Review Time**: [X] minutes
- **Issues Found**: [X] total
- **Code Quality Score**: [X]/10
- **Security Posture**: [Strong/Good/Needs Work/Weak]
- **Test Coverage**: [X]% ([Above/Below] target)

---

## Next Steps

[If approved]:
✅ **Ready to Merge** - All critical issues resolved, high quality code

[If approved with comments]:
⚠️ **Approved with Comments** - Safe to merge, but consider addressing [X] high priority issues in follow-up

[If changes required]:
❌ **Changes Required** - [X] critical issues must be fixed before merge:
1. [Critical issue 1]
2. [Critical issue 2]
```

---

## Phase 5: Save Review Report & Communicate (2-3 min)

### Save Review Report

```bash
# Generate filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PR_NUMBER=[extracted from $ARGUMENTS]
REVIEW_FILE=".agency/reviews/pr-${PR_NUMBER}-review-${TIMESTAMP}.md"

# Create directory if needed
mkdir -p .agency/reviews
```

Write the unified report from Phase 4 to `$REVIEW_FILE` using Write tool.

### Present Summary to User

Provide concise summary:

```
## Code Review Complete: [PR/MR Title]

**Overall**: ✅ APPROVED / ⚠️ APPROVED WITH COMMENTS / ❌ CHANGES REQUIRED

**Issues Summary**:
- CRITICAL: [X] (must fix)
- HIGH: [X] (should fix)
- MEDIUM: [X] (consider fixing)
- LOW: [X] (optional)

**Review Aspects**:
- Security: [X] issues
- Quality: [X] issues
- Performance: [X] issues
- Testing: [X] issues
- Architecture: [X] issues

**Top Issues**:
1. [Critical/High issue 1]
2. [Critical/High issue 2]
3. [Critical/High issue 3]

**Detailed Report**: $REVIEW_FILE

**Next Steps**:
[Recommended actions]
```

### Update TodoWrite

Mark all review tasks as completed in TodoWrite.

---

## Multi-Provider Support

### GitHub Integration

```bash
# View PR
gh pr view 123

# View PR diff
gh pr diff 123

# Get changed files
gh pr view 123 --json files --jq '.files[].path'

# Add review comment
gh pr review 123 --comment --body "Review findings: ..."

# Request changes
gh pr review 123 --request-changes --body "Critical issues found..."

# Approve
gh pr review 123 --approve --body "LGTM! 🚀"
```

### GitLab Integration

```bash
# View MR
glab mr view 123

# View MR diff
glab mr diff 123

# Add MR comment
glab mr note 123 --message "Review findings: ..."
```

### Bitbucket Integration

```bash
# Use Bitbucket API
curl -X POST https://api.bitbucket.org/2.0/repositories/owner/repo/pullrequests/123/comments \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": {"raw": "Review findings..."}}'
```

### Local Files (No PR)

When reviewing local files without a PR:
- Create review report in `.agency/reviews/`
- Filename: `local-review-[filename]-[timestamp].md`
- Include git diff in report if available

---

## Review Decision Criteria

### ✅ APPROVED

All of the following must be true:
- Zero CRITICAL issues
- Zero HIGH issues (or all have acceptable explanations)
- Code quality score ≥ 7/10
- Test coverage ≥ 80% (or acceptable for change type)
- No security vulnerabilities
- Follows project standards

### ⚠️ APPROVED WITH COMMENTS

When:
- Zero CRITICAL issues
- 1-3 HIGH issues that are acceptable trade-offs
- Code quality score 5-7/10
- Test coverage 60-79%
- Minor security concerns (all addressed or mitigated)
- High priority items can be addressed in follow-up

### ❌ CHANGES REQUIRED

When any of the following are true:
- 1+ CRITICAL issues
- 4+ HIGH issues
- Code quality score < 5/10
- Test coverage < 60% for new code
- Security vulnerabilities present
- Breaking changes without migration path
- Does not follow project standards

---

## Error Handling

### If PR/MR Not Found

```
Error: PR/MR not found: $ARGUMENTS

Please check:
1. PR/MR number is correct
2. You have access to the repository
3. PR/MR is not deleted
4. CLI tool is installed (gh, glab, etc.)

Try:
- Full PR URL instead of number
- Different format (e.g., #123 vs 123)
```

### If No Changed Files

```
Error: No changed files found in $ARGUMENTS

This could mean:
1. PR/MR is empty
2. All changes have been reverted
3. Wrong PR/MR number

Cannot proceed with review of empty changeset.
```

### If Review Agent Fails

```
Warning: [Agent] review failed or incomplete

Error: [Error message]

Continuing with partial review from other agents...

Note: Review may be incomplete. Consider:
1. Re-running failed aspect manually
2. Manual review of [aspect] concerns
```

---

## Best Practices

1. **Review in Parallel**: Spawn all review agents at once for speed
2. **Focus on Critical/High**: Don't get lost in minor issues
3. **Be Specific**: Link to exact files and lines
4. **Provide Solutions**: Don't just identify problems, suggest fixes
5. **Recognize Good Work**: Note positive observations too
6. **Security First**: Never approve PRs with security issues
7. **Context Matters**: Consider the scope and purpose of the change
8. **Test Coverage**: Advocate for tests, but be reasonable

---

## Example Usage

```bash
# Review a GitHub PR by number
/agency:review 123

# Review a GitHub PR by URL
/agency:review https://github.com/owner/repo/pull/456

# Review specific files
/agency:review src/api/auth.ts

# Review a directory of changes
/agency:review src/features/authentication/

# Review local uncommitted changes
/agency:review .
```

---

## Tips

- **Run early and often**: Review during development, not just before merge
- **Parallel reviews are fast**: Multi-aspect review in 10-30 minutes
- **Trust the agents**: Specialized reviewers catch domain-specific issues
- **Fix critical first**: Don't bikeshed formatting when security issues exist
- **Learn from reviews**: Patterns in findings suggest areas for improvement

---

## Related Commands

- `/agency:work [issue]` - Full development workflow with built-in review
- `/agency:implement [plan]` - Includes code review phase
- `/agency:test [component]` - Generate tests to improve coverage
