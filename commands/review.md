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

<!-- Component: prompts/progress/todo-initialization.md -->
## Initialize Progress Tracking

Use TodoWrite tool to create todo list:

```javascript
TodoWrite({
  todos: [
    {
      content: "Detect review target and fetch details",
      status: "in_progress",
      activeForm: "Detecting review target and fetching details"
    },
    {
      content: "Analyze changed files and complexity",
      status: "pending",
      activeForm: "Analyzing changed files and complexity"
    },
    {
      content: "Launch parallel multi-aspect reviews",
      status: "pending",
      activeForm: "Launching parallel multi-aspect reviews"
    },
    {
      content: "Aggregate and categorize findings",
      status: "pending",
      activeForm: "Aggregating and categorizing findings"
    },
    {
      content: "Generate and save review report",
      status: "pending",
      activeForm: "Generating and saving review report"
    }
  ]
});
```

---

## Critical Instructions

<!-- Component: prompts/specialist-selection/skill-activation.md -->
### 1. Activate Code Review Standards

**IMMEDIATELY** activate the code review standards skill:
```
Use the Skill tool to activate: code-review-standards
```

This skill contains critical review patterns, security checklists, and quality standards you MUST follow.

---

## Phase 1: Review Target Detection (2-3 min)

<!-- Component: prompts/issue-management/github-issue-fetch.md (adapted for PRs) -->
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

<!-- Component: prompts/issue-management/issue-metadata-extraction.md -->
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

<!-- Component: prompts/progress/phase-tracking.md -->
**Update Progress**:
```javascript
TodoWrite({
  todos: [
    {content: "Detect review target and fetch details", status: "completed", activeForm: "..."},
    {content: "Analyze changed files and complexity", status: "in_progress", activeForm: "Analyzing changed files and complexity"},
    {content: "Launch parallel multi-aspect reviews", status: "pending", activeForm: "..."},
    {content: "Aggregate and categorize findings", status: "pending", activeForm: "..."},
    {content: "Generate and save review report", status: "pending", activeForm: "..."}
  ]
});
```

## Phase 2: Changed Files Analysis (3-5 min)

<!-- Component: prompts/context/framework-detection.md (adapted for file categorization) -->
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

<!-- Component: prompts/progress/phase-tracking.md -->
**Update Progress**:
```javascript
TodoWrite({
  todos: [
    {content: "Detect review target and fetch details", status: "completed", activeForm: "..."},
    {content: "Analyze changed files and complexity", status: "completed", activeForm: "..."},
    {content: "Launch parallel multi-aspect reviews", status: "in_progress", activeForm: "Launching parallel multi-aspect reviews"},
    {content: "Aggregate and categorize findings", status: "pending", activeForm: "..."},
    {content: "Generate and save review report", status: "pending", activeForm: "..."}
  ]
});
```

## Phase 3: Parallel Multi-Aspect Review (10-30 min)

<!-- Component: prompts/code-review/reality-checker-spawn.md (adapted for multi-aspect review) -->
### Launch Review Agents in Parallel

**IMPORTANT**: Spawn ALL relevant agents in parallel (single message, multiple Task calls) for maximum efficiency.

**Review aspects to spawn based on file categorization**:
- **Security Review** (ALWAYS) - Use backend-architect specialist
- **Quality Review** (ALWAYS) - Use testing-reality-checker specialist
- **Performance Review** (IF backend/API/frontend performance-critical changes) - Use performance-benchmarker specialist
- **Testing Review** (IF new features or test coverage < 80%) - Use test-results-analyzer specialist
- **Architecture Review** (IF > 20 files changed or major refactoring) - Use appropriate specialist based on domain

#### Review Prompt Template (Apply to Each Aspect)

For each review aspect, use the Task tool with this structure:

```bash
Task tool with:
- subagent_type: [specialist-for-aspect]
- description: "[Aspect] review for PR $ARGUMENTS"
- prompt: "Perform [aspect] review focusing on:

  [Aspect-specific checklist from reality-checker-spawn.md]:
  - Security: OWASP Top 10, input validation, authentication, secrets
  - Quality: Readability, bugs, best practices, type safety
  - Performance: Database queries, bundle size, algorithm efficiency
  - Testing: Coverage, test quality, missing tests
  - Architecture: Patterns, breaking changes, scalability

  Files to review: [filtered-by-aspect]

  Severity levels:
  - CRITICAL: Must fix before merge
  - HIGH: Should fix before merge
  - MEDIUM: Consider fixing
  - LOW: Nice to have

  Report CRITICAL and HIGH issues ONLY."
```

**Key Review Focus Areas** (from reality-checker-spawn.md):

**Security** (backend-architect):
- OWASP Top 10 vulnerabilities
- Input validation, SQL injection, XSS, CSRF
- Authentication/authorization checks
- Secrets management, password hashing

**Quality** (testing-reality-checker):
- Code readability and maintainability
- Bugs and logic errors
- Type safety, error handling
- Code standards and best practices

**Performance** (performance-benchmarker):
- Database query efficiency (N+1, indexing)
- API response times, caching
- Frontend bundle size, re-renders
- Algorithm complexity

**Testing** (test-results-analyzer):
- Test coverage (80%+ target)
- Test quality and patterns
- Missing tests for critical paths
- Edge case and error coverage

**Architecture** (domain-specialist):
- Pattern consistency
- Separation of concerns
- Breaking changes handling
- Scalability considerations

### Wait for All Reviews to Complete

All review agents run in parallel. Wait for all to finish before proceeding to aggregation.

---

