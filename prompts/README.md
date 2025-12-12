# Agency Prompt Components

Reusable prompt building blocks for agency commands and workflows.

## Overview

This directory contains modular prompt components that eliminate duplication across agency commands. Instead of repeating the same instructions in multiple command files, commands reference these shared components.

**Benefits**:
- **62% line reduction**: 12,895 → 7,500 lines across all commands
- **3.5x reuse**: Each component used in 3-5 commands on average
- **Single source of truth**: Update one component, all commands benefit
- **Consistent behavior**: Same specialist selection, quality gates, review process everywhere

---

## Directory Structure

```
prompts/
├── context/                       # Project context detection
│   ├── framework-detection.md     # Detect framework (Next.js, Django, Laravel, etc.)
│   ├── testing-framework-detection.md  # Detect test framework (Jest, pytest, etc.)
│   ├── database-detection.md      # Detect database/ORM (Prisma, Django ORM, etc.)
│   ├── build-tool-detection.md    # Detect build tool (Vite, webpack, Next.js, etc.)
│   ├── documentation-system-detection.md  # Detect docs system (MkDocs, Storybook, etc.)
│   └── project-size-detection.md  # Categorize project size (small/medium/large)
├── specialist-selection/          # Determine which specialist(s) to use
│   ├── keyword-analysis.md        # Score specialists based on keywords
│   ├── dependency-detection.md    # Detect sequential vs parallel execution
│   └── user-approval.md           # Confirm specialist selection with user
├── quality-gates/                 # Sequential verification steps
│   └── quality-gate-sequence.md   # Build → Type → Lint → Test → Coverage
├── code-review/                   # Code review spawning and verification
│   └── reality-checker-spawn.md   # Spawn reality-checker with correct context
├── planning/                      # Plan validation and parsing
│   └── plan-validation.md         # Validate plan completeness
├── reporting/                     # Standardized reporting formats
│   └── summary-template.md        # Implementation summary structure
├── git/                           # Git operations and workflows
│   ├── branch-creation.md         # Create branches with naming conventions
│   ├── commit-formatting.md       # Conventional commit format
│   ├── pr-creation.md             # Create comprehensive PRs with gh CLI
│   ├── status-validation.md       # Validate git state before operations
│   └── tag-creation.md            # Semantic versioning and release tags
├── issue-management/              # GitHub/Jira issue workflows
│   ├── github-issue-fetch.md      # Fetch GitHub issue with gh CLI
│   ├── jira-issue-fetch.md        # Fetch Jira issue with acli
│   ├── issue-metadata-extraction.md  # Extract title, description, labels, priority
│   └── dependency-parsing.md      # Parse "depends on #123" patterns
├── error-handling/                # Error detection and recovery patterns
│   ├── scope-detection-failure.md # Handle ambiguous or missing scope detection
│   ├── tool-execution-failure.md  # Handle CLI tool failures (gh, npm, tsc, etc.)
│   ├── user-cancellation.md       # Clean up and exit gracefully when user cancels
│   ├── timeout-handling.md        # Handle long-running operations with timeouts
│   ├── partial-failure-recovery.md # Handle scenarios where some tasks succeed, others fail
│   └── ask-user-retry.md          # Standardized retry/skip/abort pattern with AskUserQuestion
└── progress/                      # TodoWrite progress tracking
    ├── todo-initialization.md     # Initialize TodoWrite for command phases
    ├── phase-tracking.md          # Update TodoWrite as phases complete
    └── completion-reporting.md    # Final TodoWrite update with summary
```

---

## Usage in Commands

### Including Components

Commands reference components using special markers (implementation detail may vary):

```markdown
## Phase 2: Specialist Selection

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/dependency-detection.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

### Before (Monolithic)

```markdown
<!-- implement.md: 656 lines with duplicated content -->

## Phase 2: Specialist Selection

Scan the plan for technology keywords to determine the best specialist:

**Frontend Specialist** if plan mentions:
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
- TypeScript, JavaScript, JSX, TSX
... [20+ lines of keywords]

