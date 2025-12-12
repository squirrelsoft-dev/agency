---
description: Implement entire sprint (all issues in sprint/milestone/iteration)
argument-hint: sprint-id, milestone-name, or 'current'
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Work on Sprint: $ARGUMENTS

Implement all issues in a sprint/milestone end-to-end with intelligent dependency resolution and parallel execution.

## Reusable Components Used

This command leverages the following prompt components from `prompts/`:

**Context Detection**:
- `context/framework-detection.md` - Detect project framework
- `context/testing-framework-detection.md` - Detect test framework
- `context/database-detection.md` - Detect database/ORM
- `context/project-size-detection.md` - Categorize project size

**Issue Management**:
- `issue-management/github-issue-fetch.md` - Fetch GitHub milestones/issues
- `issue-management/jira-issue-fetch.md` - Fetch Jira sprints/issues
- `issue-management/dependency-parsing.md` - Parse issue dependencies

**Progress Tracking**:
- `progress/todo-initialization.md` - Initialize progress tracking
- `progress/phase-tracking.md` - Update progress throughout execution
- `progress/completion-reporting.md` - Final completion report

**Quality Gates**:
- `quality-gates/quality-gate-sequence.md` - Verify PR quality

**Error Handling**:
- `error-handling/partial-failure-recovery.md` - Handle partial sprint failures

**Reporting**:
- `reporting/summary-template.md` - Sprint report structure
- `reporting/artifact-listing.md` - List generated artifacts
- `reporting/metrics-comparison.md` - Aggregate metrics
- `reporting/next-steps-template.md` - Next steps recommendations

## Your Mission

Execute sprint: **$ARGUMENTS**

Coordinate implementation of multiple issues with:
- Automatic dependency detection and resolution
- Parallel execution where possible (max 3 concurrent)
- Integration testing across all changes
- Comprehensive sprint completion reporting

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and multi-agent coordination strategies you MUST follow.

### 2. Use TodoWrite Throughout

Track sprint progress with TodoWrite at every major step:
- Sprint fetched ✅
- Dependencies analyzed ✅
- Batch 1 complete (3 issues) ✅
- Batch 2 in progress...
- etc.

Update status continuously so user can track progress of long-running sprint execution.

---

## Phase 0: Project Context Detection (1-2 min)

<!-- Component: prompts/context/framework-detection.md -->
<!-- Component: prompts/context/testing-framework-detection.md -->
<!-- Component: prompts/context/database-detection.md -->
<!-- Component: prompts/context/project-size-detection.md -->

Quickly gather project context to inform agent and tool selection throughout the sprint. Execute the detection logic from these components:

1. **Framework Detection**: Identify primary framework (Next.js, Django, Laravel, etc.)
2. **Testing Framework Detection**: Detect test frameworks (Jest, Vitest, pytest, etc.)
3. **Database/ORM Detection**: Identify database and ORM (Prisma, Drizzle, Django ORM, etc.)
4. **Project Size Detection**: Categorize as Small/Medium/Large based on file count

### Use Context Throughout Sprint

Based on detected context:
- **Select appropriate specialist agents** for each issue (frontend-developer for Next.js, backend-architect for APIs, etc.)
- **Activate relevant skills** (nextjs-16-expert, typescript-5-expert, etc.)
- **Choose correct test commands** (npm test, pytest, cargo test, etc.)
- **Adapt quality gates** (slower builds on large projects)

Log detected context:
```
Detected Project Context:
- Framework: [Detected Framework + Version]
- Language: [Detected Language]
- Testing: [Detected Test Framework]
- Database: [Detected Database/ORM]
- Project Size: [Small/Medium/Large] ([X] files)

This context will inform agent selection and tooling for all sprint issues.
```

---

## Phase 1: Sprint Detection & Fetching (3-5 min)

### Step 1: Detect Provider from Sprint ID

Analyze `$ARGUMENTS` to determine the provider:

**GitHub Milestone** if:
- Numeric only: `1`, `2`, `123`
- GitHub URL: `https://github.com/owner/repo/milestone/1`
- Milestone name: `"Sprint 23"`, `"v1.5.0"`
- Keyword `current` (will find current milestone)

**Jira Sprint** if:
- Jira sprint format: `PROJ-Sprint-1`, `123` (Jira sprint ID)
- Jira URL: `https://company.atlassian.net/secure/RapidBoard.jspa?rapidView=123&view=planning&sprint=456`
- Keyword `current` with Jira configured

**Linear Cycle** if:
- Linear cycle format: `CYC-123`
- Linear URL: `https://linear.app/team/cycle/[id]`
- Keyword `current` with Linear configured

**Provider Detection Logic**:
```bash
# 1. Check for explicit provider hints
if [[ "$ARGUMENTS" =~ github.com ]]; then
  PROVIDER="github"
elif [[ "$ARGUMENTS" =~ atlassian.net ]]; then
  PROVIDER="jira"
elif [[ "$ARGUMENTS" =~ linear.app ]]; then
  PROVIDER="linear"

# 2. Check format patterns
elif [[ "$ARGUMENTS" =~ ^[A-Z]+-Sprint-[0-9]+$ ]]; then
  PROVIDER="jira"  # PROJ-Sprint-1 format
elif [[ "$ARGUMENTS" =~ ^[0-9]+$ ]]; then
  # Could be GitHub milestone or Jira sprint
  # Check settings for default provider
  # If both enabled, ask user

# 3. Keyword "current"
elif [[ "$ARGUMENTS" == "current" ]]; then
  # Detect from git remote or settings
  # Prefer GitHub if .git/config has github.com remote
fi
```

