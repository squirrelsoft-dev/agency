---
description: Work on any issue end-to-end with intelligent orchestration (auto-detects GitHub/Jira)
argument-hint: issue number, URL, or 'next'
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion
---

# Work on Issue: $ARGUMENTS

Implement a GitHub or Jira issue end-to-end using the Agency orchestrator and specialized agents.

## Your Mission

Work on issue: **$ARGUMENTS**

Follow the full development lifecycle: fetch → plan → review → implement → test → code review → commit → PR.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

---

<!-- Component: prompts/progress/todo-initialization.md -->
## Phase 0: Initialize Progress Tracking

Use TodoWrite tool to create todo list:

```javascript
[
  {
    "content": "Fetch and analyze issue",
    "status": "in_progress",
    "activeForm": "Fetching and analyzing issue"
  },
  {
    "content": "Set up repository and branch",
    "status": "pending",
    "activeForm": "Setting up repository and branch"
  },
  {
    "content": "Generate implementation plan",
    "status": "pending",
    "activeForm": "Generating implementation plan"
  },
  {
    "content": "Select specialist(s) and get approval",
    "status": "pending",
    "activeForm": "Selecting specialist(s) and getting approval"
  },
  {
    "content": "Implement changes via specialist",
    "status": "pending",
    "activeForm": "Implementing changes via specialist"
  },
  {
    "content": "Run quality gates",
    "status": "pending",
    "activeForm": "Running quality gates"
  },
  {
    "content": "Conduct code review",
    "status": "pending",
    "activeForm": "Conducting code review"
  },
  {
    "content": "Commit and create pull request",
    "status": "pending",
    "activeForm": "Committing and creating pull request"
  }
]
```

---

<!-- Component: prompts/issue-management/github-issue-fetch.md -->
<!-- Component: prompts/issue-management/jira-issue-fetch.md -->
<!-- Component: prompts/issue-management/issue-metadata-extraction.md -->
## Phase 1: Issue Fetch & Analysis

### Detect Issue Source

Analyze `$ARGUMENTS` to determine the source:

**GitHub Issue** if:
- Numeric only: `123`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- `next` keyword (find next GitHub issue)

**Jira Issue** if:
- Jira key format: `PROJ-123`
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`

### Fetch Issue Details

**For GitHub**:
```bash
# Numeric issue or URL
gh issue view $ARGUMENTS --json number,title,body,state,labels,assignees,milestone

# Find next issue (if $ARGUMENTS is "next")
gh issue list --assignee @me --state open --limit 1 --json number,title,body,labels
```

**For Jira**:
```bash
# Extract issue key from URL if needed
ISSUE_KEY=$(echo "$ARGUMENTS" | grep -oP '[A-Z]+-\d+')

# Fetch issue details
acli jira --action getIssue \
  --issue "$ISSUE_KEY" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,issuetype,assignee,labels"

# Find next issue (if $ARGUMENTS is "next")
acli jira --action getIssueList \
  --jql "sprint in openSprints() AND assignee = currentUser() AND status != Done" \
  --maxResults 1 \
  --outputFormat 2
```

### Extract Key Information

From the issue, identify:
- **Title/Summary**: What is being requested?
- **Description**: Detailed requirements
- **Acceptance Criteria**: How to verify success
- **Labels/Type**: Bug, feature, enhancement, etc.
- **Priority**: Urgency level
- **Dependencies**: Related issues or blockers

**Parse structured sections** from issue description:
- Acceptance Criteria (look for `## Acceptance Criteria`, `## AC`, `## Success Criteria`)
- Technical Requirements (look for `## Technical Requirements`, `## Implementation Details`)
- Context/Background (look for `## Description`, `## Background`, `## Problem`)

**Error Handling**:
- If issue not found, verify issue number/key and permissions
- If issue lacks detail, use AskUserQuestion to clarify requirements
- If issue is closed, warn user and ask whether to proceed

---

<!-- Component: prompts/git/branch-creation.md -->
## Phase 2: Repository Setup

### Pre-Flight Checks

```bash
# 1. Check current branch
git branch --show-current

# 2. Check for uncommitted changes
git status --porcelain

# 3. Fetch latest changes
git fetch origin

# 4. Checkout and update main branch
git checkout main
git pull origin main
```

### Create Feature Branch

