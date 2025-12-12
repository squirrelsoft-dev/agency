---
description: Execute implementation from an existing plan file
argument-hint: plan-file path [--branch]
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion
---

# Implement from Plan: $ARGUMENTS

Execute implementation from an existing plan file with specialist delegation and quality gates.

## Your Mission

Implement the plan from: **$ARGUMENTS**

Follow the implementation lifecycle: validate plan → [branch creation] → select specialist → implement → [commit] → verify → review → [commit fixes] → report → [create PR].

## Parse Arguments

**Extract flags and plan file path**:

```bash
# Check if --branch flag is present
BRANCH_FLAG=false
PLAN_FILE=""

if [[ "$ARGUMENTS" == *"--branch"* ]]; then
  BRANCH_FLAG=true
  # Remove --branch flag to get plan file path
  PLAN_FILE=$(echo "$ARGUMENTS" | sed 's/--branch//g' | xargs)
else
  PLAN_FILE="$ARGUMENTS"
fi
```

**Flag Behavior**:
- `--branch`: Enables full git workflow:
  - **Phase 1.5**: Create git branch after plan validation
  - **Phase 3.5**: Commit implementation changes
  - **Phase 5.5**: Commit code review fixes (if any)
  - **Phase 7**: Push branch and create pull request
  - Complete end-to-end: branch → implement → commit → PR

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

---

## Phase 1: Plan Validation & Parsing (3-5 min)

### Read Plan File

**Plan File Location**:
- If `$PLAN_FILE` is a full path: Read directly
- If `$PLAN_FILE` is just a filename: Look in `.agency/plans/`
- If `$PLAN_FILE` doesn't include `.md`: Add `.md` extension

```bash
# Example paths to check:
# 1. $PLAN_FILE (if full path)
# 2. .agency/plans/$PLAN_FILE (if filename)
# 3. .agency/plans/$PLAN_FILE.md (if no extension)
```

Use the Read tool to load the plan file contents.

### Extract Plan Components

Parse the plan file and extract:

**Required Components**:
- **Objective**: What are we building?
- **Requirements**: List of functional requirements
- **File Changes**: Which files will be created/modified
- **Implementation Steps**: Ordered sequence of tasks
- **Success Criteria**: How to verify completion
- **Dependencies**: External libraries, APIs, services

**Optional Components**:
- **Architecture Decisions**: Technical approach rationale
- **Testing Strategy**: How to validate the implementation
- **Rollback Plan**: How to undo if needed
- **Performance Targets**: Expected benchmarks

### Validate Plan Completeness

Check the plan has:
- [ ] Clear objective statement
- [ ] At least 3 implementation steps
- [ ] List of files to modify/create
- [ ] Success criteria defined
- [ ] No placeholder text ([TODO], [TBD], etc.)

If plan is incomplete, ask the user:
```
Use AskUserQuestion tool to clarify:
- Missing requirements
- Unclear implementation steps
- Undefined success criteria
```

**Do NOT proceed** if plan validation fails. Get user input first.

---

## Phase 1.5: Branch Creation (if --branch flag present) (1-2 min)

**ONLY execute this phase if `$BRANCH_FLAG` is true.**

Follow the branch creation workflow from `prompts/git/branch-creation.md`:

### Step 1: Get Default Branch

Determine the repository's default branch:

```bash
# Get default branch name from git config
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

# Fallback: check common branch names
if [ -z "$DEFAULT_BRANCH" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    DEFAULT_BRANCH="master"
  else
    # Ask user for default branch
    Use AskUserQuestion tool:
    "What is your default branch? (main/master/other)"
  fi
fi
```

### Step 2: Check Current Branch

Verify if we're on the default branch:

```bash
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]]; then
  echo "⚠️ Not on default branch. Currently on: $CURRENT_BRANCH"
  echo "Need to switch to $DEFAULT_BRANCH first."
fi
```

### Step 3: Checkout Default Branch and Pull (if needed)

If not on default branch:

```bash
# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  Use AskUserQuestion tool:
  "You have uncommitted changes. What would you like to do?

  Options:
  1. Stash changes and switch to $DEFAULT_BRANCH (Recommended)
  2. Commit changes first
  3. Cancel branch creation"

  # Handle response:
  # Option 1: git stash push -m "WIP before branch creation"
  # Option 2: Guide user through commit process
  # Option 3: Exit Phase 1.5, skip to Phase 2
fi

# Checkout default branch
git checkout $DEFAULT_BRANCH

# Pull latest changes
git pull origin $DEFAULT_BRANCH
```

**Quality Gate**: Must be on default branch with latest changes before creating new branch.

### Step 4: Generate Branch Name

Extract feature name from plan file and create branch name:

```bash
# Extract feature name from plan filename
# Example: plan-user-authentication.md → user-authentication
FEATURE_NAME=$(basename "$PLAN_FILE" .md | sed 's/^plan-//')

# Determine branch type from plan content or keywords
# Scan plan for keywords to determine type:
BRANCH_TYPE="feat"  # Default

# Check plan content for type indicators:
if grep -qi "fix\|bug" "$PLAN_FILE_PATH"; then
  BRANCH_TYPE="fix"
elif grep -qi "refactor" "$PLAN_FILE_PATH"; then
  BRANCH_TYPE="refactor"
elif grep -qi "docs\|documentation" "$PLAN_FILE_PATH"; then
  BRANCH_TYPE="docs"
elif grep -qi "test" "$PLAN_FILE_PATH"; then
  BRANCH_TYPE="test"
elif grep -qi "chore" "$PLAN_FILE_PATH"; then
  BRANCH_TYPE="chore"
fi

# Construct branch name
BRANCH_NAME="${BRANCH_TYPE}/${FEATURE_NAME}"

# Extract issue number if present in plan
if [[ "$FEATURE_NAME" =~ issue-([0-9]+) ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
  # Already included in feature name, keep as is
fi
```

**Present branch name to user**:

```
Use AskUserQuestion tool:
"Ready to create branch: $BRANCH_NAME

Based on:
- Plan file: $PLAN_FILE
- Base branch: $DEFAULT_BRANCH
- Branch type: $BRANCH_TYPE

Proceed with this branch name?"

Options:
- Yes, create branch (Recommended)
- Use different branch name
```

### Step 5: Create Branch

Create and checkout the new branch:

```bash
# Create and switch to new branch
git checkout -b "$BRANCH_NAME"

# Verify branch created successfully
CREATED_BRANCH=$(git branch --show-current)

if [[ "$CREATED_BRANCH" == "$BRANCH_NAME" ]]; then
  echo "✅ Branch created successfully: $BRANCH_NAME"
  echo "📍 Base: $DEFAULT_BRANCH ($(git rev-parse --short HEAD))"
else
  echo "❌ Branch creation failed"
  # Ask user how to proceed
fi
```

### Step 6: Branch Creation Report

```markdown
## Branch Created

**Branch Name**: $BRANCH_NAME
**Base Branch**: $DEFAULT_BRANCH
**Created From**: [commit hash] ([commit message])
**Status**: ✅ Clean working directory
**Remote Tracking**: ⚠️ Not yet pushed (will push after implementation)

**Next Steps**:
1. Continue with Phase 2: Specialist Selection
2. Implementation will occur on this branch
3. Branch will be pushed during PR creation in Phase 6
```

**Store branch name for later phases**:
```bash
IMPLEMENTATION_BRANCH="$BRANCH_NAME"
# This will be used in Phase 6 when creating PRs
```

---

## Phase 2: Multi-Specialist Detection & Selection (2-5 min)

### Step 1: Keyword Scoring Algorithm

Scan the plan and score each specialist domain based on keyword matches:

#### Scoring System

For each specialist, count keyword matches and calculate score:
- **Score = (keyword_matches × 0.5)**
- **Threshold**: Score > 2.0 → Specialist needed

**Use keyword analysis from**: `prompts/specialist-selection/keyword-analysis.md`

#### Analysis Output

```markdown
**Keyword Analysis Results**:

Frontend Developer:
- Keywords found: React, component, Tailwind, UI, form [5 matches]
- Score: 2.5
- Status: ✅ NEEDED

Backend Architect:
- Keywords found: API, database, authentication, JWT [4 matches]
- Score: 2.0
- Status: ✅ NEEDED

Mobile App Builder:
- Keywords found: [0 matches]
- Score: 0.0
- Status: ❌ NOT NEEDED

AI Engineer:
- Keywords found: [0 matches]
- Score: 0.0
- Status: ❌ NOT NEEDED

DevOps Automator:
- Keywords found: [0 matches]
- Score: 0.0
- Status: ❌ NOT NEEDED
```

### Step 2: Single vs Multi-Specialist Decision

**IF only ONE specialist scores > 2.0**:
→ Go to **Single-Specialist Mode** (Step 3A)

**IF multiple specialists score > 2.0**:
→ Go to **Multi-Specialist Mode** (Step 3B)

**IF NO specialists score > 2.0**:
→ Use `senior-developer` as fallback

---

### Step 3A: Single-Specialist Mode (Traditional Path)

**Use user approval from**: `prompts/specialist-selection/user-approval.md`

Present the selected specialist:
```
Use AskUserQuestion tool:
"I've analyzed the plan and selected **[SPECIALIST]** based on these keywords: [KEYWORDS].

Score: [X.X]

Proceed with [SPECIALIST] for implementation?"

Options:
- Yes, proceed with [SPECIALIST] (Recommended)
- No, use a different specialist
```

If approved, proceed to **Phase 3: Implementation Delegation** (single-specialist path).

---

### Step 3B: Multi-Specialist Mode (NEW)

**Specialists detected**: [LIST with scores]

#### Dependency Detection

**Use dependency detection from**: `prompts/specialist-selection/dependency-detection.md`

Scan the plan for dependency indicators:

**Sequential Indicators** (execute one after another):
- "frontend needs backend API"
- "UI calls authentication endpoint"
- "mobile consumes GraphQL API"
- "component fetches data from API"
- "[SPECIALIST_A] requires [SPECIALIST_B]"

**Parallel Indicators** (execute simultaneously):
- "separate admin dashboard"
- "independent API changes"
- "standalone service"
- "no shared interfaces"

#### Execution Strategy Decision

**IF sequential indicators found**:
```
Strategy: Sequential
Reason: [Specific dependency found in plan]
Order: [SPECIALIST_A] → [SPECIALIST_B] → [SPECIALIST_C]
```

**IF parallel indicators OR no clear dependencies**:
```
Strategy: Sequential (safe default)
Reason: No explicit dependencies mentioned, but sequential execution ensures proper integration
Warning: Can switch to parallel if user confirms independence
```

#### User Confirmation

**Use user approval from**: `prompts/specialist-selection/user-approval.md`

Present multi-specialist plan:
```
Use AskUserQuestion tool:

"**Multi-Specialist Work Detected**

Specialists Needed:
- ✅ [SPECIALIST_1] (Score: [X.X]) - [Responsibilities based on keywords]
- ✅ [SPECIALIST_2] (Score: [Y.Y]) - [Responsibilities based on keywords]
[... additional specialists ...]

Execution Strategy: [Sequential/Parallel]
- Reason: [DEPENDENCY_REASON or INDEPENDENCE_REASON]
[IF Sequential]:
- Order: [SPECIALIST_1] → [SPECIALIST_2] → ...

Proceed with this multi-specialist plan?"

Options:
- Yes, proceed with multi-specialist workflow (Recommended)
- Run in parallel instead [IF currently sequential]
- Run sequentially instead [IF currently parallel]
- Modify specialist selection
```

If approved, proceed to **Phase 3: Handoff Coordination** (multi-specialist path).

---

## Phase 3: Implementation Execution (30-180 min)

This phase has **two paths** depending on Phase 2 decision:
- **Path A**: Single-Specialist Delegation (traditional)
- **Path B**: Multi-Specialist Handoff Coordination (new)

---

### Path A: Single-Specialist Delegation

**When**: Only one specialist selected in Phase 2

#### Prepare Specialist Context

Create a comprehensive task description for the specialist:

```markdown
**Task**: Implement the plan from $ARGUMENTS

**Plan Objective**: [Extracted from Phase 1]

**Requirements**:
[Bullet list from plan]

**Files to Create/Modify**:
[List from plan]

**Implementation Steps**:
[Ordered steps from plan]

**Success Criteria**:
[Criteria from plan]

**Important Notes**:
- Follow the plan exactly - do not add extra features
- Implement all requirements before proceeding to next step
- Run tests after each significant change
- Create meaningful git commits as you progress
- Ask for clarification if any requirement is unclear
```