<!-- Component: prompts/progress/phase-tracking.md -->
**Update Progress**:
```javascript
TodoWrite({
  todos: [
    {content: "Detect review target and fetch details", status: "completed", activeForm: "..."},
    {content: "Analyze changed files and complexity", status: "completed", activeForm: "..."},
    {content: "Launch parallel multi-aspect reviews", status: "completed", activeForm: "..."},
    {content: "Aggregate and categorize findings", status: "in_progress", activeForm: "Aggregating and categorizing findings"},
    {content: "Generate and save review report", status: "pending", activeForm: "..."}
  ]
});
```

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

Organize findings by severity and file for clarity.

<!-- Component: prompts/reporting/summary-template.md (adapted for code review) -->
### Generate Unified Report

Use the following template structure for the review report:

**File**: `.agency/reviews/pr-[number]-review-[timestamp].md`

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
- Security: [X] issues
- Quality: [X] issues
- Performance: [X] issues
- Testing: [X] issues
- Architecture: [X] issues

**Severity Breakdown**:
- CRITICAL: [X] (must fix before merge)
- HIGH: [X] (should fix before merge)
- MEDIUM: [X] (consider fixing)
- LOW: [X] (optional improvements)

---

## Critical Issues (Must Fix Before Merge)

[For each critical issue]:
### [N]. [Aspect] [File:Line] - [Issue Title]

**Severity**: CRITICAL
**File**: `path/to/file.ts:123`
**Issue**: [Description]
**Risk**: [Impact if not fixed]
**Recommendation**: [How to fix]

---

## High Priority Issues (Should Fix Before Merge)

[Same structure as Critical Issues]

---

## Medium/Low Priority Issues

[Condensed format]:
- **[File:Line]** - [Brief issue] → [Brief fix]

---

## File-by-File Breakdown

### `[file-path]` ([+X, -Y] lines)

**Issues Found**: [X]
**Strengths**: [Positive observations]

---

## Positive Observations

- ✅ [Good practice observed]

---

## Review Metrics

- **Files Reviewed**: [X]
- **Review Time**: [X] minutes
- **Issues Found**: [X] total
- **Code Quality Score**: [X]/10
- **Security Posture**: [Strong/Good/Needs Work/Weak]

---

<!-- Component: prompts/reporting/next-steps-template.md -->
## Next Steps

[Based on review decision criteria]:

**✅ APPROVED**: Ready to merge
**⚠️ APPROVED WITH COMMENTS**: Safe to merge with noted issues
**❌ CHANGES REQUIRED**: Fix [X] critical issues before merge
```

---

<!-- Component: prompts/progress/phase-tracking.md -->
**Update Progress**:
```javascript
TodoWrite({
  todos: [
    {content: "Detect review target and fetch details", status: "completed", activeForm: "..."},
    {content: "Analyze changed files and complexity", status: "completed", activeForm: "..."},
    {content: "Launch parallel multi-aspect reviews", status: "completed", activeForm: "..."},
    {content: "Aggregate and categorize findings", status: "completed", activeForm: "..."},
    {content: "Generate and save review report", status: "in_progress", activeForm: "Generating and saving review report"}
  ]
});
```

## Phase 5: Save Review Report & Communicate (2-3 min)

<!-- Component: prompts/reporting/artifact-listing.md -->
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
[Recommended actions based on next-steps-template.md]
```

<!-- Component: prompts/progress/completion-reporting.md -->
### Update TodoWrite

Mark all review tasks as completed:

```javascript
TodoWrite({
  todos: [
    {content: "Detect review target and fetch details", status: "completed", activeForm: "..."},
    {content: "Analyze changed files and complexity", status: "completed", activeForm: "..."},
    {content: "Launch parallel multi-aspect reviews", status: "completed", activeForm: "..."},
    {content: "Aggregate and categorize findings", status: "completed", activeForm: "..."},
    {content: "Generate and save review report", status: "completed", activeForm: "Generating and saving review report"}
  ]
});
```

---

<!-- Component: prompts/git/pr-creation.md (adapted for review submission) -->
## Multi-Provider Support

**GitHub**: Use `gh pr review` to submit review findings
**GitLab**: Use `glab mr note` to add review comments
**Bitbucket**: Use API or web interface to submit review
**Local Files**: Save review report to `.agency/reviews/local-review-[filename]-[timestamp].md`

---

<!-- Component: prompts/reporting/next-steps-template.md (review decision matrix) -->
## Review Decision Criteria

**✅ APPROVED**: 0 critical, 0 high issues, coverage ≥80%, quality ≥7/10, no security vulnerabilities

**⚠️ APPROVED WITH COMMENTS**: 0 critical, 1-3 high issues (acceptable trade-offs), coverage 60-79%, quality 5-7/10

**❌ CHANGES REQUIRED**: 1+ critical OR 4+ high issues OR coverage <60% OR quality <5/10 OR security vulnerabilities present

---

<!-- Component: prompts/error-handling/tool-execution-failure.md -->
## Error Handling

### If PR/MR Not Found

**Detection**: gh/glab CLI returns 404 or "not found" error

**User Message**:
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

**Recovery**: Use AskUserQuestion to get corrected PR number or URL.

### If No Changed Files

**User Message**:
```
Error: No changed files found in $ARGUMENTS

This could mean:
1. PR/MR is empty
2. All changes have been reverted
3. Wrong PR/MR number

Cannot proceed with review of empty changeset.
```

<!-- Component: prompts/error-handling/partial-failure-recovery.md -->
### If Review Agent Fails

**Strategy**: Continue with partial review from successful agents.

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