**If provider is ambiguous, ask user**:
```
Use AskUserQuestion tool:
  Question: "Sprint ID '$ARGUMENTS' could be GitHub or Jira. Which provider?"
  Options:
    - "GitHub Milestone"
    - "Jira Sprint"
```

### Step 2: Fetch Sprint Metadata

<!-- Component: prompts/issue-management/github-issue-fetch.md (adapted for milestones) -->
<!-- Component: prompts/issue-management/jira-issue-fetch.md (adapted for sprints) -->

**For GitHub**, use gh CLI to fetch milestone metadata (similar to github-issue-fetch.md but for milestones).

**For Jira**, use acli to fetch sprint metadata (similar to jira-issue-fetch.md but for sprints).

### Step 3: Fetch All Issues in Sprint

**For GitHub**, use gh CLI to list all issues in the milestone.

**For Jira**, use acli to list all issues in the sprint.

See `prompts/issue-management/github-issue-fetch.md` and `prompts/issue-management/jira-issue-fetch.md` for detailed fetch commands.

### Step 4: Extract Issue Dependencies

<!-- Component: prompts/issue-management/dependency-parsing.md -->

Parse issue bodies/descriptions for dependency markers using the patterns and logic defined in `prompts/issue-management/dependency-parsing.md`:

**Dependency Keywords**: depends on, blocked by, requires, needs, after
**GitHub Patterns**: #123 references, full URLs
**Jira Patterns**: PROJ-123 keys, issue links

Build dependency graph for execution ordering.

### Step 5: Log Sprint Summary

<!-- Component: prompts/progress/todo-initialization.md -->
<!-- Component: prompts/progress/phase-tracking.md -->

Initialize TodoWrite with sprint execution phases (see `prompts/progress/todo-initialization.md` for structure).

Output sprint summary to user:
```markdown
## Sprint Summary: $SPRINT_TITLE

**Provider**: $PROVIDER
**Status**: $SPRINT_STATE
**Due Date**: $DUE_DATE

### Issues Overview
- **Total**: $TOTAL_ISSUES issues
- **Open**: $OPEN_ISSUES (to implement)
- **Closed**: $CLOSED_ISSUES (already done)

### Issues to Implement
1. #123: Add user authentication (priority: high, labels: feature)
2. #124: Create database schema (priority: high, labels: backend)
3. #125: Set up CI/CD pipeline (priority: medium, labels: devops)
4. #126: Build login UI (priority: high, labels: frontend, depends on: #123)
5. #127: Implement user registration (priority: medium, labels: feature, depends on: #123)
...

Proceeding to dependency analysis...
```

---

## Phase 2: Dependency Analysis & Sequencing (5-7 min)

### Step 1: Build Dependency Graph

Create a directed graph of issue dependencies:

```bash
# For each issue, list its dependencies
# Use simple adjacency list format:
# {
#   "123": [],           # No dependencies (can run immediately)
#   "124": [],           # No dependencies
#   "125": [],           # No dependencies
#   "126": ["123"],      # Depends on #123
#   "127": ["123"],      # Depends on #123
#   "128": ["126", "127"] # Depends on #126 and #127
# }
```

### Step 2: Topological Sort (Dependency Resolution)

Determine execution order using topological sort:

**Algorithm**:
1. Find all issues with no dependencies → **Batch 1** (can run in parallel)
2. Remove Batch 1 from graph
3. Find issues whose dependencies are all in Batch 1 → **Batch 2**
4. Remove Batch 2 from graph
5. Repeat until all issues assigned to batches

**Handle Circular Dependencies**:
```bash
# Detect cycles using DFS
if [cycle detected]; then
  echo "ERROR: Circular dependency detected:"
  echo "  Issue #123 depends on #124"
  echo "  Issue #124 depends on #125"
  echo "  Issue #125 depends on #123"
  echo ""
  echo "Cannot determine execution order."
  echo "Please resolve circular dependencies before proceeding."

  Use AskUserQuestion:
    Question: "Circular dependency detected. How to proceed?"
    Options:
      - "Break dependency chain manually"
      - "Execute in arbitrary order (risky)"
      - "Cancel sprint execution"
fi
```

### Step 3: Calculate Parallel Execution Batches

Group issues into batches for parallel execution:

**Constraints**:
- Max 3 issues running in parallel (configurable via settings)
- Issues in same batch must have no dependencies on each other
- Issues must wait for all dependencies to complete before starting

**Example Batches**:
```
Batch 1 (Parallel):
  - #123: Add user authentication
  - #124: Create database schema
  - #125: Set up CI/CD pipeline

Batch 2 (Depends on Batch 1):
  - #126: Build login UI (depends on #123)
  - #127: Implement user registration (depends on #123)

Batch 3 (Depends on Batch 2):
  - #128: Integration testing (depends on #126, #127)
```

### Step 4: Estimate Execution Time

Provide rough time estimate based on issue complexity:

**Estimation Heuristics**:
- **Small issue** (< 50 LOC estimated): 30-60 min
- **Medium issue** (50-200 LOC): 1-2 hours
- **Large issue** (> 200 LOC): 2-4 hours

Estimate based on:
- Issue labels (`bug` faster than `feature`)
- Issue description length (longer = more complex)
- Number of acceptance criteria
- Historical data if available