**Backend Specialist** if plan mentions:
- API, REST, GraphQL, tRPC
- Database, SQL, PostgreSQL, MySQL, MongoDB
... [20+ lines of keywords]

[Repeated in work.md, test.md, refactor.md, optimize.md, document.md...]
```

### After (Component-Based)

```markdown
<!-- implement.md: ~250 lines, focused and concise -->

## Phase 2: Specialist Selection

{{include:prompts/specialist-selection/keyword-analysis.md}}
{{include:prompts/specialist-selection/user-approval.md}}
```

---

## Core Components

### 0. Project Context Detection (Foundation - NEW)

**Files**:
- `context/framework-detection.md` - Detect framework (Next.js, Django, Laravel, FastAPI, Flask, Express, Rails, etc.)
- `context/testing-framework-detection.md` - Detect test framework (Jest, Vitest, pytest, Playwright, Cypress, PHPUnit, RSpec, etc.)
- `context/database-detection.md` - Detect database/ORM (Prisma, Drizzle, Supabase, SQLAlchemy, Eloquent, ActiveRecord, etc.)
- `context/build-tool-detection.md` - Detect build tool (Vite, webpack, Rollup, Next.js, Turbopack, etc.)
- `context/documentation-system-detection.md` - Detect docs system (MkDocs, Docusaurus, Storybook, VitePress, Sphinx, etc.)
- `context/project-size-detection.md` - Categorize project size (small/medium/large) based on file count, LOC, complexity

**Used in**: All 11 commands that interact with code

**Purpose**: Understand project context to adapt commands, testing strategies, build processes, and execution approaches.

**Detection Methods**:
- **Framework**: Config files (next.config.js, manage.py, artisan), dependencies, directory patterns
- **Testing**: Package dependencies (Jest, pytest, PHPUnit) and test file patterns
- **Database**: ORM dependencies (Prisma, Django ORM, Eloquent) and config files
- **Build Tool**: Bundler config files (vite.config.ts, webpack.config.js)
- **Documentation**: Doc system config (mkdocs.yml, docusaurus.config.js, .storybook/)
- **Project Size**: File count, LOC, dependencies (small < 50 files, medium 50-500, large > 500)

**Command Adaptations**:
- Use framework-specific patterns and conventions
- Run correct test commands for detected framework
- Use appropriate database migration commands
- Execute correct build commands
- Update documentation in correct format
- Adjust timeouts and scope based on project size

---

### 1. Specialist Selection (Most Critical)

**Files**:
- `specialist-selection/keyword-analysis.md` - Scoring algorithm for specialist detection
- `specialist-selection/dependency-detection.md` - Sequential vs parallel execution
- `specialist-selection/user-approval.md` - User confirmation prompts

**Used in**: `implement.md`, `work.md`, `test.md`, `refactor.md`, `optimize.md`

**Purpose**: Consistently select the right specialist(s) based on plan content.

### 2. Quality Gates

**Files**:
- `quality-gates/quality-gate-sequence.md` - Sequential execution of verification steps

**Used in**: `implement.md`, `work.md`, `test.md`, `review.md`

**Purpose**: Ensure consistent quality standards across all workflows.

**Gates**:
1. Build (CRITICAL)
2. Type Check (CRITICAL)
3. Linter (HIGH PRIORITY)
4. Tests (CRITICAL)
5. Coverage (RECOMMENDED)

### 3. Code Review

**Files**:
- `code-review/reality-checker-spawn.md` - Reality-checker agent spawning

**Used in**: `implement.md`, `work.md`, `test.md`, `review.md`, `refactor.md`

**Purpose**: Consistent code review process with proper context.

**Modes**:
- Single-specialist review
- Per-specialist verification (multi-specialist)
- Integrated review (multi-specialist)

### 4. Planning

**Files**:
- `planning/plan-validation.md` - Validate plan completeness

**Used in**: `implement.md`, `plan.md`, `work.md`

**Purpose**: Ensure plans are complete before implementation starts.

### 5. Reporting

**Files**:
- `reporting/summary-template.md` - Standardized implementation summaries

**Used in**: `implement.md`, `work.md`, `sprint.md`

**Purpose**: Consistent reporting format for all implementations.

### 6. Issue Management

**Files**:
- `issue-management/github-issue-fetch.md` - Fetch GitHub issues with gh CLI
- `issue-management/jira-issue-fetch.md` - Fetch Jira issues with acli
- `issue-management/issue-metadata-extraction.md` - Extract structured metadata
- `issue-management/dependency-parsing.md` - Parse dependency references

**Used in**: `work.md`, `sprint.md`, `plan.md`

**Purpose**: Unified issue fetching and parsing for both GitHub and Jira workflows.

**Workflow**:
1. Detect issue source (GitHub vs Jira)
2. Fetch issue with appropriate CLI (gh or acli)
3. Extract metadata (title, description, labels, priority)
4. Parse dependencies ("depends on #123", "blocked by PROJ-456")
5. Check dependency status before implementation

### 7. Progress Tracking

**Files**:
- `progress/todo-initialization.md` - Initialize TodoWrite for workflows
- `progress/phase-tracking.md` - Update TodoWrite during execution
- `progress/completion-reporting.md` - Final TodoWrite with summary

**Used in**: `work.md`, `implement.md`, `sprint.md`, `deploy.md`

**Purpose**: Consistent progress tracking across all multi-phase commands.

**TodoWrite Guidelines**:
- Initialize at command start with all workflow phases
- Exactly ONE item must be `in_progress` at all times
- Update immediately after each phase completes
- Mark all items `completed` at workflow end
- Include timing and completion statistics in final report

### 8. Git Operations

**Files**:
- `git/branch-creation.md` - Create feature/bugfix/refactor branches with naming conventions
- `git/commit-formatting.md` - Conventional commit format with templates
- `git/pr-creation.md` - Create comprehensive PRs using gh CLI
- `git/status-validation.md` - Validate repository state before operations
- `git/tag-creation.md` - Semantic versioning and release tag creation

**Used in**: `implement.md` (Phase 6), `work.md`, `deploy.md`

**Purpose**: Standardized git workflows with best practices and error handling.

**Key Features**:
- **Branch Creation**: feat/, fix/, refactor/ naming conventions with pre-flight checks
- **Commit Formatting**: Conventional commits (feat:, fix:, etc.) with HEREDOC templates
- **PR Creation**: Comprehensive PR templates with multi-specialist support
- **Status Validation**: Clean state checks, uncommitted changes detection, merge conflict handling
- **Tag Creation**: SemVer tags with automated changelog generation from commits

**Workflow Integration**:
1. Validate status before starting work
2. Create feature branch with proper naming
3. Make commits following conventional format
4. Validate status before creating PR
5. Create PR with comprehensive description
6. Create release tags with semantic versioning

### 9. Error Handling

**Files**:
- `error-handling/scope-detection-failure.md` - Handle ambiguous or missing scope detection
- `error-handling/tool-execution-failure.md` - Handle CLI tool failures (gh, npm, tsc, etc.)
- `error-handling/user-cancellation.md` - Clean up and exit gracefully when user cancels
- `error-handling/timeout-handling.md` - Handle long-running operations with timeouts
- `error-handling/partial-failure-recovery.md` - Handle scenarios where some tasks succeed, others fail
- `error-handling/ask-user-retry.md` - Standardized retry/skip/abort pattern with AskUserQuestion

**Used in**: All 14 commands (error handling is universal)

**Purpose**: Consistent, user-friendly error detection, reporting, and recovery across all workflows.

**Key Features**:
- **Scope Detection Failure**: Handle missing/ambiguous project framework, ask user for clarification
- **Tool Execution Failure**: Detect and handle CLI tool failures (npm, tsc, gh, pytest, etc.) with smart recovery
- **User Cancellation**: Graceful Ctrl+C handling, cleanup procedures, partial work preservation
- **Timeout Handling**: Detect hanging processes, configurable timeouts, progress indicators
- **Partial Failure Recovery**: Handle mixed success/failure scenarios, dependency-aware recovery
- **Ask User Retry**: Standardized retry/skip/abort pattern using AskUserQuestion

**Error Detection Patterns**:
- Exit code analysis (127 = not found, 124 = timeout, 1 = general error)
- Output pattern matching for specific error types
- Background process monitoring with timeout detection
- User response timeout handling with sensible defaults

**Recovery Strategies**:
- Automatic retry with exponential backoff
- User-guided recovery with clear options (A/B/C)
- Graceful degradation (continue with warnings)
- Selective rollback (revert only failed changes)
- State preservation for resume/retry

**Cleanup Procedures**:
- Stop background processes and specialists
- Remove temporary files and incomplete artifacts
- Save partial state to `.agency/logs/`
- Handle git state (WIP commit, discard, or keep uncommitted)
- Clear TodoWrite and log cancellation

**Exit Codes**:
```bash
# Scope detection failures: 10-19
EXIT_CODE_SCOPE_FAILURE=10
EXIT_CODE_SCOPE_AMBIGUOUS=12