#### Spawn Implementation Specialist

Use the Task tool to spawn the selected specialist:

```bash
Task tool with:
- subagent_type: [selected-specialist]
- description: "Implement plan: [plan-filename]"
- prompt: [comprehensive context from above]
```

#### Monitor Progress

The specialist will work autonomously. You can:
- Check TodoWrite updates for progress tracking
- The specialist may use AskUserQuestion for clarifications
- Respond to any interactive confirmations for destructive operations

**After specialist completes**: Proceed to **Phase 3.5: Commit Implementation Changes** (if `--branch` flag used)

---

### Path B: Multi-Specialist Handoff Coordination (NEW)

**When**: Multiple specialists selected in Phase 2

#### Step 1: Create Handoff Structure

Create the handoff directory structure:

```bash
FEATURE_NAME=[extract from plan filename, e.g., "user-authentication"]

mkdir -p .agency/handoff/${FEATURE_NAME}/{integration,archive}

# For each specialist
for SPECIALIST in ${SPECIALISTS[@]}; do
  mkdir -p .agency/handoff/${FEATURE_NAME}/${SPECIALIST}
done
```

**Directory Structure**:
```
.agency/handoff/${FEATURE_NAME}/
├── execution-state.json          # Orchestrator tracks overall progress
├── integration/
│   └── api-contract.md          # Shared integration specs
├── backend-architect/
│   ├── plan.md                  # This specialist's specific tasks
│   ├── summary.md               # Created by specialist after completion
│   ├── verification.md          # Created by reality-checker
│   └── files-changed.json       # Specialist tracks files modified
├── frontend-developer/
│   ├── plan.md
│   ├── summary.md
│   ├── verification.md
│   └── files-changed.json
└── [... other specialists ...]
```

#### Step 2: Generate Per-Specialist Plans

For EACH specialist, create their specific plan:

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/plan.md`

```markdown
# ${SPECIALIST} Plan: ${FEATURE_NAME}

## Multi-Specialist Context

**Feature**: ${FEATURE_NAME}
**Your Specialty**: ${SPECIALIST}
**Other Specialists**: [LIST]
**Execution Order**: [Sequential: Position X of Y] OR [Parallel with: LIST]

## Your Responsibilities

[Extract specialist-specific tasks from the main plan based on keyword matches]

Examples:
- Backend: API endpoints, database schema, authentication logic
- Frontend: UI components, forms, routing, state management
- Mobile: Native app screens, API integration, navigation

## Dependencies

**You need from other specialists**:
[IF sequential and not first]:
- ${PREVIOUS_SPECIALIST}: [What they should provide, e.g., "API contracts", "Database schema"]

**Other specialists need from you**:
[IF sequential and not last]:
- ${NEXT_SPECIALIST}: [What you must provide, e.g., "API documentation", "Type definitions"]

## Integration Points

[Shared interfaces, contracts, or data structures]

**API Contracts**: See `.agency/handoff/${FEATURE_NAME}/integration/api-contract.md`

## Files to Create/Modify

[Specialist-specific file list from main plan]

## Success Criteria

[Specialist-specific criteria]

Your work is complete when:
- All your tasks implemented
- Tests pass for your changes
- Integration points documented
- Summary.md created with handoff details

## Handoff Requirements

After completing your work, you MUST create:

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/summary.md`

Include:
1. Work Completed (files created/modified)
2. Implementation Details
3. Integration Points (for other specialists)
4. Verification Criteria (for reality-checker)
5. Testing Evidence (test results, coverage)

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/files-changed.json`

```json
{
  "created": ["file1.ts", "file2.tsx"],
  "modified": ["file3.ts"],
  "deleted": []
}
```
```

#### Step 3: Initialize Execution State

**File**: `.agency/handoff/${FEATURE_NAME}/execution-state.json`

```json
{
  "feature": "${FEATURE_NAME}",
  "plan_file": "$ARGUMENTS",
  "execution_strategy": "[sequential/parallel]",
  "specialists": [
    {
      "name": "backend-architect",
      "status": "pending",
      "verification": null,
      "dependencies_met": true,
      "started_at": null,
      "completed_at": null
    },
    {
      "name": "frontend-developer",
      "status": "pending",
      "verification": null,
      "dependencies_met": false,
      "waiting_for": ["backend-architect"],
      "started_at": null,
      "completed_at": null
    }
  ],
  "current_phase": "execution"
}
```

#### Step 4A: Sequential Execution

**For each specialist in order**:

```bash
1. Update execution-state.json: Mark specialist as "in_progress"

2. Spawn specialist:
   Task tool with:
   - subagent_type: ${SPECIALIST}
   - description: "${SPECIALIST} work for ${FEATURE_NAME}"
   - prompt: "
     Multi-specialist handoff mode enabled.

     Read your plan: .agency/handoff/${FEATURE_NAME}/${SPECIALIST}/plan.md

     Complete your responsibilities and create summary.md when done.
     "

3. Wait for specialist completion

4. Spawn reality-checker for verification:
   Task tool with:
   - subagent_type: testing-reality-checker
   - description: "Verify ${SPECIALIST} work for ${FEATURE_NAME}"
   - prompt: [Use prompts/code-review/reality-checker-spawn.md multi-specialist template]

5. Check verification result:
   IF CRITICAL issues found:
     → Enter fix loop (max 3 iterations)
     → Re-verify after fixes
   IF PASS:
     → Update execution-state.json: Mark as "completed", verification "passed"
     → Continue to next specialist
   IF FAIL after 3 iterations:
     → Ask user for guidance

6. Check dependencies for next specialist:
   Update next specialist's "dependencies_met" to true
```

#### Step 4B: Parallel Execution

**Spawn ALL specialists simultaneously**:

```bash
Single message with multiple Task tool calls:

Task 1:
- subagent_type: ${SPECIALIST_1}
- description: "${SPECIALIST_1} work for ${FEATURE_NAME}"
- prompt: "Read your plan: .agency/handoff/${FEATURE_NAME}/${SPECIALIST_1}/plan.md..."

Task 2:
- subagent_type: ${SPECIALIST_2}
- description: "${SPECIALIST_2} work for ${FEATURE_NAME}"
- prompt: "Read your plan: .agency/handoff/${FEATURE_NAME}/${SPECIALIST_2}/plan.md..."