**Example Estimate**:
```
Estimated Sprint Duration:
- Batch 1: 3 issues × 1.5 hours avg = 1.5 hours (parallel)
- Batch 2: 2 issues × 2 hours avg = 2 hours (parallel)
- Batch 3: 1 issue × 1 hour = 1 hour

Total Sequential Time: 4.5 hours
(vs. 10.5 hours if executed sequentially without parallelization)
```

### Step 5: Get User Approval

Present execution plan and get approval:

```
Use AskUserQuestion tool:
  Question: "Execute sprint with this plan?"

  Options:
    - "Yes, execute all $OPEN_ISSUES issues in parallel batches (Recommended)"
      Description: "Implement all issues with automatic dependency resolution and parallel execution. Estimated time: 4.5 hours."

    - "Modify execution order"
      Description: "Manually adjust which issues to run and in what order."

    - "Execute subset only"
      Description: "Select specific issues to implement (useful for partial sprint execution)."

    - "Cancel"
      Description: "Exit sprint execution."
```

**If "Modify execution order"**:
- Show current batches
- Allow user to move issues between batches
- Re-validate dependencies
- Re-estimate time

**If "Execute subset only"**:
- Allow user to select issues (checkbox list)
- Build dependency graph for selected issues only
- Warn about incomplete dependencies

**Example Output**:
```markdown
## Sprint Execution Plan

**Sprint**: Sprint 23
**Total Issues**: 8 (6 open, 2 closed)
**Estimated Time**: 4.5 hours (parallel) vs 10.5 hours (sequential)

### Execution Strategy

**Parallelization**:
- Max 3 issues running concurrently
- 3 batches total
- Dependency resolution complete

### Batch Breakdown

**Batch 1** (3 issues, ~1.5 hours, parallel):
1. ✅ #123: Add user authentication
   - Priority: High
   - Labels: feature, backend
   - Estimated: 2 hours (authentication implementation)

2. ✅ #124: Create database schema
   - Priority: High
   - Labels: backend, database
   - Estimated: 1 hour (schema definition + migration)

3. ✅ #125: Set up CI/CD pipeline
   - Priority: Medium
   - Labels: devops, infrastructure
   - Estimated: 1.5 hours (GitHub Actions setup)

**Batch 2** (2 issues, ~2 hours, parallel):
Waits for: Batch 1

4. ⏸ #126: Build login UI
   - Priority: High
   - Labels: frontend, ui
   - **Depends on**: #123 (needs auth API)
   - Estimated: 2 hours (React components + forms)

5. ⏸ #127: Implement user registration
   - Priority: Medium
   - Labels: feature, backend
   - **Depends on**: #123 (needs auth system)
   - Estimated: 1.5 hours (registration logic)

**Batch 3** (1 issue, ~1 hour):
Waits for: Batch 2

6. ⏸ #128: Integration testing
   - Priority: High
   - Labels: testing, quality
   - **Depends on**: #126, #127 (needs all features)
   - Estimated: 1 hour (E2E test scenarios)

### Excluded Issues (Already Closed)
- ✅ #129: Update README (closed)
- ✅ #130: Fix typo in docs (closed)

---

**Proceed with this plan?**
```

---

## Phase 3: Batch Execution with Orchestration (Variable, 2-10 hours)

This is the main execution phase where issues are implemented in dependency order with parallel processing.

### Step 1: Initialize Sprint Execution

Update TodoWrite:
```
Sprint execution started
- Batch 1 (in_progress): 3 issues
- Batch 2 (pending): 2 issues
- Batch 3 (pending): 1 issue
```

Create sprint tracking file:
```bash
mkdir -p .agency/sprints
SPRINT_TRACKING_FILE=".agency/sprints/sprint-${SPRINT_ID}-tracking.json"

# Initialize tracking
cat > $SPRINT_TRACKING_FILE << 'EOF'
{
  "sprint_id": "$SPRINT_ID",
  "sprint_title": "$SPRINT_TITLE",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "batches": [
    {
      "batch_number": 1,
      "status": "in_progress",
      "issues": [...]
    },
    ...
  ],
  "completed_issues": [],
  "failed_issues": [],
  "blocked_issues": []
}
EOF
```

### Step 2: Execute Batch (Parallel Orchestration)

For each batch in order:

**Parallel Execution Pattern**:
```bash
# For each issue in current batch
BATCH_ISSUES=(123 124 125)  # Example: Batch 1

# Spawn work agents in parallel (max 3 concurrent)
for ISSUE in "${BATCH_ISSUES[@]}"; do
  # Use Task tool to spawn work agent
  Task tool with:
    subagent_type: agents-orchestrator
    run_in_background: true  # Run in background for parallelization
    description: "Implement issue #$ISSUE for sprint $SPRINT_ID"
    prompt: "
Execute /agency:work $ISSUE

Context:
- Part of sprint: $SPRINT_TITLE (ID: $SPRINT_ID)
- Batch: Batch 1 (3 issues total in this batch)
- Dependencies resolved: All dependencies complete
- Project context: $DETECTED_FRAMEWORK, $DETECTED_TESTING

Sprint-specific instructions:
- Do NOT merge PRs automatically (sprint orchestrator will handle merging)
- Create PR and mark as ready for review
- Ensure tests pass before marking complete
- Use branch naming: sprint-$SPRINT_ID/issue-$ISSUE

Follow standard /agency:work workflow:
1. Fetch issue details
2. Create feature branch
3. Plan implementation
4. Implement changes
5. Run tests
6. Create PR (do not merge)
7. Report completion

Important: This issue is part of a batch of 3 issues running in parallel.
"

  # Store task ID for later retrieval
  TASK_IDS+=("$TASK_ID")
done

# Wait for all tasks in batch to complete
for TASK_ID in "${TASK_IDS[@]}"; do
  Use TaskOutput tool with:
    task_id: $TASK_ID
    block: true  # Wait for completion

  # Check if task succeeded
  if [task failed]; then
    # Mark issue as failed
    FAILED_ISSUES+=("$ISSUE")

    # Log failure
    echo "Issue #$ISSUE failed during implementation"
    echo "Error: [error details from task output]"
    echo ""

    # Continue with other issues (don't block entire batch)
  else
    # Mark issue as completed
    COMPLETED_ISSUES+=("$ISSUE")

    # Extract PR number from task output
    PR_NUMBER=[extract from task output]

    # Store PR mapping
    echo "$ISSUE -> PR #$PR_NUMBER" >> pr-mappings.txt
  fi
done

# Update TodoWrite
TodoWrite: "Batch 1 completed (3/3 issues)"
```