```bash
# Determine branch prefix based on issue type
# For GitHub: Check labels (bug → fix/, feature → feat/)
# For Jira: Check issuetype (Bug → fix/, Story → feat/, Task → feat/)

# Create feature branch
# Format: feat/issue-NUMBER or feat/JIRA-KEY or fix/issue-NUMBER
git checkout -b feat/issue-$ARGUMENTS

# Or for bug fixes:
git checkout -b fix/issue-$ARGUMENTS
```

**Branch Naming Rules**:
- Use lowercase
- Use hyphens, not underscores
- GitHub: `feat/issue-123` or `fix/issue-123`
- Jira: `feat/PROJ-123` or `fix/PROJ-123`

**Validation**:
```bash
# Verify branch created
git branch --show-current

# Verify clean state
git status
```

---

## Phase 3: Planning & Architecture

### Create Implementation Plan

Analyze the issue and create a detailed plan covering:

**What to Build**:
- Files to create or modify
- Components/functions needed
- Data models or API endpoints
- UI changes (if applicable)

**Dependencies**:
- External libraries needed
- API integrations
- Database changes

**Implementation Steps**:
1. Step-by-step breakdown
2. Order of operations
3. Testing strategy

**Risks & Edge Cases**:
- Potential issues
- Edge cases to handle
- Performance considerations

<!-- Component: prompts/specialist-selection/multi-specialist-routing.md -->
### Select Specialist(s)

Based on the issue type and plan analysis, select the appropriate specialist(s):

| Issue Type | Specialist |
|------------|----------------|
| **Backend/API** | Backend Architect |
| **Frontend/UI** | Frontend Developer or ArchitectUX |
| **Mobile** | Mobile App Builder |
| **DevOps/Infrastructure** | DevOps Automator |
| **AI/ML** | AI Engineer |
| **Performance** | Performance Benchmarker |
| **General** | Plan agent or Senior Developer |

**Multi-Specialist Detection**:
If plan mentions multiple domains (e.g., "backend API" AND "frontend UI"), enable multi-specialist mode.

**Execution Strategy**:
- **Sequential**: When dependencies exist (e.g., frontend needs backend API)
  - Order: Backend → Frontend → Integration Review
- **Parallel**: When work is independent (e.g., separate admin dashboard and API)

<!-- Component: prompts/specialist-selection/user-approval.md -->
### Get User Approval

**For Single Specialist**:
```
Use AskUserQuestion tool:

"I've analyzed the plan and selected **[SPECIALIST]** based on these keywords: [KEYWORD_LIST].

Proceed with [SPECIALIST] for implementation?"

Options:
- Yes, proceed with [SPECIALIST] (Recommended)
- No, use a different specialist
```

**For Multi-Specialist**:
```
Use AskUserQuestion tool:

"**Multi-Specialist Work Detected**

Specialists Needed:
- ✅ [SPECIALIST_1] (Score: [X.X]) - [KEY_RESPONSIBILITIES]
- ✅ [SPECIALIST_2] (Score: [Y.Y]) - [KEY_RESPONSIBILITIES]

Execution Strategy: [Sequential/Parallel]
- Reason: [DEPENDENCY_REASON or INDEPENDENCE_REASON]
[IF Sequential]
- Order: [SPECIALIST_1] → [SPECIALIST_2]

Proceed with this plan?"

Options:
- Yes, proceed (Recommended)
- Run in parallel instead (faster, riskier) [IF currently sequential]
- Run sequentially instead (safer) [IF currently parallel]
- Modify specialist selection
```

**Present the final plan to the user**:
```markdown
## Implementation Plan for Issue #$ARGUMENTS

### Summary
[Brief overview of what will be implemented]

### Files to Create/Modify
- `path/to/file1.ts` - [purpose]
- `path/to/file2.ts` - [purpose]

### Key Implementation Decisions
1. [Decision 1 and rationale]
2. [Decision 2 and rationale]

### Testing Strategy
[How we'll verify this works]

**Ready to proceed with implementation?**
```

**STOP HERE until user approves the plan.**

---

## Phase 4: Implementation (Delegated to Specialist)

### Spawn Implementation Agent

Use the Task tool to spawn the implementation agent:

```
Task: Implement issue #$ARGUMENTS

Agent: [selected specialist]

Context:
- Issue details: [from Phase 1]
- Approved implementation plan: [from Phase 3]
- Branch: feat/issue-$ARGUMENTS

Instructions:
1. Implement the solution according to the approved plan
2. Activate relevant skills for technology expertise:
   - `nextjs-16-expert` (for Next.js)
   - `typescript-5-expert` (for TypeScript)
   - `tailwindcss-4-expert` (for Tailwind CSS)
   - `supabase-latest-expert` (for Supabase)
   - `next-auth-beta-expert` (for NextAuth)
   - [other relevant skills]
3. Write clean, maintainable code following best practices
4. Handle edge cases and error scenarios
5. Add appropriate logging and error handling

**Do NOT commit changes** - I will handle verification and commit.

Please implement the solution now.
```