[... all specialists in parallel ...]
```

**After ALL specialists complete**:

```bash
For each specialist:
  Spawn reality-checker for verification (can be parallel)
  If CRITICAL issues → Fix loop
  Update execution-state.json
```

#### Step 5: Handle Verification Failures

**Fix Loop** (max 3 iterations per specialist):

```bash
Iteration 1-3:
  1. Reality-checker identifies CRITICAL issues
  2. Document issues in verification.md
  3. Re-spawn specialist with:
     - Original plan.md
     - verification.md showing issues to fix
  4. Specialist fixes issues
  5. Re-run reality-checker
  6. If PASS → Exit loop
     If FAIL → Continue loop

After 3 iterations:
  Ask user:
  "Specialist ${SPECIALIST} has CRITICAL issues after 3 fix attempts.

   Issues:
   [LIST CRITICAL ISSUES]

   Options:
   1. Continue with issues (not recommended)
   2. Manual intervention needed
   3. Skip this specialist (fail the feature)"
```

**After Phase 3 completes**: All specialists finished and verified, proceed to **Phase 3.5: Commit Implementation Changes** (if `--branch` flag used)

---

## Phase 3.5: Commit Implementation Changes (if --branch flag present) (1-2 min)

**ONLY execute this phase if `$BRANCH_FLAG` is true.**

After implementation is complete, commit the changes following conventional commit standards from `prompts/git/commit-formatting.md`.

### Step 1: Check for Changes

Verify there are changes to commit:

```bash
# Check if there are any changes
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️ No changes to commit, skipping Phase 3.5"
  # Skip to Phase 4
else
  echo "📝 Changes detected, proceeding with commit"
fi
```

### Step 2: Review Changes

Show what will be committed:

```bash
# Show all changes
git status

# Show detailed diff
git diff
```

### Step 3: Analyze Changes for Commit Message

Analyze the implementation to generate appropriate commit message:

```bash
# Determine commit type based on plan and changes
COMMIT_TYPE="feat"  # Default

# Check plan file for type indicators (same logic as branch naming)
if grep -qi "fix\|bug" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="fix"
elif grep -qi "refactor" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="refactor"
elif grep -qi "docs\|documentation" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="docs"
elif grep -qi "test" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="test"
elif grep -qi "chore" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="chore"
elif grep -qi "perf\|performance" "$PLAN_FILE_PATH"; then
  COMMIT_TYPE="perf"
fi

# Extract feature name from plan
FEATURE_NAME=$(basename "$PLAN_FILE" .md | sed 's/^plan-//' | sed 's/^issue-[0-9]*-//')

# Determine scope (optional) from files changed
# Look at which directories/modules were modified
CHANGED_DIRS=$(git diff --name-only | cut -d'/' -f1-2 | sort -u)
# If changes are concentrated in one area, use as scope

# Generate commit subject
COMMIT_SUBJECT="${COMMIT_TYPE}: ${FEATURE_NAME}"