### Step 3: Handle Failures Gracefully

<!-- Component: prompts/error-handling/partial-failure-recovery.md -->

If an issue fails during implementation, use the partial failure recovery strategies from `prompts/error-handling/partial-failure-recovery.md`:

1. Mark as failed/blocked
2. Check if other issues depend on this one
3. Mark dependents as blocked
4. Continue with other issues in batch
5. Log failure details for sprint report

**Don't Block Entire Sprint**:
- Failed issues don't stop other independent issues
- Blocked issues (dependencies failed) are marked but don't halt execution
- Sprint continues with maximum possible progress

### Step 4: Track Progress Throughout Execution

<!-- Component: prompts/progress/phase-tracking.md -->

Continuously update TodoWrite as each issue completes using the phase tracking patterns from `prompts/progress/phase-tracking.md`:

- Mark completed batches as `completed`
- Mark current batch as `in_progress`
- Keep future batches as `pending`
- Update after each issue completion for visibility

### Step 5: Wait for Batch Completion Before Next Batch

Before starting next batch:
1. Verify all issues in current batch are complete or failed
2. Update dependency graph (remove completed issues)
3. Check if next batch issues are now unblocked
4. If any next-batch issues are blocked by failures, mark them as blocked

```bash
# Before starting Batch 2
for ISSUE in "${BATCH_2_ISSUES[@]}"; do
  # Check if dependencies are satisfied
  DEPS=$(get dependencies for $ISSUE)

  for DEP in $DEPS; do
    if [[ " ${FAILED_ISSUES[@]} " =~ " ${DEP} " ]]; then
      # Dependency failed, block this issue
      BLOCKED_ISSUES+=("$ISSUE")
      echo "Issue #$ISSUE blocked (dependency #$DEP failed)"
      continue 2  # Skip to next issue
    fi
  done

  # All dependencies satisfied, can proceed
  RUNNABLE_ISSUES+=("$ISSUE")
done

# Execute only runnable issues
if [ ${#RUNNABLE_ISSUES[@]} -eq 0 ]; then
  echo "No runnable issues in Batch 2 (all blocked)"
  # Skip to next batch or end sprint
else
  # Execute runnable issues
  [... spawn agents for runnable issues ...]
fi
```

### Step 6: Inter-Batch Progress Summary

After each batch completes, show summary:

```markdown
## Batch 1 Complete (3/3 issues)

### ✅ Completed (3)
1. #123: Add user authentication
   - PR: #456
   - Time: 1.8 hours
   - Status: ✅ All tests passing

2. #124: Create database schema
   - PR: #457
   - Time: 0.9 hours
   - Status: ✅ All tests passing

3. #125: Set up CI/CD pipeline
   - PR: #458
   - Time: 1.3 hours
   - Status: ✅ All tests passing

### 📊 Batch Statistics
- Completion rate: 100% (3/3)
- Average time: 1.3 hours
- Quality: All PRs passing tests ✅

**Moving to Batch 2** (2 issues)...
```

---

## Phase 4: Quality Verification (10-15 min)

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->
<!-- Component: prompts/reporting/metrics-comparison.md -->

After all batches complete, verify quality of all implemented changes.

### Step 1: Aggregate PR List

Collect all PRs created during sprint from pr-mappings tracking.

### Step 2: Verify Each PR Passes Quality Gates

For each PR, run the quality gate sequence defined in `prompts/quality-gates/quality-gate-sequence.md`:

1. Build verification
2. Type checking
3. Linting
4. Test execution
5. Coverage validation

Track which PRs pass all gates vs. which have issues.

### Step 3: Aggregate Quality Metrics

<!-- Component: prompts/reporting/metrics-comparison.md -->

Collect metrics across all PRs:
- Total code changes (+lines, -lines, files changed)
- Test results (passed/failed/total)
- Coverage percentage
- Build status
- Security scan results (if applicable)

### Step 4: Handle Quality Issues

If quality issues detected:

```
Use AskUserQuestion:
  Question: "Some PRs have quality issues. How to proceed?"

  Options:
    - "Fix issues before merging (Recommended)"
      Description: "Address all quality issues ($ISSUE_COUNT issues found) before proceeding to merge."

    - "Merge passing PRs only"
      Description: "Merge ${#QUALITY_PASSED_PRS[@]} PRs that pass quality gates, skip ${#QUALITY_ISSUES[@]} with issues."

    - "Continue anyway (skip quality check)"
      Description: "Proceed to merge despite quality issues. Not recommended."

    - "Abort sprint merge"
      Description: "Stop here, don't merge any PRs. Manual review required."
```