**Wait for the implementation agent to complete.**

---

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->
## Phase 5: Verification & Quality Gates

Execute quality gates in sequence. **Do NOT skip any gate.**

### Gate 1: Build (CRITICAL)

```bash
# For Next.js/React projects
npm run build

# For TypeScript projects
npm run type-check

# For general Node.js
npm run build || npm run compile
```

**Quality Standard**: Build MUST pass

**On Failure**:
1. Read build errors carefully
2. Fix critical compilation issues
3. Re-run build
4. **BLOCK** until build passes

### Gate 2: Type Check (CRITICAL)

```bash
# TypeScript projects
npm run type-check || npx tsc --noEmit
```

**Quality Standard**: Type check MUST pass

**On Failure**:
1. Analyze type errors
2. Fix type mismatches
3. Re-run type check
4. **BLOCK** until type check passes

### Gate 3: Linter (HIGH PRIORITY)

```bash
# ESLint
npm run lint

# Auto-fix when possible
npm run lint -- --fix
```

**Quality Standard**:
- Linting errors MUST be fixed
- Warnings are acceptable but should be minimized

**On Failure**:
1. Review linting errors
2. Fix errors (auto-fix when possible)
3. Re-run linter
4. **BLOCK** on errors, proceed with warnings (note them)

### Gate 4: Tests (CRITICAL)

```bash
# Run all tests
npm test

# Or specific test commands
npm run test:unit
npm run test:integration
npm run test:e2e
```

**Quality Standard**: All tests MUST pass

**On Failure**:
1. Analyze test failures carefully
2. Fix code or update tests appropriately
3. Re-run tests
4. **BLOCK** until all tests pass

### Gate 5: Test Coverage (RECOMMENDED)

```bash
# Generate coverage report
npm run test:coverage || npm test -- --coverage
```

**Quality Standard**: Target 80%+ coverage

**On Low Coverage (< 80%)**:
1. Note coverage gaps in report
2. Recommend adding tests
3. **DO NOT BLOCK** - user decides acceptability
4. Document coverage in summary

---

<!-- Component: prompts/code-review/reality-checker-spawn.md -->
## Phase 6: Code Review

Spawn a code review agent to review the changes:

```
Task: Code review for issue #$ARGUMENTS

Agent: Reality Checker

Context:
- Issue: [issue details]
- Changes made: [summary]

Instructions:
Review the implementation for:

**Plan Compliance**:
- All requirements from the plan implemented
- No extra features added beyond plan scope
- Success criteria met
- All specified files created/modified

**Code Quality**:
- No obvious bugs or logic errors
- Follows project coding standards
- Proper error handling
- No hardcoded values that should be configurable
- Efficient algorithms and data structures

**Security**:
- No SQL injection vulnerabilities
- No XSS vulnerabilities
- No exposed secrets or credentials
- Proper input validation
- Authentication/authorization checks

**Performance**:
- No obvious performance issues
- No unnecessary re-renders (React)
- Proper database indexing (if applicable)
- Efficient queries and data fetching

**Testing**:
- Tests adequately cover the implementation
- Edge cases tested
- Error paths tested

**Files to review**: [list of modified/created files]

Provide findings with severity levels:
- **CRITICAL**: Must fix before merge (security, data loss, crashes)
- **HIGH**: Should fix before merge (bugs, incorrect behavior)
- **MEDIUM**: Consider fixing (code quality, performance)
- **LOW**: Nice to have (style, minor improvements)

**Focus on CRITICAL and HIGH severity issues only.**
```

**Handle Review Findings**:

**CRITICAL or HIGH issues found**:
1. Read review findings carefully
2. Fix each critical/high issue
3. Re-run quality gates if changes are significant
4. Re-run reality-checker to verify fixes
5. **Maximum 3 fix iterations** - escalate to user after that

**MEDIUM or LOW issues**:
- Document in implementation summary
- User decides whether to address
- Don't block completion

---

<!-- Component: prompts/git/commit-formatting.md -->
<!-- Component: prompts/git/pr-creation.md -->
## Phase 7: Completion & PR Creation

### Stage and Review Changes

```bash
# See what changed
git status

# Review the diff
git diff

# Stage changes
git add -A

# Review staged changes
git diff --cached
```

