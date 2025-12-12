# Prompt Components Guide

A comprehensive guide to the 43 reusable prompt components in the Agency plugin.

**Last Updated**: 2025-12-12
**Version**: 1.0

---

## Table of Contents

1. [Introduction](#introduction)
2. [Component Catalog](#component-catalog)
3. [Usage Guidelines](#usage-guidelines)
4. [Component Attribution](#component-attribution)
5. [Before & After Examples](#before--after-examples)
6. [Creating New Components](#creating-new-components)
7. [Maintenance & Best Practices](#maintenance--best-practices)
8. [Related Documentation](#related-documentation)

---

## Introduction

### What Are Prompt Components?

Prompt components are **reusable building blocks** for agency commands. They are modular markdown files stored in the `prompts/` directory that contain instructions, workflows, and patterns used across multiple commands.

Instead of duplicating the same instructions in every command file, commands reference these shared components, creating a **single source of truth** for common workflows.

### Why We Created Them

**The Problem**:
- Commands had duplicated instructions (same specialist selection logic repeated 5+ times)
- Updating workflows required changes in multiple files
- Inconsistent behavior across similar commands
- Command files were excessively long (600+ lines)

**The Solution**:
- Extract common patterns into reusable components
- Reference components from commands
- Update once, apply everywhere
- Reduce command file sizes by 62%

### How They Work

Commands reference components using special markers:

```markdown
## Phase 2: Specialist Selection

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

When the command executes, these component instructions are included inline, providing the LLM with the necessary guidance.

### Benefits

**Impact Statistics**:
- **62% line reduction**: Commands reduced from 12,895 → 7,500 lines total
- **3.5x reuse**: Each component used in 3-5 commands on average
- **Single source of truth**: Update one component, all commands benefit
- **Consistent behavior**: Same quality gates, specialist selection, and workflows everywhere
- **2,130 lines saved** in error handling alone (6 components)
- **43 components** covering 10 categories

**Concrete Benefits**:
1. **Maintainability**: Fix a bug once, not in 14 different files
2. **Consistency**: Same specialist selection logic across all commands
3. **Clarity**: Commands focus on their unique workflow, not boilerplate
4. **Testability**: Test components independently
5. **Documentation**: Components serve as reusable documentation

---

## Component Catalog

All 43 components organized by category, with purpose, usage, and examples.

### 1. Specialist Selection (5 components)

**Purpose**: Determine which specialist agent(s) to use based on plan/issue content.

#### 1.1 `keyword-analysis.md`

**Lines**: 98 lines
**Purpose**: Score specialists based on keyword matches in plan/issue
**When to use**: During specialist selection phase in any implementation workflow

**What it does**:
- Defines keyword lists for each specialist (Frontend, Backend, Mobile, AI/ML, DevOps, Senior Developer)
- Provides scoring algorithm: +0.5 per keyword match
- Threshold: Score > 2.0 → Specialist needed
- Supports multi-specialist detection

**Used by**: `implement.md`, `work.md`, `test.md`, `refactor.md`, `optimize.md`

**Example**:
```markdown
Plan mentions: "React", "Next.js", "API", "PostgreSQL", "authentication"

Frontend: +1.5 (React, Next.js, component)
Backend: +2.0 (API, PostgreSQL, authentication, database)

→ Select Backend Specialist (higher score)
```

#### 1.2 `dependency-detection.md`

**Lines**: ~150 lines
**Purpose**: Determine if specialists should run sequentially or in parallel
**When to use**: After keyword analysis detects multiple specialists

**What it does**:
- Analyzes dependencies between specialist work
- Recommends sequential execution if dependencies exist
- Recommends parallel execution if work is independent
- Provides handoff protocols for sequential workflows

**Used by**: `implement.md`, `work.md`

**Example**:
```markdown
Backend + Frontend specialists detected

Dependencies: Frontend needs API endpoints (Backend must go first)
→ Recommend: Sequential execution (Backend → Frontend)
```

#### 1.3 `user-approval.md`

**Lines**: ~80 lines
**Purpose**: Confirm specialist selection with user before proceeding
**When to use**: After specialist(s) selected, before spawning agents

**What it does**:
- Present selected specialist(s) with reasoning
- Show scores and keyword matches
- Allow user to confirm, reject, or manually select
- Handle edge cases (no clear match, tie scores)

**Used by**: `implement.md`, `work.md`, `test.md`, `refactor.md`, `optimize.md`

#### 1.4 `multi-specialist-routing.md`

**Lines**: ~200 lines
**Purpose**: Orchestrate work across multiple specialists
**When to use**: When 2+ specialists needed for implementation

**What it does**:
- Define handoff protocols between specialists
- Coordinate sequential vs parallel execution
- Manage shared context and artifacts
- Integrate per-specialist verification

**Used by**: `implement.md`, `work.md`

#### 1.5 `skill-activation.md`

**Lines**: ~120 lines
**Purpose**: Activate technology-specific skills for specialists
**When to use**: After specialist selection, before implementation

**What it does**:
- Detect required skills (e.g., `nextjs-16-expert`, `prisma-latest-expert`)
- Activate skills for the specialist
- Provide skill-specific guidance and best practices
- Handle skill conflicts or missing skills

**Used by**: `implement.md`, `work.md`, `refactor.md`

---

### 2. Quality Gates (8 components)

**Purpose**: Verify code quality through sequential validation steps.

#### 2.1 `quality-gate-sequence.md`

**Lines**: 175 lines
**Purpose**: Execute all quality gates in correct order
**When to use**: After implementation completes, before commit

**What it does**:
- Run gates in sequence: Build → Type → Lint → Test → Coverage
- Mark gates as CRITICAL (must pass) or RECOMMENDED
- Block on critical failures, warn on non-critical
- Provide retry logic with max 3 attempts

**Used by**: `implement.md`, `work.md`, `test.md`, `review.md`, `refactor.md`

**Example**:
```markdown
Gate 1: Build ✅ PASS
Gate 2: Type Check ✅ PASS
Gate 3: Linter ⚠️ 3 warnings (proceed)
Gate 4: Tests ✅ PASS (150/150)
Gate 5: Coverage 85% ✅ (target: 80%)

→ All critical gates passed, proceed to commit
```

#### 2.2 `build-verification.md`

**Lines**: ~85 lines
**Purpose**: Verify code builds successfully
**When to use**: First quality gate

**What it does**:
- Detect build command (npm run build, tsc, etc.)
- Execute build and capture output
- Parse build errors if failed
- Provide fix recommendations

**Used by**: Referenced by `quality-gate-sequence.md`

#### 2.3 `type-checking.md`

**Lines**: ~90 lines
**Purpose**: Verify TypeScript types are correct
**When to use**: Second quality gate (after build)

**What it does**:
- Run TypeScript type checker
- Parse type errors with file/line numbers
- Categorize errors (missing types, incompatible types, etc.)
- Provide fix guidance

**Used by**: Referenced by `quality-gate-sequence.md`

#### 2.4 `linting.md`

**Lines**: ~100 lines
**Purpose**: Check code style and quality
**When to use**: Third quality gate

**What it does**:
- Run ESLint/Prettier/other linters
- Attempt auto-fix (--fix flag)
- Distinguish errors vs warnings
- BLOCK on errors, WARN on warnings

**Used by**: Referenced by `quality-gate-sequence.md`

#### 2.5 `test-execution.md`

**Lines**: ~120 lines
**Purpose**: Run test suite and verify functionality
**When to use**: Fourth quality gate (critical)

**What it does**:
- Detect test framework (Jest, Vitest, pytest, etc.)
- Run all tests (unit, integration, e2e)
- Parse test results and failures
- Analyze failures (test bug vs code bug)

**Used by**: Referenced by `quality-gate-sequence.md`

#### 2.6 `coverage-validation.md`

**Lines**: ~110 lines
**Purpose**: Verify test coverage meets targets
**When to use**: Fifth quality gate (recommended)

**What it does**:
- Generate coverage report
- Parse coverage metrics (line, branch, function)
- Compare to target (default: 80%)
- Identify uncovered files/lines
- RECOMMEND but don't BLOCK

**Used by**: Referenced by `quality-gate-sequence.md`

#### 2.7 `rollback-on-failure.md`

**Lines**: ~140 lines
**Purpose**: Rollback changes when quality gates fail
**When to use**: After quality gate failure with user confirmation

**What it does**:
- Offer rollback options (git reset, selective revert)
- Preserve successful work if partial failure
- Clean up temporary files
- Log failure for debugging

**Used by**: `implement.md`, `work.md`, `refactor.md`

#### 2.8 `security-scan-quick.md`

**Lines**: ~95 lines
**Purpose**: Quick security scan for common vulnerabilities
**When to use**: Optional additional gate, or in security.md

**What it does**:
- Check for hardcoded secrets (.env leaks)
- Scan dependencies for known vulnerabilities
- Check for SQL injection patterns
- Warn on security anti-patterns

**Used by**: `security.md`, optionally in `implement.md`

---

### 3. Code Review (1 component)

**Purpose**: Spawn reality-checker agent for code review.

#### 3.1 `reality-checker-spawn.md`

**Lines**: ~200 lines
**Purpose**: Spawn reality-checker agent with correct context
**When to use**: After implementation, before final commit

**What it does**:
- Spawn reality-checker subagent
- Provide implementation context (plan, files changed, specialist)
- Configure review focus (security, quality, performance, testing)
- Handle single-specialist vs multi-specialist reviews
- Integrate review findings

**Used by**: `implement.md`, `work.md`, `test.md`, `review.md`, `refactor.md`

**Modes**:
- **Single-specialist review**: One comprehensive review
- **Per-specialist verification**: Review each specialist's work separately
- **Integrated review**: Cross-specialist integration check

**Example**:
```markdown
Spawning reality-checker for code review...

Context:
- Plan: .agency/plans/user-authentication.md
- Specialist: backend-architect
- Files: 5 created, 3 modified
- Focus: Security, API design, database schema

Review complete: 2 high-priority issues found
```

---

### 4. Context Detection (6 components)

**Purpose**: Detect project context to adapt command behavior.

#### 4.1 `framework-detection.md`

**Lines**: 505 lines
**Purpose**: Detect application framework (Next.js, Django, Laravel, etc.)
**When to use**: At start of any command that generates or modifies code

**What it does**:
- Check for config files (next.config.js, manage.py, artisan, etc.)
- Detect 13+ frameworks with version detection
- Handle ambiguity (multiple frameworks)
- Adapt commands to framework conventions

**Used by**: 11 commands (`work.md`, `implement.md`, `test.md`, `refactor.md`, `optimize.md`, `deploy.md`, `document.md`, `review.md`, `security.md`, `plan.md`, `adr.md`)

**Example**:
```bash
$ test -f next.config.js
✅ Framework: Next.js 14.0.4
- Type: Full-stack React framework
- Build: npm run build
- Test: Jest/Vitest
```

#### 4.2 `testing-framework-detection.md`

**Lines**: ~280 lines
**Purpose**: Detect test framework (Jest, pytest, PHPUnit, etc.)
**When to use**: Before running tests or generating test files

**What it does**:
- Check package.json/requirements.txt for test dependencies
- Detect test file patterns (*.test.ts, *_test.py, etc.)
- Determine test commands
- Configure test execution strategy

**Used by**: `test.md`, `implement.md`, `work.md`, `refactor.md`

#### 4.3 `database-detection.md`

**Lines**: ~250 lines
**Purpose**: Detect database/ORM (Prisma, Django ORM, Eloquent, etc.)
**When to use**: For database-related work (schema changes, migrations)

**What it does**:
- Detect ORM from dependencies and config files
- Identify database type (PostgreSQL, MySQL, MongoDB, etc.)
- Determine migration commands
- Handle connection configuration

**Used by**: `implement.md`, `work.md`, `refactor.md`, `optimize.md`

#### 4.4 `build-tool-detection.md`

**Lines**: ~220 lines
**Purpose**: Detect build tool (Vite, webpack, Next.js, etc.)
**When to use**: Before running build commands

**What it does**:
- Check for build config files
- Detect bundler (Vite, webpack, Rollup, esbuild, etc.)
- Determine build commands
- Configure build optimizations

**Used by**: `deploy.md`, `optimize.md`, `work.md`, `implement.md`

#### 4.5 `documentation-system-detection.md`

**Lines**: ~200 lines
**Purpose**: Detect documentation system (MkDocs, Storybook, etc.)
**When to use**: For documentation commands

**What it does**:
- Detect docs system from config files
- Identify docs directory structure
- Determine docs build commands
- Adapt documentation format

**Used by**: `document.md`, `adr.md`

#### 4.6 `project-size-detection.md`

**Lines**: ~180 lines
**Purpose**: Categorize project size (small/medium/large)
**When to use**: To adapt scope and timeouts

**What it does**:
- Count files, lines of code, dependencies
- Categorize: Small < 50 files, Medium 50-500, Large > 500
- Adjust timeouts based on size
- Scale complexity estimation

**Used by**: `sprint.md`, `optimize.md`, `security.md`, `refactor.md`

---

### 5. Git Operations (5 components)

**Purpose**: Standardized git workflows with best practices.

#### 5.1 `branch-creation.md`

**Lines**: ~220 lines
**Purpose**: Create branches with naming conventions
**When to use**: Before starting implementation work

**What it does**:
- Follow naming conventions (feat/, fix/, refactor/, etc.)
- Validate branch name format
- Check for existing branches
- Handle branch creation errors

**Used by**: `work.md`, `implement.md`

**Example**:
```bash
Issue: "Add user authentication"
→ Branch: feat/user-authentication-123
```

#### 5.2 `commit-formatting.md`

**Lines**: 548 lines
**Purpose**: Create conventional commits with proper format
**When to use**: When committing changes

**What it does**:
- Enforce conventional commit format (feat:, fix:, etc.)
- Provide commit message templates
- Use HEREDOC for multi-line commits
- Validate commit messages
- Link commits to issues

**Used by**: `work.md`, `adr.md`, `optimize.md`, `document.md`

**Example**:
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT authentication

Implement token-based authentication to replace
session-based auth for better scalability.

Closes #123
EOF
)"
```

#### 5.3 `pr-creation.md`

**Lines**: ~320 lines
**Purpose**: Create comprehensive PRs using gh CLI
**When to use**: After implementation complete and verified

**What it does**:
- Generate PR title and description
- Include summary, changes, testing notes
- Link to original issue
- Handle multi-specialist PRs
- Add labels and reviewers

**Used by**: `work.md`, `implement.md`

**Example**:
```bash
gh pr create --title "feat: Add user authentication" --body "$(cat <<'EOF'
## Summary
- Implemented JWT-based authentication
- Added login/register endpoints
- Created user model and middleware

## Changes
- Created: src/auth/*.ts (3 files)
- Modified: src/middleware/auth.ts

## Testing
- All tests pass (150/150)
- Coverage: 85%

Closes #123
EOF
)"
```

#### 5.4 `status-validation.md`

**Lines**: ~190 lines
**Purpose**: Validate git state before operations
**When to use**: Before creating branch, committing, or creating PR

**What it does**:
- Check for uncommitted changes
- Detect merge conflicts
- Verify remote connection
- Check branch tracking
- Ensure clean working tree

**Used by**: `work.md`, `implement.md`, `deploy.md`

#### 5.5 `tag-creation.md`

**Lines**: ~210 lines
**Purpose**: Create semantic version tags with changelogs
**When to use**: For releases and deployments

**What it does**:
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Generate changelog from commits
- Create annotated tags
- Push tags to remote

**Used by**: `deploy.md`

---

### 6. Issue Management (5 components)

**Purpose**: Fetch and parse GitHub/Jira issues.

#### 6.1 `github-issue-fetch.md`

**Lines**: 201 lines
**Purpose**: Fetch GitHub issues using gh CLI
**When to use**: Start of /agency:work with GitHub issue

**What it does**:
- Handle issue numbers (123), URLs, or "next"
- Fetch with gh CLI
- Return JSON with issue details
- Handle not found errors

**Used by**: `work.md`, `sprint.md`, `plan.md`, `review.md`

**Example**:
```bash
gh issue view 123 --json number,title,body,labels,assignees
```

#### 6.2 `jira-issue-fetch.md`

**Lines**: 302 lines
**Purpose**: Fetch Jira issues using acli
**When to use**: Start of /agency:work with Jira issue

**What it does**:
- Handle issue keys (PROJ-123), URLs, or "next"
- Fetch with acli
- Return CSV with issue details
- Handle authentication and permissions

**Used by**: `work.md`, `sprint.md`, `plan.md`, `review.md`

**Example**:
```bash
acli jira --action getIssue \
  --issue "PROJ-123" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority"
```

#### 6.3 `issue-metadata-extraction.md`

**Lines**: 361 lines
**Purpose**: Extract structured metadata from issue output
**When to use**: After fetching issue, before planning

**What it does**:
- Parse title, description, labels, priority
- Extract acceptance criteria
- Identify issue type (Bug, Feature, Task)
- Handle missing fields gracefully

**Used by**: `work.md`, `sprint.md`, `plan.md`

#### 6.4 `dependency-parsing.md`

**Lines**: 376 lines
**Purpose**: Parse dependency references from issue descriptions
**When to use**: After metadata extraction

**What it does**:
- Detect patterns: "depends on #123", "blocked by PROJ-456"
- Check dependency status (open vs closed)
- Recommend proceed or wait
- Handle circular dependencies

**Used by**: `work.md`, `sprint.md`, `plan.md`

**Example**:
```markdown
Issue description: "Depends on #122 (authentication)"

Dependency check:
- #122: OPEN ⚠️ (blocking)

→ Recommend: Wait for #122 or ask user to proceed anyway
```

#### 6.5 `README.md`

**Lines**: 189 lines
**Purpose**: Documentation for issue management components
**When to use**: Reference for developers

---

### 7. Error Handling (6 components)

**Purpose**: Detect, report, and recover from errors gracefully.

#### 7.1 `scope-detection-failure.md`

**Lines**: ~150 lines
**Purpose**: Handle ambiguous or missing scope detection
**When to use**: When framework/technology cannot be detected

**What it does**:
- List detection attempts and results
- Ask user to specify framework/scope
- Provide fallback generic approach
- Exit code: 10 (scope failure)

**Used by**: All 14 commands

**Example**:
```markdown
⚠️ Framework Detection Failed

Attempted:
- Next.js: Not found
- Django: Not found
- Express: Not found

Please specify your framework:
A) Next.js
B) Django
C) Express
D) Other (specify)
```

#### 7.2 `tool-execution-failure.md`

**Lines**: ~180 lines
**Purpose**: Handle CLI tool failures (npm, gh, tsc, etc.)
**When to use**: When external commands fail

**What it does**:
- Detect exit codes (127 = not found, 1 = general error)
- Parse tool-specific error messages
- Suggest fixes (install missing tool, fix config)
- Exit code: 20-29 (tool failures)

**Used by**: All 14 commands

#### 7.3 `user-cancellation.md`

**Lines**: ~140 lines
**Purpose**: Clean up gracefully when user cancels (Ctrl+C)
**When to use**: On SIGINT or user abort

**What it does**:
- Stop background processes
- Remove temporary files
- Offer WIP commit or discard
- Exit code: 130 (user cancel)

**Used by**: 12 commands

#### 7.4 `timeout-handling.md`

**Lines**: ~160 lines
**Purpose**: Handle long-running operations with timeouts
**When to use**: For build, test, deploy operations

**What it does**:
- Set timeouts based on project size
- Monitor progress with indicators
- Detect hanging processes
- Exit code: 40-49 (timeout)

**Used by**: `deploy.md`, `optimize.md`, `test.md`, `sprint.md`

#### 7.5 `partial-failure-recovery.md`

**Lines**: 677 lines (most comprehensive!)
**Purpose**: Handle scenarios where some tasks succeed, others fail
**When to use**: Multi-task workflows (sprint, optimize, deploy)

**What it does**:
- Track success/failure per task
- Distinguish critical vs non-critical failures
- Offer recovery options (retry, rollback, continue)
- Dependency-aware recovery
- Exit code: 50-59 (partial failures)

**Used by**: `sprint.md`, `optimize.md`, `deploy.md`, `review.md`

**Example**:
```markdown
⚠️ Partial Success

Summary:
- ✅ Succeeded: 8 tasks
- ❌ Failed: 2 tasks
- Total: 10 tasks

Failed Tasks:
1. Payment integration - Stripe API auth failed
2. Email notifications - SMTP unreachable

Options:
A) Fix failed tasks and retry
B) Continue without failed tasks
C) Rollback all changes
D) Save progress and abort
```

#### 7.6 `ask-user-retry.md`

**Lines**: ~120 lines
**Purpose**: Standardized retry/skip/abort pattern
**When to use**: When recoverable errors occur

**What it does**:
- Present error context
- Offer options: Retry, Skip, Abort
- Use AskUserQuestion tool
- Handle user response timeout

**Used by**: 10 commands

**Example**:
```markdown
❌ Build Failed

Error: Type errors found in src/auth/service.ts

Options:
A) Retry (I'll fix the errors)
B) Skip build check (not recommended)
C) Abort workflow

Please select (A/B/C):
```

---

### 8. Progress Tracking (4 components)

**Purpose**: TodoWrite-based progress tracking for multi-phase workflows.

#### 8.1 `todo-initialization.md`

**Lines**: 467 lines
**Purpose**: Initialize TodoWrite list at command start
**When to use**: Phase 0 of any multi-phase command

**What it does**:
- Provide command-specific templates (work, implement, sprint, deploy)
- Define TodoWrite format (content, status, activeForm)
- Generate dynamic todo lists
- Set first phase to "in_progress"

**Used by**: `work.md`, `implement.md`, `sprint.md`, `deploy.md`, `test.md`, `adr.md`, `optimize.md`, `document.md`, `review.md`

**Example**:
```javascript
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "in_progress",
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Create implementation plan",
      status: "pending",
      activeForm: "Creating implementation plan"
    },
    // ... more phases
  ]
});
```

#### 8.2 `phase-tracking.md`

**Lines**: 398 lines
**Purpose**: Update TodoWrite as phases complete
**When to use**: After each phase completes

**What it does**:
- Mark completed phase as "completed"
- Set next phase to "in_progress"
- Enforce: Exactly ONE "in_progress" at all times
- Calculate progress percentage

**Used by**: Same 9 commands as todo-initialization

**Example**:
```javascript
// After Phase 1 completes
TodoWrite({
  todos: [
    {content: "Fetch issue", status: "completed"},
    {content: "Create plan", status: "in_progress"}, // ← Now active
    {content: "Implement", status: "pending"},
    // ...
  ]
});

// Progress: 1/9 phases (11%)
```

#### 8.3 `completion-reporting.md`

**Lines**: 419 lines
**Purpose**: Final TodoWrite update with summary
**When to use**: After workflow completes

**What it does**:
- Mark all phases "completed"
- Calculate total duration
- Show completion statistics
- Link to PR and artifacts

**Used by**: Same 9 commands

**Example**:
```markdown
## Workflow Complete

**Status**: ✅ SUCCESS
**Duration**: 4m 32s
**Progress**: 9/9 phases (100%)

**Pull Request**: #456
**Summary**: .agency/implementations/impl-issue-123.md
```

#### 8.4 `README.md`

**Lines**: 312 lines
**Purpose**: Documentation for progress tracking components
**When to use**: Reference for developers

---

### 9. Planning (1 component)

**Purpose**: Plan validation and parsing.

#### 9.1 `plan-validation.md`

**Lines**: ~250 lines
**Purpose**: Validate plan completeness before implementation
**When to use**: After plan generation, before implementation

**What it does**:
- Check required sections exist (Objective, Requirements, Success Criteria)
- Validate implementation steps are detailed
- Ensure file paths and structure specified
- Verify acceptance criteria defined

**Used by**: `implement.md`, `plan.md`, `work.md`

**Example**:
```markdown
Plan Validation:
✅ Objective defined
✅ Requirements listed (5 items)
✅ Implementation steps detailed
✅ Success criteria specified
⚠️ File structure missing (will generate during implementation)

→ Plan is valid, proceed to implementation
```

---

### 10. Reporting (4 components)

**Purpose**: Standardized reporting formats for implementations and reviews.

#### 10.1 `summary-template.md`

**Lines**: 342 lines
**Purpose**: Implementation summary report template
**When to use**: After implementation completes

**What it does**:
- Provide standardized report structure
- Document: Objective, files changed, verification results, review findings
- Calculate completion percentage
- Recommend next steps

**Used by**: `implement.md`, `work.md`, `sprint.md`

**Structure**:
```markdown
# Implementation Summary: Feature Name

**Status**: ✅ SUCCESS
**Specialist**: backend-architect
**Duration**: 12m 34s

## Objective
[Brief description]

## Requirements Implemented
- [x] Req 1
- [x] Req 2
(5/5 = 100%)

## Files Changed
- Created: 3 files
- Modified: 2 files
- Deleted: 0 files

## Verification Results
- Build: ✅ PASS
- Tests: ✅ 150/150 passed
- Coverage: 85%

## Code Review
- Critical: 0
- High: 1
- Medium: 3

## Next Steps
- Create PR
- Deploy to staging
```

#### 10.2 `artifact-listing.md`

**Lines**: ~110 lines
**Purpose**: List all generated artifacts
**When to use**: End of command for summary

**What it does**:
- List implementation summaries
- List plan files
- List test reports
- Show artifact locations

**Used by**: `work.md`, `sprint.md`, `deploy.md`

#### 10.3 `metrics-comparison.md`

**Lines**: ~130 lines
**Purpose**: Compare before/after metrics
**When to use**: After optimization or refactoring

**What it does**:
- Compare performance metrics (bundle size, response time)
- Calculate improvement percentages
- Present in table format
- Highlight regressions

**Used by**: `optimize.md`, `refactor.md`

**Example**:
```markdown
## Metrics Comparison

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Bundle size | 850 KB | 620 KB | -27% ✅ |
| First load | 2.3s | 1.8s | -22% ✅ |
| API response | 340ms | 280ms | -18% ✅ |
```

#### 10.4 `next-steps-template.md`

**Lines**: ~90 lines
**Purpose**: Recommend next actions based on results
**When to use**: End of command

**What it does**:
- Analyze completion status
- Recommend follow-up commands
- Suggest reviews or testing
- Provide deployment guidance

**Used by**: `implement.md`, `work.md`, `optimize.md`, `refactor.md`

---

## Usage Guidelines

### How to Reference Components in Commands

Components are referenced using include syntax:

```markdown
## Phase 2: Specialist Selection

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/dependency-detection.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

**Rules**:
1. Use relative path from project root: `prompts/category/component.md`
2. Include only what's needed for that phase
3. Maintain order if components have dependencies
4. Don't duplicate component inclusion in same command

### When to Use Components vs Inline Content

**Use Components When**:
- Pattern appears in 3+ commands
- Logic is >15 lines
- Likely to change or evolve
- Part of a critical workflow (quality gates, specialist selection)

**Use Inline Content When**:
- Command-specific logic unique to that command
- One-off instructions
- Less than 10 lines
- Tightly coupled to command context

**Examples**:

✅ **Good component**: Specialist keyword analysis (used in 5 commands)
✅ **Good inline**: Command-specific introduction text
❌ **Bad component**: Single-use helper text
❌ **Bad inline**: Quality gate sequence duplicated across commands

### Component Dependencies

Some components depend on others and must be used in order:

**Specialist Selection Flow**:
```
specialist-selection/keyword-analysis.md
  ↓ (provides specialist list)
specialist-selection/dependency-detection.md
  ↓ (determines execution strategy)
specialist-selection/user-approval.md
```

**Quality Gates Flow**:
```
quality-gates/quality-gate-sequence.md
  ↓ (all gates must pass)
code-review/reality-checker-spawn.md
```

**Issue Workflow**:
```
issue-management/github-issue-fetch.md (or jira-issue-fetch.md)
  ↓
issue-management/issue-metadata-extraction.md
  ↓
issue-management/dependency-parsing.md
```

**Progress Tracking Flow**:
```
progress/todo-initialization.md (start)
  ↓
progress/phase-tracking.md (during each phase)
  ↓
progress/completion-reporting.md (end)
```

---

## Component Attribution

### Attribution Format

When using components, add attribution comments in command files:

```markdown
## Phase 2: Specialist Selection

<!-- Component: prompts/specialist-selection/keyword-analysis.md -->
<!-- Component: prompts/specialist-selection/user-approval.md -->

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

**Benefits**:
- Clearly show which components are used
- Help with impact analysis when updating components
- Serve as inline documentation
- Easy to find component usage with grep

### Finding Component Usage

```bash
# Find all commands using a specific component
grep -r "keyword-analysis" commands/

# Find all components used in a specific command
grep "Component:" commands/work.md

# Count component usage
grep -r "prompts/specialist-selection" commands/ | wc -l
```

---

## Before & After Examples

### Example 1: Specialist Selection

**Before** (Monolithic approach in every command):

```markdown
<!-- implement.md: 656 lines -->

## Phase 2: Specialist Selection

Scan the plan for technology keywords to determine the best specialist:

**Frontend Specialist** if plan mentions:
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
- TypeScript, JavaScript, JSX, TSX
- Tailwind, CSS, styled-components
- shadcn, Radix UI, Headless UI
- Component, UI, UX, design system
- Form, button, layout, modal
- Animation, transition, responsive

**Backend Specialist** if plan mentions:
- API, REST, GraphQL, tRPC
- Database, SQL, PostgreSQL, MySQL, MongoDB
- Prisma, Drizzle, TypeORM
- Authentication, authorization, JWT
- Microservices, serverless
- Node.js server, Express, Fastify
- Middleware, endpoint, route
- Schema, migration, query

[... 80+ more lines of keywords and scoring logic ...]

<!-- This was repeated in work.md, test.md, refactor.md, optimize.md -->
```

**After** (Component-based):

```markdown
<!-- implement.md: ~250 lines -->

## Phase 2: Specialist Selection

<!-- Component: prompts/specialist-selection/keyword-analysis.md -->
<!-- Component: prompts/specialist-selection/user-approval.md -->

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

**Impact**:
- **Before**: 656 lines × 5 commands = 3,280 lines
- **After**: ~20 lines × 5 commands + 98 lines (component) = 198 lines
- **Saved**: 3,082 lines (94% reduction!)

### Example 2: Quality Gates

**Before**:

```markdown
<!-- implement.md, work.md, test.md, review.md, refactor.md -->

## Phase 5: Run Quality Gates

Execute quality verification in order. DO NOT skip any gate.

### Gate 1: Build
Run build to verify code compiles:
```bash
npm run build
```
If build fails:
1. Read build errors
2. Fix compilation issues
3. Re-run build
4. BLOCK until build passes

### Gate 2: Type Check
Run TypeScript type checker:
```bash
npm run type-check || npx tsc --noEmit
```
If type check fails:
1. Analyze type errors
2. Fix type mismatches
3. Re-run type check
4. BLOCK until passes

[... 120+ more lines for lint, test, coverage ...]

<!-- Duplicated in 5 commands -->
```

**After**:

```markdown
## Phase 5: Run Quality Gates

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->

{{include:prompts/quality-gates/quality-gate-sequence.md}}
```

**Impact**:
- **Before**: ~175 lines × 5 commands = 875 lines
- **After**: ~10 lines × 5 commands + 175 lines (component) = 225 lines
- **Saved**: 650 lines (74% reduction)

### Example 3: Error Handling

**Before**:

```markdown
<!-- Every command had its own error handling -->

If npm install fails:
- Check error message
- Try npm ci instead
- If still fails, ask user
- Exit code 1

If build fails:
- Parse build errors
- Suggest fixes
- Retry up to 3 times
- Exit if still failing

If user presses Ctrl+C:
- Stop any running processes
- Clean up temp files
- Ask: Keep changes or discard?
- Exit gracefully

[... different error handling in each command ...]
```

**After**:

```markdown
<!-- Component: prompts/error-handling/tool-execution-failure.md -->
<!-- Component: prompts/error-handling/user-cancellation.md -->
<!-- Component: prompts/error-handling/ask-user-retry.md -->

{{include:prompts/error-handling/tool-execution-failure.md}}
{{include:prompts/error-handling/user-cancellation.md}}
{{include:prompts/error-handling/ask-user-retry.md}}
```

**Impact**:
- **Before**: Inconsistent error handling across 14 commands (~350 lines each)
- **After**: Standardized error handling with 6 reusable components
- **Saved**: 2,130 lines (from Phase 4 plan statistics)

---

## Creating New Components

### When to Create a New Component

**Create a component when**:
1. **Used 3+ times**: Pattern appears in 3 or more commands
2. **Substantial**: Logic is >15 lines
3. **Evolving**: Likely to change or improve over time
4. **Critical**: Part of a core workflow (testing, quality, security)

**Don't create a component when**:
1. **One-off**: Only used in one command
2. **Trivial**: Less than 10 lines
3. **Command-specific**: Tightly coupled to specific command context
4. **Unstable**: Still experimenting, not yet standardized

### Component Structure Template

```markdown
# Component Title

Brief description of what this component does (1-2 sentences).

## When to Use

**Triggers**:
- Condition 1
- Condition 2
- Condition 3

**Commands Using This**: [List commands that use this component]

---

## Purpose

[Detailed explanation of what problem this solves and why it exists]

---

## Main Content

[The actual reusable instructions, code examples, workflows, etc.]

---

## Validation

[How to verify this component was executed correctly]

**Success criteria**:
- Criterion 1
- Criterion 2

**Failure indicators**:
- Indicator 1
- Indicator 2

---

## Related Components

- `prompts/category/related-component.md` - [How they relate]

---

## Examples

### Example 1: [Scenario]

[Concrete example showing component in action]

### Example 2: [Another scenario]

[Another example]
```

### Naming Conventions

**File naming**:
- Use `kebab-case.md` for all filenames
- Be descriptive and action-oriented
- Group related components in subdirectories

**Good names**:
- ✅ `keyword-analysis.md` (clear, descriptive)
- ✅ `quality-gate-sequence.md` (describes what it does)
- ✅ `github-issue-fetch.md` (specific platform)

**Bad names**:
- ❌ `utils.md` (too vague)
- ❌ `helper.md` (not descriptive)
- ❌ `stuff.md` (not professional)

**Directory structure**:
```
prompts/
├── category-name/           # Lowercase, hyphenated
│   ├── component-one.md     # Descriptive, action-oriented
│   ├── component-two.md
│   └── README.md            # Category documentation
```

### Component Development Checklist

Before creating a new component:

- [ ] Confirm it's used in 3+ commands (or will be soon)
- [ ] Check no similar component already exists
- [ ] Define clear purpose and scope
- [ ] Write comprehensive documentation sections
- [ ] Include concrete examples
- [ ] Add validation criteria
- [ ] Test with all intended commands
- [ ] Update this guide's component catalog
- [ ] Add attribution comments in commands

---

## Maintenance & Best Practices

### Updating Existing Components

**When updating a component**:

1. **Test with ALL commands that use it**
   ```bash
   # Find all usages
   grep -r "component-name" commands/

   # Test each command
   /agency:work 123
   /agency:implement plan.md
   # etc.
   ```

2. **Document the change**
   - Add version comment at top of component
   - Update component description if behavior changes
   - Update this guide if significant

3. **Version header example**:
   ```markdown
   <!-- v1.2.0 - 2025-12-12 - Added DevOps specialist scoring -->
   # Specialist Selection: Keyword Analysis
   ```

4. **Communicate changes**
   - Update relevant documentation
   - Notify team of breaking changes
   - Consider deprecation period for major changes

**Impact radius**: Remember, one component change affects 3-5+ commands!

### Deprecating Components

When a component is no longer needed:

1. **Mark as deprecated**:
   ```markdown
   # [DEPRECATED] Old Component Name

   **⚠️ DEPRECATED**: Use `new-component-name.md` instead.
   **Migration guide**: [Link to migration instructions]
   **Removal date**: 2025-01-15
   ```

2. **Provide migration path**:
   ```markdown
   ## Migration

   **Before**:
   {{include:prompts/old/deprecated-component.md}}

   **After**:
   {{include:prompts/new/replacement-component.md}}
   ```

3. **Update all commands** to use new component

4. **Remove after migration complete** (all commands updated)

### Versioning Strategy

**Semantic versioning for components**:
- **MAJOR** (v1.0.0 → v2.0.0): Breaking changes (commands must update)
- **MINOR** (v1.0.0 → v1.1.0): New features, backward compatible
- **PATCH** (v1.0.0 → v1.0.1): Bug fixes, clarifications

**Version header format**:
```markdown
<!-- v1.2.3 - 2025-12-12 - Brief description of change -->
```

### Testing Components

**Manual testing**:
1. Test with single-specialist workflow: `/agency:implement simple-plan`
2. Test with multi-specialist workflow: `/agency:implement fullstack-plan`
3. Test error cases: Invalid plans, failing tests, etc.

**Verification checklist**:
- [ ] Commands still execute correctly
- [ ] No behavioral regressions
- [ ] Output quality maintained
- [ ] Error handling works as expected
- [ ] Edge cases handled gracefully

**Automated testing** (future enhancement):
- Component linting (validate markdown structure)
- Link checking (ensure cross-references work)
- Usage verification (detect orphaned components)

### Best Practices

1. **Single Responsibility**: Each component should do one thing well
2. **Self-Documenting**: Include clear purpose and examples
3. **Validation**: Define success criteria and failure indicators
4. **Error Handling**: Handle edge cases gracefully
5. **Consistency**: Follow established patterns and naming
6. **Composability**: Design to work with other components
7. **Testability**: Easy to verify component works correctly

### Common Pitfalls to Avoid

❌ **Don't**:
- Create components for one-off use
- Make components too generic (lose clarity)
- Create circular dependencies between components
- Change component behavior without testing all usages
- Skip documentation or examples

✅ **Do**:
- Create components for repeated patterns
- Keep components focused and specific
- Document dependencies clearly
- Test thoroughly before deploying
- Maintain comprehensive documentation

---

## Related Documentation

### Internal Documentation

- **`prompts/README.md`**: Overview of component system, statistics, recent additions
- **`docs/orchestration-playbook.md`**: How commands orchestrate specialists using components
- **`docs/handoff-system-guide.md`**: Multi-specialist coordination patterns (TBD)

### Component READMEs

Each category has its own README with specific details:

- **`prompts/issue-management/README.md`**: Issue fetching and parsing workflows
- **`prompts/progress/README.md`**: TodoWrite progress tracking patterns

### Command Files

See how components are used in practice:

- **`commands/work.md`**: Full issue-to-PR workflow using 20+ components
- **`commands/implement.md`**: Plan implementation using quality gates, specialist selection
- **`commands/sprint.md`**: Multi-issue workflow with progress tracking
- **`commands/deploy.md`**: Deployment workflow with error handling and git operations

### External Resources

- **Conventional Commits**: https://www.conventionalcommits.org/
- **Semantic Versioning**: https://semver.org/
- **GitHub CLI (gh)**: https://cli.github.com/
- **Atlassian CLI (acli)**: https://bobswift.atlassian.net/wiki/spaces/ACLI/overview

---

## Appendix: Quick Reference

### Component Count by Category

| Category | Components | Total Lines | Avg Reuse |
|----------|------------|-------------|-----------|
| Specialist Selection | 5 | ~648 | 3.4x |
| Quality Gates | 8 | ~1,015 | 4.2x |
| Code Review | 1 | ~200 | 5.0x |
| Context Detection | 6 | ~1,635 | 5.5x |
| Git Operations | 5 | ~1,488 | 2.8x |
| Issue Management | 5 | ~1,429 | 3.2x |
| Error Handling | 6 | ~1,427 | 9.3x |
| Progress Tracking | 4 | ~1,596 | 9.0x |
| Planning | 1 | ~250 | 3.0x |
| Reporting | 4 | ~672 | 3.5x |
| **Total** | **43** | **~10,360** | **4.9x avg** |

### Most Reused Components (Top 10)

1. **error-handling/tool-execution-failure.md** - 14 commands (used by all)
2. **error-handling/scope-detection-failure.md** - 14 commands (used by all)
3. **progress/todo-initialization.md** - 9 commands
4. **progress/phase-tracking.md** - 9 commands
5. **context/framework-detection.md** - 11 commands
6. **quality-gates/quality-gate-sequence.md** - 5 commands
7. **code-review/reality-checker-spawn.md** - 5 commands
8. **specialist-selection/keyword-analysis.md** - 5 commands
9. **error-handling/user-cancellation.md** - 12 commands
10. **error-handling/ask-user-retry.md** - 10 commands

### Component Impact Statistics

**Total line reduction**: 62% (12,895 → 7,500 lines across all commands)

**Biggest savings**:
- Specialist selection: ~3,082 lines saved
- Quality gates: ~650 lines saved
- Error handling: ~2,130 lines saved (6 components)
- Progress tracking: ~1,284 lines saved

**Average reuse**: 4.9x per component (each component used in ~5 commands)

---

## Questions & Support

For questions about prompt components:

1. **Check component documentation**: Read the component's header comments and examples
2. **Review usage in commands**: `grep -r "component-name" commands/` to see how it's used
3. **Consult this guide**: Search for relevant sections
4. **Check orchestration playbook**: `docs/orchestration-playbook.md` for workflow context
5. **Ask the team**: Reach out to maintainers for clarification

**Contributing**:
- Found a bug in a component? Test with all usages, then fix
- Have an improvement idea? Validate impact across commands first
- Want to create a new component? Follow the creation checklist above

---

**Document Version**: 1.0
**Last Updated**: 2025-12-12
**Maintainer**: Agency Plugin Team