If "Fix issues":
- For each quality issue, identify root cause
- Attempt auto-fix where possible (resolve conflicts, re-run tests)
- For issues requiring manual intervention, notify user

### Step 5: Quality Verification Summary

```markdown
## Quality Verification Summary

### Overview
- **Total PRs**: 6
- **Passing Quality Gates**: 5 ✅
- **Quality Issues**: 1 ⚠️

### Aggregate Metrics

**Code Changes**:
- Total Additions: +1,234 lines
- Total Deletions: -567 lines
- Files Changed: 47 files

**Test Results**:
- All Tests: 234/234 passing ✅
- New Tests: +45 tests
- Coverage: 85% (target: 80%) ✅

**Build Status**: ✅ Passing

**Security**: ✅ No vulnerabilities detected

### PR Quality Status

✅ **PR #456** (Issue #123: Add user authentication)
- CI: ✅ Passing
- Tests: ✅ 12/12 passing
- Review: ✅ Approved
- Mergeable: ✅ No conflicts

✅ **PR #457** (Issue #124: Create database schema)
- CI: ✅ Passing
- Tests: ✅ 8/8 passing
- Review: ✅ Approved
- Mergeable: ✅ No conflicts

[... continue for all PRs ...]

⚠️ **PR #460** (Issue #127: Implement user registration)
- CI: ⚠️ 1 check pending
- Tests: ✅ 15/15 passing
- Review: ⚠️ Awaiting approval
- Mergeable: ✅ No conflicts

**Issues**: CI check pending (ESlint), needs reviewer approval

---

**Quality gate status**: 5/6 PRs ready to merge
```

---

## Phase 5: Integration Testing (10-20 min)

Test that all sprint changes work together when merged.

### Step 1: Create Integration Branch

```bash
# Ensure on latest main
git checkout main
git pull origin main

# Create integration test branch
INTEGRATION_BRANCH="sprint-${SPRINT_ID}-integration"
git checkout -b $INTEGRATION_BRANCH

echo "Created integration branch: $INTEGRATION_BRANCH"
```

### Step 2: Merge All PRs into Integration Branch

Merge all passing PRs in dependency order:

```bash
# Merge in dependency order (batches)
for BATCH in "${BATCHES[@]}"; do
  for ISSUE in "${BATCH_ISSUES[@]}"; do
    PR_NUMBER=$(get PR number for issue $ISSUE)

    echo "Merging PR #$PR_NUMBER (Issue #$ISSUE)..."

    # Merge PR into integration branch
    gh pr checkout $PR_NUMBER
    git checkout $INTEGRATION_BRANCH
    git merge --no-ff pr-${PR_NUMBER} -m "Merge PR #$PR_NUMBER: Issue #$ISSUE"

    if [ $? -ne 0 ]; then
      echo "⚠️ Merge conflict detected in PR #$PR_NUMBER"
      MERGE_CONFLICTS+=("PR #$PR_NUMBER: Issue #$ISSUE")

      # Attempt auto-resolve
      # If auto-resolve fails, mark and continue
      git merge --abort
      continue
    fi

    echo "✅ Merged PR #$PR_NUMBER successfully"
  done
done
```

### Step 3: Run Full Test Suite on Integration Branch

```bash
echo "Running full test suite on integration branch..."

# Run tests
if [ -f "package.json" ]; then
  npm test
  TEST_RESULT=$?
elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
  pytest
  TEST_RESULT=$?
elif [ -f "Cargo.toml" ]; then
  cargo test
  TEST_RESULT=$?
fi

if [ $TEST_RESULT -ne 0 ]; then
  echo "❌ Integration tests failed"
  INTEGRATION_TEST_FAILED=true
else
  echo "✅ All integration tests passing"
  INTEGRATION_TEST_FAILED=false
fi
```

### Step 4: Check for Integration Issues

Identify issues that only appear when PRs are merged together:

**Common Integration Issues**:
1. **Merge Conflicts**: Code changes overlap
2. **API Contract Mismatches**: Frontend expects API that backend changed
3. **Database Schema Conflicts**: Multiple migrations conflict
4. **Configuration Conflicts**: Environment variables clash
5. **Test Conflicts**: Test setup/teardown issues

**Detection**:
```bash
if [ $INTEGRATION_TEST_FAILED = true ]; then
  echo "Integration issues detected. Analyzing..."

  # Check for common issues

  # 1. Database migration conflicts
  if [ -d "prisma/migrations" ] || [ -d "db/migrate" ]; then
    # Check for conflicting migrations
    # [migration conflict detection logic]
  fi

  # 2. API route conflicts
  if [ -d "src/app/api" ] || [ -d "api/routes" ]; then
    # Check for duplicate route definitions
    # [route conflict detection logic]
  fi

  # 3. Environment variable conflicts
  if [ -f ".env.example" ]; then
    # Check if PRs added conflicting env vars
    # [env var conflict detection logic]
  fi

  # Generate conflict report
  cat > integration-issues.md << 'EOF'
# Integration Test Failures

## Test Failures
[list of failing tests]

## Likely Causes
[analysis of conflicts]

## Conflicting PRs
[PRs that likely conflict]

## Recommended Resolution
[suggestions to fix]
EOF
fi
```

### Step 5: Integration Test Results