### Create Commit

Use conventional commit format:

```bash
git commit -m "$(cat <<'EOF'
<type>(scope): <description>

<body explaining what and why>

Closes #$ARGUMENTS
EOF
)"
```

**Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `docs`: Documentation
- `test`: Adding tests
- `chore`: Maintenance

**Example**:
```
feat(auth): add OAuth login support

Implemented OAuth authentication flow using GitHub provider.
Added login/logout buttons to navigation.
Configured session management with NextAuth.

Closes #123
```

**Quality Checklist**:
- [ ] Changes are logical and atomic
- [ ] Message follows conventional commit format
- [ ] Subject is clear and under 50 characters
- [ ] No secrets or sensitive data included
- [ ] Only intentional changes staged
- [ ] Issue reference included in footer

### Push Branch

```bash
git push -u origin feat/issue-$ARGUMENTS
```

### Create Pull Request

**Analyze PR Context First**:
```bash
# Review all commits in the branch
git log main..HEAD --oneline

# View full diff from base branch
git diff main...HEAD

# Check files changed
git diff --name-status main...HEAD
```

**CRITICAL**: Analyze ALL commits, not just the latest one!

**Create PR with GitHub CLI**:
```bash
gh pr create \
  --title "feat(scope): <brief description>" \
  --body "$(cat <<'EOF'
## Summary
- [Brief summary of what changed and WHY]
- [1-3 bullet points]

## Changes

### Backend
- [Change 1]
- [Change 2]

### Frontend
- [Change 1]
- [Change 2]

### Tests
- [Test additions/updates]

## Test Plan

- [ ] Step 1: [How to test]
- [ ] Step 2: [Expected result]
- [ ] Step 3: [Edge cases]

## Related Issues
Closes #$ARGUMENTS

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] No secrets committed
- [x] All quality gates passed
EOF
)"
```

**For Jira** (using GitHub with Jira integration):
```bash
gh pr create --title "[$ARGUMENTS]: <brief description>" --body "..."
```

**PR Pre-Flight Checks**:
- Verify current branch is NOT main/master
- Check for uncommitted changes
- Verify remote tracking exists
- Check if up to date with remote
- Verify no PR already exists

---

<!-- Component: prompts/reporting/summary-template.md -->
## Phase 8: Report Completion

Update the todo list to mark all tasks complete.

Report to the user:

```markdown
## Issue #$ARGUMENTS Complete

**Pull Request Created**: [PR URL]

**Summary**:
[Brief summary of what was implemented]

**Changes**:
- [File 1]: [Changes]
- [File 2]: [Changes]

**Verification**:
- ✅ Build passing
- ✅ Tests passing (X tests, Y% coverage)
- ✅ Linting passing
- ✅ Code review complete

**Next Steps**:
- PR is ready for review
- Assigned reviewers will be notified
- Merge when approved

[Any caveats or follow-up items]
```

---

## Error Handling

### If Phase Fails

**Planning Failure**:
- Ask user for clarification
- Provide options to modify or abandon

**Implementation Failure**:
- Review error from implementation agent
- Either fix directly or re-delegate with adjusted instructions

**Verification Failure**:
- Fix issues and re-run verification
- Don't proceed to PR until all gates pass

**PR Creation Failure**:
- Check GitHub/Jira authentication
- Verify permissions
- Retry or provide manual instructions

### If Issue is Unclear

Use AskUserQuestion to clarify:
- What exactly should be implemented?
- What are the acceptance criteria?
- Are there specific technical requirements?
- Any constraints or preferences?

---

## Important Notes

- **Always wait for user approval** before starting implementation
- **The implementation agent does the coding**, not you (the orchestrator)
- **Activate relevant skills** to enhance agent knowledge
- **Keep the user informed** at each phase
- **Don't leave the repository in a broken state** - always ensure build/tests pass
- **Use TodoWrite** to track progress throughout

---

## Skills to Reference

Activate and reference these skills as needed:
- `agency-workflow-patterns` - Orchestration patterns (REQUIRED)
- `github-workflow-best-practices` - GitHub workflows, branching, PRs
- `code-review-standards` - Review criteria
- `testing-strategy` - Testing best practices

## Related Commands

- `/agency:plan` - Planning only (no implementation)
- `/agency:review` - Code review only
- `/agency:test` - Test generation only

---

**Remember**: You are the orchestrator. Coordinate the work, but delegate implementation to specialists. Keep context lean and focused on coordination.