# Tool execution failures: 20-29
EXIT_CODE_TOOL_NOT_FOUND=20
EXIT_CODE_TOOL_FAILED=21
EXIT_CODE_TOOL_TIMEOUT=22

# User-initiated: 130-139
EXIT_CODE_USER_CANCEL=130     # Ctrl+C
EXIT_CODE_USER_ABORT=131      # Explicit abort

# Timeout failures: 40-49
EXIT_CODE_TIMEOUT_BUILD=40
EXIT_CODE_TIMEOUT_TEST=41

# Partial failures: 50-59
EXIT_CODE_PARTIAL_SUCCESS=50
EXIT_CODE_PARTIAL_CRITICAL=51
```

**Integration Example**:
```bash
# Build with error handling
if ! npm run build; then
  ask_user_retry "Build Failure" "npm run build" "Type errors found" "B (Fix and retry)"

  case $? in
    0) npm run build || cleanup_and_exit ;;  # Retry
    1) BUILD_SKIPPED=true ;;                  # Skip
    2) cleanup_and_exit "User aborted" 130 ;; # Abort
  esac
fi
```

**Usage Statistics** (from Phase 4 plan):
- `scope-detection-failure.md`: Used in all 14 commands (520 lines saved)
- `tool-execution-failure.md`: Used in all 14 commands (650 lines saved)
- `user-cancellation.md`: Used in 12 commands (330 lines saved)
- `timeout-handling.md`: Used in 4 commands (120 lines saved)
- `partial-failure-recovery.md`: Used in 4 commands (150 lines saved)
- `ask-user-retry.md`: Used in 10 commands (360 lines saved)

**Total Impact**: 2,130 lines saved across 6 components (9.3 average uses per component)

---

## Creating New Components

### Guidelines

**When to create a component**:
- Pattern appears in 3+ commands
- Logic is >15 lines
- Likely to change or evolve
- Part of a critical workflow

**When NOT to create a component**:
- Command-specific logic
- One-off instructions
- Less than 10 lines
- Tightly coupled to specific command context

### Component Structure

```markdown
# Component Title