```markdown
## Integration Test Results

### Integration Branch: `sprint-23-integration`

**Merge Status**:
- ✅ 5/6 PRs merged successfully
- ⚠️ 1 PR has merge conflicts

**Test Results**:
- ❌ 3 tests failing (out of 234 total)
- ✅ Coverage maintained: 85%

### Failing Tests

1. **test/integration/auth-flow.test.ts**
   - Test: "Login redirect after authentication"
   - Error: `Expected redirect to /dashboard, got /home`
   - **Likely cause**: Conflict between PR #456 (auth) and PR #459 (login UI)
   - **Resolution**: Align redirect paths between auth service and UI

2. **test/integration/db-migration.test.ts**
   - Test: "All migrations apply cleanly"
   - Error: `Migration 003_add_user_roles conflicts with 004_add_auth_tokens`
   - **Likely cause**: PR #457 and PR #456 both modified users table
   - **Resolution**: Merge migrations or reorder

3. **test/e2e/registration.test.ts**
   - Test: "User can register and login"
   - Error: `Email validation failed`
   - **Likely cause**: Different email validation in PR #460 vs PR #456
   - **Resolution**: Standardize email validation

### Merge Conflicts

⚠️ **PR #460** (Issue #127)
- Conflicts in: `src/lib/validation.ts`
- Between: PR #456 (auth validation) and PR #460 (registration validation)
- **Resolution needed**: Manual merge of validation logic

---

**Recommendation**: Fix 3 integration issues before proceeding to merge
```

### Step 6: Handle Integration Failures

If integration tests fail:

```
Use AskUserQuestion:
  Question: "Integration tests revealed conflicts. How to proceed?"

  Options:
    - "Fix conflicts automatically (Recommended)"
      Description: "Attempt to auto-resolve the 3 identified conflicts. May require manual review."

    - "Fix conflicts manually"
      Description: "Provide conflict details for manual resolution before merging."

    - "Merge PRs sequentially with testing"
      Description: "Merge PRs one at a time, testing after each merge. Slower but safer."

    - "Abort integration"
      Description: "Stop here, don't merge any PRs. Conflicts require investigation."
```

If "Fix automatically":
- Attempt to resolve conflicts using AI assistance
- Generate unified fixes for common conflicts
- Re-run tests after each fix
- If auto-fix fails, escalate to manual

If "Merge sequentially":
- Merge PRs one at a time in dependency order
- Run tests after each merge
- If tests fail, rollback that merge
- Identify which PR caused the failure

---

## Phase 6: PR Review & Merging (5-30 min)

Merge all approved PRs that pass quality gates.

### Step 1: Select Merge Strategy

Present merge strategy options:

```
Use AskUserQuestion:
  Question: "Select merge strategy for sprint PRs"

  Options:
    - "Sequential Merge (Recommended - Safest)"
      Description: "Merge PRs one at a time in dependency order. Run tests after each merge. Rollback if any tests fail. Slower but safest approach."

    - "Batch Merge (Faster)"
      Description: "Merge all PRs that passed integration tests. Run tests once after all merges. Faster but riskier if integration tests missed issues."

    - "Manual Review"
      Description: "Present PRs for manual merge via GitHub UI. You control the merge timing and method."
```

### Step 2: Execute Merge Strategy

**Sequential Merge** (safest):
```bash
# Merge PRs one at a time
for PR in "${ORDERED_PR_LIST[@]}"; do
  echo "Merging PR #$PR..."

  # Check if PR is approved
  REVIEW_STATUS=$(gh pr view $PR --json reviewDecision --jq '.reviewDecision')
  if [[ "$REVIEW_STATUS" != "APPROVED" ]]; then
    echo "⚠️ PR #$PR not approved, skipping"
    SKIPPED_PRS+=("$PR")
    continue
  fi

  # Merge PR
  gh pr merge $PR --squash --delete-branch --auto

  # Wait for merge to complete
  sleep 3

  # Pull latest main
  git checkout main
  git pull origin main

  # Run tests
  npm test
  if [ $? -ne 0 ]; then
    echo "❌ PR #$PR caused test failures"

    # Revert the merge
    git revert HEAD --no-edit
    git push origin main

    echo "Reverted PR #$PR merge"
    REVERTED_PRS+=("$PR")

    # Ask user how to proceed
    Use AskUserQuestion:
      Question: "PR #$PR caused tests to fail after merge. Continue with remaining PRs?"
      Options:
        - "Yes, continue"
        - "No, stop merging"
  else
    echo "✅ PR #$PR merged successfully, tests passing"
    MERGED_PRS+=("$PR")
  fi
done
```

**Batch Merge** (faster):
```bash
# Merge all PRs at once
for PR in "${PR_NUMBERS[@]}"; do
  gh pr merge $PR --squash --delete-branch --auto
done

# Wait for all merges
sleep 10

# Pull latest main
git checkout main
git pull origin main

# Run tests once
npm test
if [ $? -ne 0 ]; then
  echo "❌ Batch merge caused test failures"

  # Revert all merges
  git reset --hard HEAD~${#PR_NUMBERS[@]}
  git push origin main --force

  echo "All merges reverted due to test failures"

  # Fall back to sequential merge
  Use AskUserQuestion:
    Question: "Batch merge failed. Switch to sequential merge?"
    Options:
      - "Yes, merge sequentially"
      - "No, stop merging"
else
  echo "✅ All PRs merged successfully, tests passing"
fi
```

**Manual Review**:
```markdown
## PRs Ready for Manual Merge

Please review and merge these PRs via GitHub:

1. **PR #456** - Add user authentication
   - Issue: #123
   - Status: ✅ Approved, all checks passing
   - Link: https://github.com/owner/repo/pull/456

2. **PR #457** - Create database schema
   - Issue: #124
   - Status: ✅ Approved, all checks passing
   - Link: https://github.com/owner/repo/pull/457

[... continue for all PRs ...]

**Recommended merge order**: #456 → #457 → #458 → #459 → #460 → #461

After merging all PRs, I will verify tests pass and generate sprint completion report.
```