# If issue number present, include reference in body
ISSUE_REF=""
if [[ "$PLAN_FILE" =~ issue-([0-9]+) ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
  ISSUE_REF="Closes #${ISSUE_NUM}"
fi
```

### Step 4: Generate Commit Body

Create detailed commit body based on implementation:

```bash
# Extract requirements from plan that were implemented
# This should summarize what was completed

COMMIT_BODY="Implement ${FEATURE_NAME} as specified in plan.

Changes:
- [List key files created/modified]
- [List main functional changes]

${ISSUE_REF}"
```

### Step 5: Stage Changes

Stage all implementation changes:

```bash
# Stage all changes
git add .

# Verify staged changes
git diff --staged --stat
```

### Step 6: Present Commit Message for Approval

Show the proposed commit message:

```
Use AskUserQuestion tool:
"Ready to commit implementation changes:

Commit message:
─────────────────────
${COMMIT_SUBJECT}

${COMMIT_BODY}
─────────────────────

Files to commit: [X] files changed, [Y] insertions(+), [Z] deletions(-)

Proceed with this commit message?"

Options:
- Yes, commit with this message (Recommended)
- Edit commit message
- Skip commit (continue without committing)
```

### Step 7: Create Commit

Create the commit using conventional format:

```bash
# Create commit with heredoc for proper formatting
git commit -m "$(cat <<EOF
${COMMIT_SUBJECT}

${COMMIT_BODY}
EOF
)"

# Verify commit created
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "✅ Commit created: ${COMMIT_HASH}"
```

### Step 8: Commit Report

```markdown
## Implementation Committed

**Commit Hash**: ${COMMIT_HASH}
**Branch**: ${IMPLEMENTATION_BRANCH}
**Type**: ${COMMIT_TYPE}
**Message**: ${COMMIT_SUBJECT}

**Files Changed**: [X] files (+[Y], -[Z] lines)

**Status**: ✅ Changes committed successfully
**Remote**: ⚠️ Not yet pushed (will push during PR creation)

**Next Steps**:
1. Continue to Phase 4: Verification & Quality Gates
2. Run build and tests to validate commit
3. Additional commits may be created after Phase 5 if fixes needed
```

---

## Phase 4: Verification & Quality Gates (5-10 min)

### Run Build

Verify the code compiles/builds successfully:

```bash
# For Next.js/React projects
npm run build

# For TypeScript projects
npm run type-check

# For general Node.js
npm run build || npm run compile
```

**Quality Gate**: Build MUST pass. If build fails:
1. Read build errors
2. Fix critical issues
3. Re-run build
4. Do NOT proceed until build passes

### Run Type Check

Verify TypeScript types are correct:

```bash
# TypeScript projects
npm run type-check || npx tsc --noEmit

# Check for type errors
```

**Quality Gate**: Type check MUST pass. Type errors are blockers.

### Run Linter

Check code style and quality:

```bash
# ESLint
npm run lint

# Or
npx eslint .
```

**Quality Gate**: Linting errors MUST be fixed. Warnings are acceptable but should be minimized.

### Run Tests

Execute the test suite:

```bash
# Run all tests
npm test

# Or specific test commands
npm run test:unit
npm run test:integration
npm run test:e2e
```

**Quality Gate**: All tests MUST pass. If tests fail:
1. Analyze test failures
2. Fix code or update tests as appropriate
3. Re-run tests
4. Do NOT proceed until all tests pass

### Check Test Coverage

Verify sufficient test coverage:

```bash
# Generate coverage report
npm run test:coverage || npm test -- --coverage
```

**Quality Gate Target**: 80%+ coverage

If coverage is below 80%:
1. Note coverage gaps in report
2. Recommend adding tests (but don't block)
3. User can decide if coverage is acceptable

---

## Phase 5: Code Review (5-10 min)

This phase differs based on single vs multi-specialist:
- **Single-Specialist**: One reality-checker review
- **Multi-Specialist**: Integrated code review (per-specialist reviews already done in Phase 3)

---

### Path A: Single-Specialist Code Review

**When**: Single specialist was used in Phase 3

**Use**: `prompts/code-review/reality-checker-spawn.md` (single-specialist template)

Use the Task tool to spawn the code review agent:

```bash
Task tool with:
- subagent_type: testing-reality-checker
- description: "Review implementation of [plan-filename]"
- prompt: "Review the implementation for:

  **Plan Compliance**:
  - All requirements from the plan implemented
  - No extra features added beyond plan scope
  - Success criteria met

  **Code Quality**:
  - No obvious bugs or logic errors
  - Follows project coding standards
  - Proper error handling
  - No hardcoded values that should be configurable

  **Security**:
  - No SQL injection vulnerabilities
  - No XSS vulnerabilities
  - No exposed secrets or credentials
  - Proper input validation

  **Performance**:
  - No obvious performance issues
  - Efficient algorithms and data structures
  - No unnecessary re-renders (React)
  - Proper database indexing (if applicable)

  **Testing**:
  - Tests adequately cover the implementation
  - Edge cases tested
  - Error paths tested

  Files to review: [list of modified files]

  Provide findings with severity levels:
  - CRITICAL: Must fix before merge
  - HIGH: Should fix before merge
  - MEDIUM: Consider fixing
  - LOW: Nice to have

  Focus on CRITICAL and HIGH severity issues only."
```

#### Address Critical Issues

If the reality checker finds CRITICAL or HIGH severity issues:

1. Read the review findings
2. Fix each critical issue
3. Re-run verification (Phase 4) if code changes are significant
4. Document fixes in TodoWrite

**Do NOT skip critical fixes**. These are blockers to completion.

Medium and Low severity issues:
- Document them in the implementation summary
- User can decide whether to address them

---

### Path B: Multi-Specialist Integrated Code Review (NEW)

**When**: Multiple specialists were used in Phase 3

**Note**: Per-specialist verification already completed in Phase 3. This review focuses on integration.

**Use**: `prompts/code-review/reality-checker-spawn.md` (integrated review template)

Use the Task tool to spawn integrated code review:

```bash
Task tool with:
- subagent_type: code-reviewer
- description: "Multi-specialist integration review for ${FEATURE_NAME}"
- prompt: "**Multi-Specialist Integration Review**

  Feature: ${FEATURE_NAME}
  Handoff Directory: .agency/handoff/${FEATURE_NAME}/

  **Context**:
  - All specialists have been individually verified
  - Read ALL specialist summaries from handoff directory
  - Review ALL files changed across all specialists
  - Check integration points between specialists

  **Per-Specialist Summaries**:
  [List paths to each specialist's summary.md]

  **All Files Changed**:
  [Aggregate list from all specialists' files-changed.json]

  **Focus Areas**:

  1. **Cross-Specialist Integration**
     - Frontend ↔ Backend: API contracts match
     - Mobile ↔ Backend: Data formats consistent
     - AI ↔ Backend: Model integration correct
     - Data types aligned across boundaries
     - Error handling consistent across layers

  2. **Consistency Across Specialists**
     - Naming conventions consistent
     - Code style uniform
     - Patterns aligned
     - No conflicting approaches

  3. **Overall Architecture**
     - Components work together cohesively
     - No architectural conflicts
     - Scalability maintained
     - Design principles followed

  4. **Security Across Boundaries**
     - Authentication flows complete end-to-end
     - Authorization checks at all layers
     - Data validation at system boundaries
     - No security gaps between specialists' work

  5. **Integration Points Validation**
     - API contracts match frontend expectations
     - Type definitions consistent
     - Shared interfaces aligned
     - No integration gaps

  **Organize Findings**:
  - By specialist (backend issues, frontend issues)
  - By integration point (API contract mismatches)
  - Overall architectural concerns

  **Output Format**: Standard code review with severity levels

  **Integration-Specific Checks**:
  - Do frontend API calls match backend endpoints?
  - Are data types consistent between layers?
  - Is error handling aligned across the stack?
  - Are integration points documented?

  Provide findings with severity levels:
  - CRITICAL: Must fix before merge (breaks integration)
  - HIGH: Should fix before merge (integration issues)
  - MEDIUM: Consider fixing (consistency issues)
  - LOW: Nice to have (minor improvements)

  **Focus on integration issues** - individual specialist work already reviewed."
```

#### Review Integration Findings

**File**: `.agency/handoff/${FEATURE_NAME}/integration-review.md`

Save the integrated review findings for reference.

#### Address Integration Issues

If integrated review finds CRITICAL or HIGH issues:

1. Identify which specialist(s) need to fix
2. For each affected specialist:
   - Update their plan.md with fix requirements
   - Re-spawn specialist to fix integration issues
   - Re-verify individual specialist work
3. Re-run integrated code review
4. Max 2 iterations for integration fixes

**Integration Issue Examples**:
- API endpoint returns different data structure than frontend expects
- Authentication token format mismatch between backend and frontend
- Database schema doesn't match TypeScript types
- Error codes inconsistent between layers

---

## Phase 5.5: Commit Code Review Fixes (if --branch flag present) (1-2 min)

**ONLY execute this phase if `$BRANCH_FLAG` is true AND fixes were made after code review.**

After addressing code review issues, commit the fixes following conventional commit standards from `prompts/git/commit-formatting.md`.

### Step 1: Check for Changes Since Last Commit

Verify there are new changes to commit:

```bash
# Check if there are any uncommitted changes
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️ No new changes since last commit, skipping Phase 5.5"
  # Skip to Phase 6
else
  echo "📝 Code review fixes detected, proceeding with commit"
fi
```

### Step 2: Review Fix Changes

Show what fixes will be committed:

```bash
# Show changes since last commit
git status

# Show detailed diff
git diff
```

### Step 3: Analyze Fixes for Commit Message

Generate commit message based on fixes applied:

```bash
# Commit type is typically 'fix' for code review fixes
COMMIT_TYPE="fix"

# Extract feature name from plan (same as before)
FEATURE_NAME=$(basename "$PLAN_FILE" .md | sed 's/^plan-//' | sed 's/^issue-[0-9]*-//')

# Generate commit subject based on what was fixed
# Examples:
# - "fix: address code review findings"
# - "fix: resolve security vulnerabilities"
# - "fix: correct type errors and linting issues"

COMMIT_SUBJECT="${COMMIT_TYPE}: address code review findings for ${FEATURE_NAME}"
```

### Step 4: Generate Commit Body from Review Findings

Create detailed commit body based on fixes:

```bash
# List what was fixed from code review
# Examples:
# - Fixed CRITICAL: SQL injection vulnerability in user query
# - Fixed HIGH: Missing input validation on login form
# - Fixed HIGH: Incorrect error handling in API endpoint

COMMIT_BODY="Address code review findings:

Fixes applied:
- [List critical issues fixed]
- [List high priority issues fixed]

Security:
- [List security fixes if any]

Code quality:
- [List quality improvements if any]"
```

### Step 5: Stage Fix Changes

Stage all fix changes:

```bash
# Stage all changes
git add .

# Verify staged changes
git diff --staged --stat
```

### Step 6: Present Commit Message for Approval

Show the proposed commit message:

```
Use AskUserQuestion tool:
"Ready to commit code review fixes:

Commit message:
─────────────────────
${COMMIT_SUBJECT}

${COMMIT_BODY}
─────────────────────

Files to commit: [X] files changed, [Y] insertions(+), [Z] deletions(-)

Proceed with this commit message?"

Options:
- Yes, commit with this message (Recommended)
- Edit commit message
- Skip commit (continue without committing)
```

### Step 7: Create Commit

Create the commit using conventional format:

```bash
# Create commit with heredoc for proper formatting
git commit -m "$(cat <<EOF
${COMMIT_SUBJECT}

${COMMIT_BODY}
EOF
)"

# Verify commit created
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "✅ Commit created: ${COMMIT_HASH}"
```

### Step 8: Commit Report

```markdown
## Code Review Fixes Committed

**Commit Hash**: ${COMMIT_HASH}
**Branch**: ${IMPLEMENTATION_BRANCH}
**Type**: fix
**Message**: ${COMMIT_SUBJECT}

**Files Changed**: [X] files (+[Y], -[Z] lines)

**Status**: ✅ Code review fixes committed successfully
**Remote**: ⚠️ Not yet pushed (will push during PR creation)

**Commits Summary**:
1. Implementation commit (Phase 3.5)
2. Code review fixes commit (Phase 5.5) ← Current

**Next Steps**:
1. Continue to Phase 6: Completion & Reporting
2. Branch ready for PR creation with clean commit history
```

---

## Phase 6: Completion & Reporting (2-3 min)

### Save Implementation Summary

**Use**: `prompts/reporting/summary-template.md` for consistent formatting

Create a summary document in `.agency/implementations/`:

```bash
# Generate filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FEATURE_NAME=[extracted from plan filename]
SUMMARY_FILE=".agency/implementations/impl-${FEATURE_NAME}-${TIMESTAMP}.md"
```

#### Single-Specialist Summary

For single-specialist implementations, use the standard template from `prompts/reporting/summary-template.md`.

Key sections:
- Objective
- Requirements Implemented
- Files Changed (created/modified/deleted)
- Verification Results (build, type-check, lint, tests, coverage)
- Code Review Findings
- Success Criteria Status
- Next Steps
- Notes

#### Multi-Specialist Summary (NEW)

For multi-specialist implementations, extend the template with specialist breakdown:

```markdown
# Implementation Summary: [Feature Name]

**Date**: [Current date]
**Plan**: $ARGUMENTS
**Mode**: Multi-Specialist
**Execution Strategy**: [Sequential/Parallel]
**Duration**: [Approximate time taken]

## Specialists Involved

### Backend Architect

**Responsibilities**:
- API endpoints
- Database schema
- Authentication logic

**Files Changed**: [X] created, [Y] modified
**Verification**: ✅ PASSED / ❌ FAILED
**Summary**: [Link to .agency/handoff/${FEATURE_NAME}/backend-architect/summary.md]

### Frontend Developer

**Responsibilities**:
- Login/register forms
- Protected routes
- User profile UI

**Files Changed**: [X] created, [Y] modified
**Verification**: ✅ PASSED / ❌ FAILED
**Summary**: [Link to .agency/handoff/${FEATURE_NAME}/frontend-developer/summary.md]

[... additional specialists ...]

### Integration Review

**Status**: ✅ PASS / ⚠️ ISSUES FOUND / ❌ FAIL
**Review File**: [Link to .agency/handoff/${FEATURE_NAME}/integration-review.md]
**Integration Issues**: [X] critical, [Y] high, [Z] medium/low

## Objective

[Plan objective]

## Requirements Implemented

[Standard checklist from template]

## Files Changed (Aggregated)

### Created ([X] total)
- [List all files created by ALL specialists]

### Modified ([Y] total)
- [List all files modified by ALL specialists]

### Deleted ([Z] total)
- [List all files deleted by ALL specialists]

**Total Changes**: +[X] lines, -[Y] lines across [Z] files

## Verification Results

[Standard verification section - applies to entire implementation]

## Code Review Findings

### Per-Specialist Review Results

- Backend Architect: [X] critical, [Y] high, [Z] medium/low
- Frontend Developer: [X] critical, [Y] high, [Z] medium/low

### Integration Review Results

- Integration Issues: [X] critical, [Y] high, [Z] medium/low
- Focus: Cross-specialist integration, consistency, architecture

**Overall Review Status**: ✅ APPROVED / ⚠️ APPROVED WITH NOTES / ❌ CHANGES REQUIRED

## Success Criteria Status

[Standard success criteria section]

## Integration Quality

**API Contracts**: ✅ Match / ❌ Mismatch
**Type Consistency**: ✅ Consistent / ❌ Inconsistencies found
**Error Handling**: ✅ Aligned / ❌ Gaps
**Documentation**: ✅ Complete / ⚠️ Partial

## Next Steps

[Standard next steps, tailored to multi-specialist context]

## Handoff Directory

All specialist work, summaries, and verification reports saved to:
`.agency/handoff/${FEATURE_NAME}/`

## Notes

[Standard notes section]
```

### Report Results to User

Provide a concise summary:

#### Single-Specialist Report

```
## Implementation Complete: [Feature Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Specialist**: [Selected specialist]

**Verification**:
- Build: [✅/❌]
- Type Check: [✅/❌]
- Linter: [✅/⚠️/❌]
- Tests: [X/Y passed] ([Z]%)
- Coverage: [X]%

**Code Review**:
- Critical: [X]
- High: [X]
- Medium/Low: [X]

**Files Changed**: [X] created, [Y] modified, [Z] deleted

**Summary Report**: $SUMMARY_FILE

**Next Steps**:
[Recommended actions based on results]
```

#### Multi-Specialist Report (NEW)

```
## Multi-Specialist Implementation Complete: [Feature Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Specialists**: [LIST]
**Execution**: [Sequential/Parallel]

**Specialists Summary**:
- Backend Architect: ✅ Verified ([X] files)
- Frontend Developer: ✅ Verified ([Y] files)
[... additional specialists ...]

**Integration Review**: ✅ PASS / ⚠️ ISSUES / ❌ FAIL

**Verification**:
- Build: [✅/❌]
- Type Check: [✅/❌]
- Linter: [✅/⚠️/❌]
- Tests: [X/Y passed] ([Z]%)
- Coverage: [X]%

**Code Review (Aggregated)**:
- Per-Specialist: [X] critical, [Y] high
- Integration: [X] critical, [Y] high
- Total Issues: [X] critical, [Y] high, [Z] medium/low

**Files Changed (Total)**: [X] created, [Y] modified, [Z] deleted

**Summary Report**: $SUMMARY_FILE
**Handoff Directory**: .agency/handoff/${FEATURE_NAME}/

**Next Steps**:
[Recommended actions based on results]
```

### Update TodoWrite

Mark all implementation tasks as completed in TodoWrite.

---

## Phase 7: Pull Request Creation (if --branch flag present) (2-3 min)

**ONLY execute this phase if `$BRANCH_FLAG` is true.**

After implementation is complete and verified, offer to create a pull request.

### Step 1: Ask User About PR Creation

Present PR creation option:

```
Use AskUserQuestion tool:
"Implementation complete! Ready to create a pull request?

Branch: ${IMPLEMENTATION_BRANCH}
Commits: [X] commits
- [commit 1 message]
- [commit 2 message]

This will:
1. Push branch to remote
2. Create pull request
3. Link to issue (if applicable)

Create pull request now?"

Options:
- Yes, create PR now (Recommended)
- No, I'll create it manually later
```

**If user selects "No"**: Skip to completion, provide manual instructions

**If user selects "Yes"**: Continue with PR creation

---

### Step 2: Push Branch to Remote

Push the branch with all commits:

```bash
# Push branch to remote with tracking
git push -u origin ${IMPLEMENTATION_BRANCH}

# Verify push succeeded
if [ $? -eq 0 ]; then
  echo "✅ Branch pushed to remote: ${IMPLEMENTATION_BRANCH}"
else
  echo "❌ Push failed"
  # Ask user how to proceed:
  # 1. Retry push
  # 2. Skip PR creation
  # 3. Manual intervention needed
fi
```

### Step 3: Generate PR Title and Description

Create PR title and description from plan and commits:

```bash
# PR Title format: "[Type] Feature name" or "Feature name"
# Extract from first commit or plan

# If issue number present, include in title
if [[ "$PLAN_FILE" =~ issue-([0-9]+) ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
  PR_TITLE="[#${ISSUE_NUM}] ${FEATURE_NAME}"
else
  PR_TITLE="${FEATURE_NAME}"
fi

# Generate PR description
PR_DESCRIPTION="## Summary

Implements ${FEATURE_NAME} as specified in plan: \`${PLAN_FILE}\`

## Changes

$(git log origin/$(git_default_branch)..HEAD --oneline)

## Implementation Details

- **Specialist(s)**: [List specialists used]
- **Files Changed**: [X] created, [Y] modified, [Z] deleted
- **Tests**: [Status from Phase 4]
- **Build**: [Status from Phase 4]
- **Code Review**: [Status from Phase 5]

## Verification

- [x] All requirements implemented
- [x] Tests pass
- [x] Build succeeds
- [x] Code review completed
- [x] No critical issues

## Related

"

# Add issue reference if present
if [[ -n "$ISSUE_NUM" ]]; then
  PR_DESCRIPTION+="Closes #${ISSUE_NUM}"
fi
```

### Step 4: Create Pull Request

Use GitHub CLI to create the PR:

```bash
# Create PR using gh CLI
gh pr create \
  --title "${PR_TITLE}" \
  --body "$(cat <<EOF
${PR_DESCRIPTION}
EOF
)" \
  --base $(git_default_branch) \
  --head ${IMPLEMENTATION_BRANCH}

# Capture PR URL
PR_URL=$(gh pr view --json url --jq .url)

if [ -n "$PR_URL" ]; then
  echo "✅ Pull request created: ${PR_URL}"
else
  echo "❌ Failed to create pull request"
  # Provide manual instructions
fi
```

### Step 5: PR Creation Report

```markdown
## Pull Request Created

**PR URL**: ${PR_URL}
**Title**: ${PR_TITLE}
**Branch**: ${IMPLEMENTATION_BRANCH} → $(git_default_branch)
**Status**: ✅ PR created successfully

**Commits Included**:
1. ${COMMIT_1_MESSAGE}
2. ${COMMIT_2_MESSAGE}
[... additional commits ...]

**PR Description**:
- Summary of changes
- Implementation details
- Verification checklist
- Issue reference (if applicable)

**Next Steps**:
1. Review PR on GitHub: ${PR_URL}
2. Request reviews from team members
3. Address any CI/CD feedback
4. Merge when approved
```

### Step 6: Fallback - Manual PR Instructions

If PR creation fails or user declines, provide manual instructions:

```markdown
## Create Pull Request Manually

Your implementation is complete and ready for PR creation!

**Branch**: ${IMPLEMENTATION_BRANCH}
**Commits**: [X] commits
**Status**: ✅ Pushed to remote

### Manual PR Creation Steps:

1. **Via GitHub CLI**:
   ```bash
   gh pr create --title "${PR_TITLE}" --body "..."
   ```

2. **Via GitHub Web**:
   - Visit: https://github.com/[owner]/[repo]/compare/${IMPLEMENTATION_BRANCH}
   - Click "Create pull request"
   - Fill in title and description
   - Submit PR

3. **Suggested PR Title**:
   ```
   ${PR_TITLE}
   ```

4. **Suggested PR Description**:
   ```
   ${PR_DESCRIPTION}
   ```

**Next Steps**:
- Create PR manually using above instructions
- Link to issue #${ISSUE_NUM} (if applicable)
- Request reviews
```

---

## Interactive Mode Guidelines

Throughout the implementation:

**ASK the user** when:
- Plan is incomplete or ambiguous
- Specialist selection is uncertain
- Destructive operations are about to be performed
- Critical issues are found that need direction
- Build/tests fail and root cause is unclear

**DO NOT ask** for:
- Confirmation of every file change
- Approval of every commit
- Permission to run standard verification steps
- Approval of obvious bug fixes

**Autonomous decisions** you can make:
- Running builds, tests, linters
- Creating standard file structures
- Following established patterns in codebase
- Fixing obvious typos or syntax errors
- Standard git operations (add, commit)

---

## Error Handling

### If Plan File Not Found

```
Error: Plan file not found at: [attempted paths]

Please provide:
1. Full path to plan file, OR
2. Plan filename (will look in .agency/plans/), OR
3. Create plan file first using /agency:plan
```

### If Build Fails

```
Error: Build failed with [X] errors

Top errors:
[List top 3-5 errors]

Attempting to fix critical issues...
[Try automatic fixes]

If unfixable, ask user for guidance.
```

### If Tests Fail

```
Error: [X] tests failed

Failed tests:
[List failed test names and errors]

Possible causes:
[Analyze and suggest]

Recommendation: [Fix suggestions]
```

### If Specialist Gets Stuck

```
Warning: Specialist encountered blocker: [BLOCKER]

Attempted workarounds:
[List attempts]

User guidance needed:
[Specific question]
```

### If Branch Creation Fails (when --branch flag used)

```
Error: Failed to create branch: [BRANCH_NAME]

Possible causes:
- Branch already exists
- Not on default branch and couldn't switch
- Uncommitted changes blocking checkout
- Permission issues

Attempted:
[List attempted solutions]

Options:
1. Skip branch creation and continue with current branch
2. Manually create branch and re-run command
3. Abort implementation
```

### If Push to Remote Fails (when --branch flag used)

```
Error: Failed to push branch to remote: [BRANCH_NAME]

Possible causes:
- No remote configured
- Network connectivity issues
- Permission/authentication issues
- Branch protection rules
- Remote branch already exists with conflicts

Attempted:
[List attempted solutions]

Options:
1. Retry push after resolving issue
2. Skip PR creation, create manually later
3. Force push (only if safe and authorized)
```

### If PR Creation Fails (when --branch flag used)

```
Error: Failed to create pull request

Possible causes:
- GitHub CLI (gh) not installed or not authenticated
- Network connectivity issues
- Repository permissions insufficient
- Pull request already exists for this branch
- Invalid PR title or description format

Attempted:
[List attempted solutions]

Fallback:
Providing manual PR creation instructions with:
- Branch name
- Suggested PR title
- Generated PR description
- Direct GitHub URL for manual PR creation
```

---

## Success Indicators

Implementation is successful when:

- ✅ All plan requirements implemented
- ✅ Build passes
- ✅ Type check passes
- ✅ Linter passes (or warnings acceptable)
- ✅ All tests pass
- ✅ Coverage ≥ 80% (or user accepts lower)
- ✅ No critical code review issues
- ✅ Success criteria from plan met
- ✅ Implementation summary saved

**Partial Success** when:
- ⚠️ Most requirements implemented
- ⚠️ Some tests fail (non-critical features)
- ⚠️ Coverage 60-79%
- ⚠️ Only medium/low code review issues

**Failure** when:
- ❌ Build fails
- ❌ Type check fails
- ❌ Critical tests fail
- ❌ Critical code review issues
- ❌ Core requirements not implemented

---

## Best Practices

1. **Follow the Plan**: Implement exactly what's in the plan, no more, no less
2. **Quality Gates Matter**: Don't skip verification steps
3. **Communicate Proactively**: Update TodoWrite, ask when unclear
4. **Document Everything**: Save summaries, capture decisions
5. **Think About Users**: Consider edge cases, error states, accessibility
6. **Security First**: Never compromise on security issues
7. **Test Thoroughly**: Aim for 80%+ coverage, test edge cases
8. **Review Before Complete**: Always run code review before marking done

---

## Example Usage

```bash
# Implement from a plan file
/agency:implement feature-user-authentication

# With full path
/agency:implement .agency/plans/add-dark-mode-support.md

# After creating a plan
/agency:plan 123
/agency:implement plan-issue-123-20241210

# With automatic branch creation
/agency:implement feature-user-authentication --branch

# Create branch and implement from full path
/agency:implement .agency/plans/add-dark-mode-support.md --branch

# Typical workflow with branch creation and PR
/agency:plan 123
/agency:implement plan-issue-123-20241210 --branch
# This will:
# 1. Validate the plan
# 2. Create a branch (e.g., feat/issue-123-description)
# 3. Implement on that branch
# 4. Commit implementation changes
# 5. Run quality gates (build, tests, linting)
# 6. Code review
# 7. Commit any fixes from code review
# 8. Generate implementation report
# 9. Push branch and create PR (if approved)
```

---

## Tips

- **Start with a good plan**: Quality of implementation depends on plan clarity
- **Choose the right specialist**: Match specialist expertise to the technology stack
- **Don't skip quality gates**: Build, tests, linting catch issues early
- **Review before commit**: Code review finds issues humans miss
- **Document for posterity**: Future you will thank present you

---

## Related Commands

- `/agency:plan [issue]` - Create an implementation plan first
- `/agency:review [pr]` - Review code after implementation
- `/agency:test [component]` - Generate additional tests
- `/agency:work [issue]` - Full end-to-end workflow (plan + implement + review)