Brief description of what this component does.

## When to Use

[Trigger conditions]

## Purpose

[What problem this solves]

---

## Main Content

[The actual reusable instructions]

---

## Validation

[How to verify this component was executed correctly]
```

### Naming Convention

- Use kebab-case for filenames
- Descriptive, action-oriented names
- Group related components in subdirectories

**Good**: `specialist-selection/keyword-analysis.md`
**Bad**: `helpers/utils.md`

---

## Multi-Specialist Workflows

Components support both single and multi-specialist workflows:

**Single-Specialist** (traditional):
- One specialist selected
- Direct implementation
- Standard verification

**Multi-Specialist** (new):
- Multiple specialists with scores
- Dependency detection
- Sequential or parallel execution
- Per-specialist verification
- Integrated code review

**Backward Compatible**: Components auto-detect mode based on context.

---

## Component Dependencies

Some components depend on others:

```
specialist-selection/keyword-analysis.md
  ↓ (provides specialist list)
specialist-selection/dependency-detection.md
  ↓ (determines execution strategy)
specialist-selection/user-approval.md
```

```
quality-gates/quality-gate-sequence.md
  ↓ (all gates must pass)
code-review/reality-checker-spawn.md
```

**Rule**: Execute dependent components in order.

---

## Testing Components

When modifying components, test with:

1. **Single-specialist workflow**: `/agency:implement [simple-plan]`
2. **Multi-specialist workflow**: `/agency:implement [fullstack-plan]`
3. **Error cases**: Invalid plans, failing tests, etc.

Verify:
- Commands still work correctly
- No regressions in behavior
- Consistent output quality

---

## Maintenance

### Updating Components

**When updating a component**:
1. Test with ALL commands that use it
2. Update component version/date in header
3. Document changes in this README
4. Notify team of changes

**Impact radius**: Remember, one component change affects 3-5 commands.

### Versioning

Consider adding version headers to components:

```markdown
<!-- v1.2.0 - 2024-12-11 - Added DevOps specialist scoring -->
```

### Deprecation

When deprecating a component:
1. Mark as `[DEPRECATED]` in filename
2. Add deprecation notice at top
3. Provide migration path
4. Remove after all commands updated

---

## Recent Additions (2024-12-12)

**Issue Management Components** (4 components, 1,240 lines):
- Complete GitHub and Jira issue fetching workflows
- Structured metadata extraction from both platforms
- Dependency parsing with status checking
- Handles issue numbers, URLs, and "next" keyword

**Progress Tracking Components** (3 components, 1,284 lines):
- TodoWrite initialization templates for all commands
- Real-time phase tracking patterns
- Completion reporting with timing metrics
- Command-specific todo templates (work, implement, sprint, deploy)

**Git Operations Components** (5 components, 3,180 lines):
- Branch creation with naming conventions (feat/, fix/, refactor/, etc.)
- Conventional commit formatting with templates and HEREDOC examples
- Comprehensive PR creation using gh CLI with multi-specialist support
- Repository status validation with error detection and handling
- Semantic versioning and release tag creation with changelog generation
- Integration with GitHub workflows and deployment pipelines

**Error Handling Components** (6 components, 2,130 lines saved):
- Scope detection failure handling with user clarification prompts
- CLI tool execution failure detection and recovery (npm, tsc, gh, pytest, etc.)
- Graceful user cancellation with cleanup and state preservation
- Timeout handling for long-running operations with progress indicators
- Partial failure recovery for mixed success/failure scenarios
- Standardized retry/skip/abort pattern using AskUserQuestion
- Comprehensive exit code standards (10-19: scope, 20-29: tools, 130-139: user, 40-49: timeout, 50-59: partial)
- Used across all 14 commands with 9.3 average uses per component

## Future Enhancements

Planned components:

- `planning/adr-integration.md` - Check for ADRs before implementation
- `testing/test-strategy-selection.md` - Determine test types needed
- `deployment/pre-flight-checks.md` - Verify deployment readiness
- `security/vulnerability-scan.md` - Security scanning instructions
- `performance/benchmark-execution.md` - Performance testing
- `documentation/auto-doc-generation.md` - Generate docs from code

---

## Related Documentation

- `../docs/orchestration-playbook.md` - How orchestration works
- `../docs/prompt-components-guide.md` - Detailed component authoring guide (TBD)
- `../docs/handoff-system-guide.md` - Multi-specialist coordination (TBD)

---

## Questions?

For questions about prompt components:
- Check component comments
- Review usage in commands (grep for component name)
- Consult orchestration playbook
- Ask the team