### Step 3: Handle Merge Failures

If a PR fails to merge:

```bash
# Capture merge error
MERGE_ERROR=$(gh pr merge $PR 2>&1)

# Common merge failure reasons:
# 1. Merge conflicts
# 2. Required checks not passing
# 3. Required reviews missing
# 4. Branch protection rules

# Provide specific guidance
if [[ "$MERGE_ERROR" == *"conflict"* ]]; then
  echo "PR #$PR has merge conflicts that need manual resolution"
elif [[ "$MERGE_ERROR" == *"required status check"* ]]; then
  echo "PR #$PR has failing required checks"
elif [[ "$MERGE_ERROR" == *"required approving review"* ]]; then
  echo "PR #$PR needs approval from a code owner"
fi
```

### Step 4: Update Sprint Status

After merging:

**For GitHub**:
```bash
# If all issues merged, close milestone
if [ ${#MERGED_PRS[@]} -eq ${#PR_NUMBERS[@]} ]; then
  gh api "repos/$REPO/milestones/$MILESTONE_NUMBER" -X PATCH \
    -f state='closed'
  echo "✅ Milestone closed"
fi
```

**For Jira**:
```bash
# Transition issues to "Done"
for ISSUE in "${MERGED_ISSUES[@]}"; do
  acli issue transition $ISSUE "Done"
done

# Close sprint if all issues complete
if [ ${#MERGED_ISSUES[@]} -eq ${#TOTAL_ISSUES[@]} ]; then
  acli sprint complete $SPRINT_ID
  echo "✅ Sprint closed"
fi
```

### Step 5: Merge Summary

```markdown
## Merge Results

### Successfully Merged (5)
✅ PR #456 - Issue #123: Add user authentication
✅ PR #457 - Issue #124: Create database schema
✅ PR #458 - Issue #125: Set up CI/CD pipeline
✅ PR #459 - Issue #126: Build login UI
✅ PR #461 - Issue #128: Integration testing

### Skipped (1)
⚠️ PR #460 - Issue #127: Implement user registration
   - Reason: Not approved by code owner
   - Action: Requires manual review

### Reverted (0)
(None)

---

**Final Status**:
- Merged: 5/6 PRs (83%)
- Main branch: ✅ All tests passing
- Sprint: 83% complete (5/6 issues)
```

---

## Phase 7: Sprint Report & Analytics (5-7 min)

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/artifact-listing.md -->
<!-- Component: prompts/reporting/metrics-comparison.md -->
<!-- Component: prompts/progress/completion-reporting.md -->

Generate comprehensive sprint completion report.

### Step 1: Calculate Sprint Metrics

Calculate the following metrics for the sprint summary:
- Time metrics (start, end, duration)
- Issue metrics (total, completed, failed, blocked, completion rate)
- Code metrics (additions, deletions, files changed)
- Quality metrics (tests, coverage)

Use the metrics comparison format from `prompts/reporting/metrics-comparison.md`.

### Step 2: Generate Execution Timeline

Create visual timeline of batch execution:

```markdown
## Execution Timeline

**Total Duration**: 4.2 hours

```
Timeline:
│
├─ 00:00  Sprint started
│
├─ 00:05  Batch 1 started (3 issues, parallel)
│   ├─ #123: Add user authentication
│   ├─ #124: Create database schema
│   └─ #125: Set up CI/CD pipeline
│
├─ 01:50  Batch 1 complete (1h 45min)
│
├─ 01:55  Batch 2 started (2 issues, parallel)
│   ├─ #126: Build login UI
│   └─ #127: Implement user registration
│
├─ 03:50  Batch 2 complete (1h 55min)
│
├─ 03:55  Batch 3 started (1 issue)
│   └─ #128: Integration testing
│
├─ 04:00  Batch 3 complete (5 min)
│
├─ 04:05  Quality verification
├─ 04:10  Integration testing
├─ 04:15  PR merging
│
└─ 04:20  Sprint complete ✅
```
```

### Step 3: Analyze Learnings

Identify what went well and what could improve:

```bash
# What went well
POSITIVES=(
  "Parallel execution saved $(calculate time saved) hours"
  "Clear dependency mapping prevented blockers"
  "Automated testing caught ${#BUGS_CAUGHT[@]} bugs early"
  "All PRs followed coding standards"
)

# What could improve
IMPROVEMENTS=(
  "Issue #127 had unclear requirements (2 hour delay)"
  "Database migrations conflicted (1 hour to resolve)"
  "Better estimation needed for UI work (+30% over estimate)"
)

# Recommendations for next sprint
RECOMMENDATIONS=(
  "Define acceptance criteria more clearly upfront"
  "Coordinate database changes earlier in planning"
  "Allocate 20% buffer for UI polish and refinement"
  "Consider pair programming for complex issues"
)
```

### Step 4: Generate Sprint Completion Report

<!-- Component: prompts/reporting/summary-template.md (adapted for sprints) -->
<!-- Component: prompts/reporting/artifact-listing.md -->

Create comprehensive markdown report using the summary template structure from `prompts/reporting/summary-template.md`, adapted for sprint context:

- Sprint metadata (ID, title, dates, duration)
- Issue completion summary
- Per-issue results
- Quality metrics
- Artifacts listing (PRs, reports, tracking files)
- Known issues/failures
- Next steps

### Step 5: Save Report and Communicate Results

<!-- Component: prompts/progress/completion-reporting.md -->
<!-- Component: prompts/reporting/next-steps-template.md -->

Save the sprint report to `.agency/sprints/sprint-${SPRINT_ID}-report-$(date +%Y%m%d).md`

Update TodoWrite with final status: "Sprint execution complete"

Display concise summary to user using the completion reporting format from `prompts/progress/completion-reporting.md` and next steps from `prompts/reporting/next-steps-template.md`.

---

## Important Notes

### Parallel Execution Safeguards

**Resource Management**:
- Maximum 3 agents running concurrently (prevent system overload)
- Each agent runs in isolated context (no state sharing)
- Agents use separate git branches (no conflicts)

**Coordination**:
- TodoWrite provides visibility into parallel execution
- TaskOutput blocks until agent completes
- Failures don't cascade (one issue failing doesn't stop others)

**Database Safety**:
- Migrations run sequentially (not parallel)
- Schema changes coordinated to avoid conflicts
- Integration testing catches migration issues

### Error Recovery

**Graceful Degradation**:
- Failed issues don't block entire sprint
- Dependent issues marked as blocked automatically
- Sprint continues with maximum possible progress

**Rollback Strategy**:
- Each batch is a checkpoint
- Can rollback to previous batch if needed
- Integration branch allows testing before merging to main

### Time Management

**Realistic Estimates**:
- Estimates are guidelines, not guarantees
- Track actual time vs estimated for future improvement
- Don't rush quality for timeline

**Long-Running Sprints**:
- User can pause/resume sprint execution
- State saved to `.agency/sprints/sprint-${SPRINT_ID}-tracking.json`
- Resume from last completed batch

### Provider-Specific Notes

**GitHub**:
- Milestones are GitHub's sprint equivalent
- Use GitHub Projects for additional sprint management
- PR auto-linking via commit messages ("Closes #123")

**Jira**:
- Sprints are first-class in Jira
- Automatic status transitions when PR merged
- Sprint reports available in Jira

---

## Error Handling

### If Sprint Fetching Fails

**Provider Not Authenticated**:
- Verify `gh auth status` (GitHub) or `acli` configuration (Jira)
- Re-authenticate if needed: `gh auth login` or configure acli
- Provide manual instructions if auth can't be automated

**Sprint Not Found**:
- Verify sprint ID is correct
- Check if sprint exists in provider
- Ask user to provide correct sprint ID

**No Issues in Sprint**:
- Verify sprint contains issues
- If sprint is empty, inform user and exit gracefully
- Suggest alternative sprints

### If Dependency Resolution Fails

**Circular Dependencies Detected**:
- Report the circular dependency chain
- Ask user to resolve manually (remove one dependency link)
- Cannot proceed with circular dependencies

**Invalid Dependency Reference**:
- Issue references non-existent issue
- Warn user, treat as no dependency
- Continue with execution

### If Batch Execution Fails

**Issue Implementation Fails**:
- Log the error for that specific issue
- Mark issue as "failed" in tracking
- Mark dependent issues as "blocked"
- Continue with other independent issues
- Include failure report in sprint summary

**Multiple Issues Fail**:
- If >50% of batch fails, pause and ask user
- Options: Continue, Abort sprint, Retry failed issues
- Provide detailed error summary

**Agent Timeout**:
- Default timeout: 10 minutes per issue
- If timeout, ask user: Extend timeout / Skip issue / Abort
- Save progress before timeout

### If Integration Testing Fails

**Merge Conflicts**:
- Report which PRs conflict
- Provide conflict resolution guidance
- Ask user to resolve manually
- Cannot auto-merge conflicting PRs

**Tests Fail on Integration Branch**:
- Identify which PRs caused failures (via bisect approach)
- Report problematic PRs to user
- Options: Fix PRs / Remove from integration / Manual merge

**Build Fails on Integration Branch**:
- Same as test failures
- Identify and report problematic PRs
- Cannot merge PRs that break build

### If PR Merging Fails

**GitHub API Error**:
- Retry once with exponential backoff
- If still fails, provide manual merge instructions
- Log error details for debugging

**PR Not Ready**:
- Required approvals missing
- CI checks not passing
- Cannot auto-merge, report to user

**Branch Protection Rules**:
- Cannot bypass branch protection
- Inform user of requirements
- Provide guidance on fulfilling requirements

### If User Interrupts Sprint

**Graceful Shutdown**:
- Complete currently running issue implementations
- Save state to `.agency/sprints/sprint-${SPRINT_ID}-tracking.json`
- Generate partial progress report
- Provide resume instructions:
  ```bash
  # Resume sprint from saved state
  /agency:sprint ${SPRINT_ID} --resume
  ```

**Resume from Saved State**:
- Load tracking JSON
- Show what was completed
- Continue from next batch
- Skip already-completed issues

---

## Skills to Reference

**Required**:
- `agency-workflow-patterns` - Multi-agent orchestration

**Optional** (activate based on project detection):
- `nextjs-16-expert` - If Next.js detected
- `typescript-5-expert` - If TypeScript detected
- `github-workflow-best-practices` - For GitHub workflows
- `code-review-standards` - For PR quality checks
- `testing-strategy-standards` - For test generation

---

## Related Commands

- `/agency:work [issue]` - Implement single issue (used internally per sprint issue)
- `/agency:plan [issue]` - Plan sprint without execution
- `/agency:review [pr]` - Review individual PR from sprint
- `/agency:test [component]` - Generate tests for sprint changes
