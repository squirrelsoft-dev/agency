---
description: Guided refactoring workflows with safety checks and test preservation
argument-hint: file-path, directory, component-name, or pattern
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion
---

<!--
REFACTORED: This command uses reusable prompt components from prompts/ directory.
Components used:
- prompts/context/framework-detection.md
- prompts/context/testing-framework-detection.md
- prompts/quality-gates/quality-gate-sequence.md
- prompts/quality-gates/build-verification.md
- prompts/quality-gates/type-checking.md
- prompts/quality-gates/linting.md
- prompts/quality-gates/test-execution.md
- prompts/quality-gates/coverage-validation.md
- prompts/specialist-selection/multi-specialist-routing.md
- prompts/git/branch-creation.md
- prompts/reporting/metrics-comparison.md
- prompts/error-handling/scope-detection-failure.md

Size reduction: ~100 lines (6.6% reduction)
Maintainability: Improved - updates to components automatically benefit all commands
-->

# Refactor Code: $ARGUMENTS

Safely refactor code with automatic quality analysis, incremental execution, and test preservation.

## Your Mission

Refactor: **$ARGUMENTS**

Execute safe, measured refactoring with:
- Code quality analysis (complexity, duplication, type coverage)
- Incremental refactoring plan with rollback points
- Test preservation (coverage must not decrease)
- Before/after metrics comparison
- Comprehensive refactoring report

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

Also activate the code review standards skill:
```
Use the Skill tool to activate: code-review-standards
```

This skill contains critical code quality criteria, refactoring patterns, and safety checks.

### 2. Safety First Principles

**NEVER**:
- Reduce test coverage below baseline
- Change functionality (behavior must remain identical)
- Skip running tests after changes
- Make multiple changes without checkpoints

**ALWAYS**:
- Git checkpoint before each refactoring step
- Run tests immediately after each change
- Rollback if tests fail
- Preserve all functionality

### 3. Use TodoWrite Throughout

Track refactoring progress:
- Code analyzed ✅
- Plan created ✅
- Step 1 complete ✅
- Step 2 in progress...

---

## Phase 0: Project Context Detection (1-2 min)

<!-- Component: prompts/context/framework-detection.md -->
<!-- Component: prompts/context/testing-framework-detection.md -->

Quickly gather project context to select appropriate analysis tools.

**Execute framework detection** using the algorithm from `prompts/context/framework-detection.md`:

- Detect primary language and framework
- Identify build tools and package manager
- Select appropriate analysis tools based on detected stack

**Execute testing framework detection** using `prompts/context/testing-framework-detection.md`:

- Detect test framework (Jest, Vitest, pytest, etc.)
- Identify test commands (run, coverage)
- Detect test file patterns

**Log Detected Context**:
```
Detected Project Context:
- Language: $LANGUAGE
- Framework: $FRAMEWORK
- Testing: $TEST_FRAMEWORK
- Analysis tools: [list of tools to use]

This context will inform code analysis and refactoring tools.
```

**Note**: See the full framework detection component at `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/prompts/context/framework-detection.md` for complete detection logic and all supported frameworks.

---

## Phase 1: Scope Detection & Analysis (3-5 min)

### Step 1: Parse Scope Argument

Determine what to refactor based on `$ARGUMENTS`:

**File Path** (most specific):
```bash
# Example: src/components/Button.tsx
if [ -f "$ARGUMENTS" ]; then
  SCOPE_TYPE="file"
  SCOPE_FILES=("$ARGUMENTS")
  SCOPE_DESCRIPTION="File: $ARGUMENTS"
fi
```

**Directory** (module/feature):
```bash
# Example: src/features/auth/
if [ -d "$ARGUMENTS" ]; then
  SCOPE_TYPE="directory"
  SCOPE_FILES=($(find "$ARGUMENTS" -type f -name "*.$PRIMARY_EXT"))
  SCOPE_DESCRIPTION="Directory: $ARGUMENTS (${#SCOPE_FILES[@]} files)"
fi
```

**Component Name** (find by name):
```bash
# Example: UserProfile
if [[ ! -f "$ARGUMENTS" ]] && [[ ! -d "$ARGUMENTS" ]]; then
  # Try to find component
  SCOPE_FILES=($(find . -type f -name "$ARGUMENTS.*" -o -name "*$ARGUMENTS*.$PRIMARY_EXT"))

  if [ ${#SCOPE_FILES[@]} -gt 0 ]; then
    SCOPE_TYPE="component"
    SCOPE_DESCRIPTION="Component: $ARGUMENTS (found ${#SCOPE_FILES[@]} files)"
  fi
fi
```

**Glob Pattern** (batch refactoring):
```bash
# Example: **/*.controller.ts
if [[ "$ARGUMENTS" == *"*"* ]]; then
  SCOPE_TYPE="pattern"
  SCOPE_FILES=($(glob "$ARGUMENTS"))
  SCOPE_DESCRIPTION="Pattern: $ARGUMENTS (${#SCOPE_FILES[@]} files)"
fi
```

**Keyword** (issue-driven refactoring):
```bash
# Example: "duplicate-code", "complexity", "type-safety"
KEYWORDS=("duplicate-code" "complexity" "type-safety" "circular-deps")

if [[ " ${KEYWORDS[@]} " =~ " ${ARGUMENTS} " ]]; then
  SCOPE_TYPE="keyword"
  SCOPE_DESCRIPTION="Refactoring focus: $ARGUMENTS"

  # Will run analysis first, then identify files
fi
```

**If scope not found**:
```
Error: Could not find files matching scope: $ARGUMENTS

Searched:
- File: $ARGUMENTS (not found)
- Directory: $ARGUMENTS/ (not found)
- Component: **/$ARGUMENTS.* (0 matches)
- Pattern: $ARGUMENTS (0 matches)

Please specify:
- Valid file path (e.g., src/components/Button.tsx)
- Valid directory (e.g., src/features/auth/)
- Component name (e.g., UserProfile)
- Glob pattern (e.g., **/*.controller.ts)
- Keyword (duplicate-code, complexity, type-safety, circular-deps)
```

### Step 2: Count Lines of Code

```bash
# Count total LOC in scope
if [ ${#SCOPE_FILES[@]} -gt 0 ]; then
  TOTAL_LOC=0
  for FILE in "${SCOPE_FILES[@]}"; do
    LOC=$(wc -l < "$FILE")
    TOTAL_LOC=$((TOTAL_LOC + LOC))
  done

  echo "Scope: ${#SCOPE_FILES[@]} files, $TOTAL_LOC total LOC"
fi
```

### Step 3: Run Code Analysis Tools

Based on detected language, run appropriate analysis:

**TypeScript/JavaScript Analysis**:
```bash
echo "Running code analysis..."

# 1. Complexity analysis
if command -v npx &> /dev/null; then
  # ESLint complexity
  npx eslint --format json ${SCOPE_FILES[@]} \
    --rule 'complexity: [error, 10]' \
    > complexity-analysis.json 2>/dev/null || true

  # Extract high-complexity functions
  COMPLEX_FUNCTIONS=$(jq -r '.[] | .messages[] | select(.ruleId=="complexity") | "\(.line): \(.message)"' complexity-analysis.json)
fi

# 2. Duplication detection
if command -v npx &> /dev/null; then
  npx jscpd ${SCOPE_FILES[@]} --format json > duplication-analysis.json 2>/dev/null || true

  DUPLICATE_BLOCKS=$(jq '.duplicates | length' duplication-analysis.json)
  DUPLICATE_LINES=$(jq '.statistics.total.lines' duplication-analysis.json)
fi

# 3. Circular dependencies (TypeScript)
if [ "$LANGUAGE" = "TypeScript" ] && command -v npx &> /dev/null; then
  npx madge --circular --extensions ts,tsx . > circular-deps.txt 2>/dev/null || true

  CIRCULAR_DEPS=$(grep -c "^  " circular-deps.txt 2>/dev/null || echo "0")
fi

# 4. Type coverage (TypeScript)
if [ "$LANGUAGE" = "TypeScript" ] && [ -f "tsconfig.json" ]; then
  npx tsc --noEmit 2>&1 | tee type-errors.txt
  TYPE_ERRORS=$(grep -c "error TS" type-errors.txt 2>/dev/null || echo "0")

  # Count 'any' usage
  ANY_COUNT=0
  for FILE in "${SCOPE_FILES[@]}"; do
    COUNT=$(grep -c ": any" "$FILE" 2>/dev/null || echo "0")
    ANY_COUNT=$((ANY_COUNT + COUNT))
  done
fi
```

**Python Analysis**:
```bash
# 1. Complexity (radon)
if command -v radon &> /dev/null; then
  radon cc ${SCOPE_FILES[@]} -a -nc --json > complexity-analysis.json

  AVG_COMPLEXITY=$(jq '[.[].complexity] | add / length' complexity-analysis.json)
fi

# 2. Code quality (pylint)
if command -v pylint &> /dev/null; then
  pylint ${SCOPE_FILES[@]} --output-format=json > pylint-analysis.json 2>/dev/null || true

  ISSUES_COUNT=$(jq 'length' pylint-analysis.json)
fi

# 3. Type coverage (mypy)
if command -v mypy &> /dev/null; then
  mypy ${SCOPE_FILES[@]} --strict 2>&1 | tee mypy-output.txt
  TYPE_ERRORS=$(grep -c "error:" mypy-output.txt 2>/dev/null || echo "0")
fi
```

### Step 4: Generate Analysis Report

Create comprehensive code quality report:

```markdown
## Code Quality Analysis: $SCOPE_DESCRIPTION

**Files in Scope**: ${#SCOPE_FILES[@]} files, $TOTAL_LOC total LOC
**Language**: $LANGUAGE
**Framework**: $FRAMEWORK

---

### Complexity Metrics

**Average Cyclomatic Complexity**: $AVG_COMPLEXITY
- Target: < 5 (simple)
- Warning: 5-10 (moderate)
- Critical: > 10 (complex)

**Functions > 10 Complexity**: $HIGH_COMPLEXITY_COUNT functions
$COMPLEX_FUNCTIONS

**Highest Complexity**:
- \`processUserData()\` in user.service.ts: **27** (Critical!)
- \`validateForm()\` in form.component.ts: **15** (High)
- \`formatDate()\` in utils.ts: **12** (High)

---

### Code Duplication

**Duplicate Blocks**: $DUPLICATE_BLOCKS
**Duplicate Lines**: $DUPLICATE_LINES ($DUPLICATE_PERCENTAGE% of scope)

**Major Duplications**:
1. Date formatting logic duplicated in 5 files (23 lines each)
2. User validation duplicated in 3 files (15 lines each)
3. Error handling pattern repeated 8 times (10 lines each)

---

### Type Safety (TypeScript)

**\`any\` Usage**: $ANY_COUNT occurrences
**Type Errors**: $TYPE_ERRORS errors
**Type Coverage**: $TYPE_COVERAGE%

**Type Issues**:
- 12 functions with \`any\` return type
- 8 parameters typed as \`any\`
- 3 untyped function declarations

---

### Circular Dependencies

**Circular Dependency Cycles**: $CIRCULAR_DEPS detected

**Critical Cycles**:
1. \`auth.ts\` ↔ \`user.ts\` (high coupling)
2. \`post.service.ts\` ↔ \`comment.service.ts\` (moderate coupling)

---

### Refactoring Opportunities

#### 🔴 High Priority

1. **Extract Complex Functions** (Complexity > 10)
   - \`processUserData()\` → Split into 3 smaller functions
   - \`validateForm()\` → Extract validation logic
   - **Impact**: Improve maintainability, reduce cognitive load
   - **Effort**: 2-3 hours

2. **Remove Code Duplication** (234 duplicate lines)
   - Extract common date formatting to \`utils/date.ts\`
   - Create shared \`UserCard\` component
   - Standardize error handling pattern
   - **Impact**: Reduce LOC by 15%, improve consistency
   - **Effort**: 1-2 hours

#### 🟡 Medium Priority

3. **Improve Type Safety** (12 \`any\` types)
   - Replace \`any\` with proper types
   - Add strict null checks
   - Type all function parameters
   - **Impact**: Catch bugs at compile time
   - **Effort**: 1 hour

4. **Break Circular Dependencies** (2 cycles)
   - Extract shared types to \`types/auth-user.ts\`
   - Refactor import paths
   - **Impact**: Improve modularity, enable tree-shaking
   - **Effort**: 2 hours

#### 🟢 Low Priority

5. **Code Organization** (optional)
   - Group related utilities
   - Consistent file naming
   - **Impact**: Minor (cosmetic)
   - **Effort**: 30 minutes

---

**Recommendation**: Focus on High Priority items (complexity and duplication) for maximum impact.
```

### Step 5: Log Analysis Complete

Update TodoWrite:
```
Code analysis complete
- Scope: ${#SCOPE_FILES[@]} files analyzed
- Complexity: Avg $AVG_COMPLEXITY (4 functions > 10)
- Duplication: $DUPLICATE_LINES lines (12%)
- Type coverage: $TYPE_COVERAGE%
- Opportunities identified: 5
```

---

## Phase 2: Refactoring Plan Creation (5-7 min)

### Step 1: Spawn Planning Agent

<!-- Component: prompts/specialist-selection/multi-specialist-routing.md -->

**Select appropriate specialist** based on detected framework and refactoring scope:

```bash
# Map framework to specialist
if [[ "$FRAMEWORK" == "Next.js" ]] || [[ "$FRAMEWORK" == "React" ]]; then
  SPECIALIST="frontend-developer"
elif [[ "$FRAMEWORK" == "Django" ]] || [[ "$FRAMEWORK" == "FastAPI" ]]; then
  SPECIALIST="backend-architect"
else
  SPECIALIST="senior-developer"  # Default for general refactoring
fi
```

**Spawn planning agent** with refactoring-specific context:

```markdown
Task tool with:
  subagent_type: $SPECIALIST
  description: "Create refactoring plan for $SCOPE_DESCRIPTION"
  prompt: "
Create a safe refactoring plan for the following code:

**Scope**: $SCOPE_DESCRIPTION ($TOTAL_LOC LOC, ${#SCOPE_FILES[@]} files)
**Language**: $LANGUAGE
**Framework**: $FRAMEWORK

**Analysis Results**:
$ANALYSIS_REPORT

**Requirements**:
1. **Preserve Functionality**: No behavior changes allowed
2. **Maintain Test Coverage**: Coverage must stay ≥ $CURRENT_COVERAGE%
3. **Incremental Steps**: Break into small, safe steps (each < 30 min)
4. **Rollback Points**: Each step independently verifiable
5. **Risk Assessment**: Rate each step (low/medium/high risk)

**Plan Format**:
For each refactoring step, provide:
- Step number and description
- Before/after code examples
- Test updates required
- Risk level (low/medium/high)
- Verification method
- Estimated time

Focus on the High Priority opportunities from the analysis.
Include a rollback strategy if any step fails.
"
```

**Note**: For complex refactorings spanning multiple domains (e.g., full-stack refactoring), see `prompts/specialist-selection/multi-specialist-routing.md` for coordination between multiple specialists.

### Step 2: Review Generated Plan

Agent returns refactoring plan. Review and validate:

```markdown
# Refactoring Plan: $SCOPE_DESCRIPTION

## Objectives
1. Reduce complexity from avg $AVG_COMPLEXITY to < 5
2. Eliminate $DUPLICATE_LINES lines of duplication
3. Improve type safety from $TYPE_COVERAGE% to 90%+
4. Break $CIRCULAR_DEPS circular dependencies

## Success Criteria
- ✅ All existing tests pass
- ✅ Test coverage ≥ $CURRENT_COVERAGE%
- ✅ Build successful
- ✅ No behavior changes (verified by tests)
- ✅ Code quality metrics improved

---

## Refactoring Steps (Sequential)

### Step 1: Extract Complex Function (Risk: 🟢 Low)
**Target**: \`processUserData()\` in \`user.service.ts\` (complexity: 27)

**Current Code** (50 lines):
\`\`\`typescript
function processUserData(data: any) {
  // Validation
  if (!data.email) throw new Error("Email required")
  if (!data.email.includes("@")) throw new Error("Invalid email")

  // Transformation
  const normalized = {
    email: data.email.toLowerCase(),
    name: data.name?.trim() || "",
    age: parseInt(data.age) || 0
  }

  // Enrichment
  const enriched = {
    ...normalized,
    createdAt: new Date(),
    isVerified: false,
    metadata: { source: "api" }
  }

  return enriched
}
\`\`\`

**Refactored Code** (4 functions, 12 lines each):
\`\`\`typescript
function validateUserData(data: UserData): void {
  if (!data.email) throw new Error("Email required")
  if (!data.email.includes("@")) throw new Error("Invalid email")
  // ... other validations
}

function transformUserData(data: UserData): NormalizedUser {
  return {
    email: data.email.toLowerCase(),
    name: data.name?.trim() || "",
    age: parseInt(data.age) || 0
  }
}

function enrichUserData(user: NormalizedUser): EnrichedUser {
  return {
    ...user,
    createdAt: new Date(),
    isVerified: false,
    metadata: { source: "api" }
  }
}

function processUserData(data: UserData): EnrichedUser {
  validateUserData(data)
  const normalized = transformUserData(data)
  return enrichUserData(normalized)
}
\`\`\`

**Test Updates**:
- Add unit tests for \`validateUserData()\` (5 test cases)
- Add unit tests for \`transformUserData()\` (4 test cases)
- Add unit tests for \`enrichUserData()\` (3 test cases)
- Existing \`processUserData()\` tests still pass

**Verification**:
```bash
npm test -- user.service.test.ts
# All 12 new tests + 8 existing tests pass
```

**Complexity After**:
- \`validateUserData\`: 3
- \`transformUserData\`: 2
- \`enrichUserData\`: 1
- \`processUserData\`: 4
Average: 2.5 (was 27) ✅

**Estimated Time**: 30 minutes

---

### Step 2: Remove Code Duplication (Risk: 🟡 Medium)
**Target**: Date formatting duplicated in 5 files (23 lines each = 115 lines)

**Approach**: Create shared \`formatDate()\` utility

**Files to Update**:
1. \`src/components/UserProfile.tsx\` (lines 45-52)
2. \`src/components/PostCard.tsx\` (lines 23-30)
3. \`src/components/CommentList.tsx\` (lines 67-74)
4. \`src/services/analytics.ts\` (lines 134-141)
5. \`src/services/report.ts\` (lines 89-96)

**New File**: \`src/utils/date.ts\`
\`\`\`typescript
export function formatDate(
  date: Date | string,
  format: 'short' | 'long' | 'iso' = 'short'
): string {
  const d = typeof date === 'string' ? new Date(date) : date

  switch (format) {
    case 'short': return d.toLocaleDateString()
    case 'long': return d.toLocaleDateString('en-US', { dateStyle: 'long' })
    case 'iso': return d.toISOString()
  }
}
\`\`\`

**Example Update** (UserProfile.tsx):
\`\`\`typescript
// Before
const formatted = new Date(user.createdAt).toLocaleDateString()

// After
import { formatDate } from '@/utils/date'
const formatted = formatDate(user.createdAt, 'short')
\`\`\`

**Test Updates**:
- Create \`src/utils/date.test.ts\` with 8 test cases
- Update existing component tests if date format changed

**Verification**:
```bash
npm test
# All tests pass, no regressions
```

**LOC Reduction**: 115 lines → 15 lines (saves 100 lines) ✅

**Estimated Time**: 45 minutes

---

### Step 3: Improve Type Safety (Risk: 🟢 Low)
**Target**: Replace 12 \`any\` types with proper types

**Changes**:
\`\`\`typescript
// Before
function getUser(id: any): any {
  return db.users.findById(id)
}

function updateUser(id: any, data: any): any {
  return db.users.update(id, data)
}

// After
function getUser(id: string): User | null {
  return db.users.findById(id)
}

function updateUser(id: string, data: Partial<User>): User {
  return db.users.update(id, data)
}
\`\`\`

**Test Updates**: None (types don't affect runtime)

**Verification**:
```bash
npx tsc --noEmit
# No type errors
```

**Type Coverage After**: 78% → 91% ✅

**Estimated Time**: 20 minutes

---

### Step 4: Break Circular Dependencies (Risk: 🔴 High)
**Target**: \`auth.ts\` ↔ \`user.ts\` circular import

**Current Structure**:
\`\`\`
auth.ts imports from user.ts
user.ts imports from auth.ts
→ Circular dependency
\`\`\`

**Refactored Structure**:
\`\`\`
Create types/auth-user.ts (shared types)
  ↑              ↑
auth.ts    user.ts
  ↓              ↓
(both import types, no longer import each other)
\`\`\`

**New File**: \`src/types/auth-user.ts\`
\`\`\`typescript
export interface AuthUser {
  id: string
  email: string
  roles: string[]
}

export interface AuthToken {
  token: string
  expiresAt: Date
}
\`\`\`

**Updates**:
- \`auth.ts\`: Import \`AuthUser\`, \`AuthToken\` from \`types/auth-user.ts\`
- \`user.ts\`: Import \`AuthUser\` from \`types/auth-user.ts\`
- Remove direct imports between \`auth.ts\` and \`user.ts\`

**Test Updates**: None (structure change only)

**Verification**:
```bash
npx madge --circular --extensions ts,tsx src/
# Output: No circular dependencies found ✅
```

**Estimated Time**: 60 minutes

---

## Rollback Strategy

**Checkpoint System**:
- Git commit before each step
- Branch naming: \`refactor/$SCOPE_NAME\`
- Commits: \`refactor: step 1 - extract complex function\`

**If Step Fails**:
1. Run: \`git reset --hard HEAD~1\`
2. Investigate failure
3. Adjust approach or skip step
4. Continue with next step

**If Multiple Steps Fail**:
- Rollback to beginning: \`git reset --hard origin/main\`
- Re-evaluate plan
- Consider smaller, safer changes

---

## Estimated Total Time

- Step 1: 30 min (extract complex function)
- Step 2: 45 min (remove duplication)
- Step 3: 20 min (improve types)
- Step 4: 60 min (break circular deps)

**Total**: ~2.5 hours

---

**This plan preserves all functionality while systematically improving code quality.**
```

### Step 3: Get User Approval

Present plan and get approval:

```
Use AskUserQuestion tool:
  Question: "Review refactoring plan. Proceed with all $STEP_COUNT steps?"

  Options:
    - "Yes, execute all steps (Recommended)"
      Description: "Refactor in $STEP_COUNT incremental steps with automatic rollback on failures. Estimated time: $TOTAL_TIME hours."

    - "Execute specific steps only"
      Description: "Select which refactoring steps to execute (useful for focusing on high-priority changes)."

    - "Modify plan"
      Description: "Adjust the refactoring approach, step order, or scope."

    - "Cancel"
      Description: "Exit refactoring without changes."
```

If "Execute specific steps":
```
Use AskUserQuestion tool:
  Question: "Select refactoring steps to execute"

  Options (multiSelect: true):
    - "Step 1: Extract complex functions (30 min)"
    - "Step 2: Remove code duplication (45 min)"
    - "Step 3: Improve type safety (20 min)"
    - "Step 4: Break circular dependencies (60 min)"
```

---

## Phase 3: Incremental Refactoring Execution (Variable, 1-4 hours)

### Step 1: Create Refactoring Branch

<!-- Component: prompts/git/branch-creation.md -->

**Create refactoring branch** following standard naming conventions from `prompts/git/branch-creation.md`:

```bash
# Ensure on latest main
git checkout main
git pull origin main

# Create refactoring branch with standard naming
REFACTOR_BRANCH="refactor/$(echo $SCOPE_DESCRIPTION | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
git checkout -b $REFACTOR_BRANCH

echo "Created branch: $REFACTOR_BRANCH"
```

**Branch naming format**: `refactor/[scope-description]`
- Use lowercase
- Use hyphens, not underscores
- Keep concise but descriptive
- Examples: `refactor/api-client`, `refactor/user-service`, `refactor/cleanup-auth-logic`

**Note**: See `prompts/git/branch-creation.md` for pre-flight checks, error handling, and validation steps.

### Step 2: Capture Baseline Test Coverage

Before making any changes, capture current test coverage:

```bash
echo "Capturing baseline test coverage..."

# Run tests with coverage
if [ "$TEST_FRAMEWORK" = "jest" ] || [ "$TEST_FRAMEWORK" = "vitest" ]; then
  npm run test:coverage > baseline-coverage.txt
  BASELINE_COVERAGE=$(grep "All files" baseline-coverage.txt | awk '{print $4}' | tr -d '%')

elif [ "$TEST_FRAMEWORK" = "pytest" ]; then
  pytest --cov --cov-report=term > baseline-coverage.txt
  BASELINE_COVERAGE=$(grep "TOTAL" baseline-coverage.txt | awk '{print $NF}' | tr -d '%')

elif [ "$TEST_FRAMEWORK" = "cargo test" ]; then
  cargo tarpaulin --out Stdout > baseline-coverage.txt
  BASELINE_COVERAGE=$(grep "Coverage" baseline-coverage.txt | awk '{print $2}' | tr -d '%')
fi

echo "Baseline coverage: $BASELINE_COVERAGE%"
```

### Step 3: Execute Each Refactoring Step

For each step in the plan:

```bash
CURRENT_STEP=1

for STEP in "${REFACTORING_STEPS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Step $CURRENT_STEP: $STEP_DESCRIPTION"
  echo "Risk: $RISK_LEVEL"
  echo "Estimated time: $ESTIMATED_TIME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Update TodoWrite
  TodoWrite: "Step $CURRENT_STEP (in_progress): $STEP_DESCRIPTION"

  # 1. Create git checkpoint
  git add .
  git commit -m "refactor: checkpoint before step $CURRENT_STEP"

  # 2. Execute refactoring (spawn agent or apply directly)
  if [ "$COMPLEXITY" = "high" ]; then
    # Spawn specialist agent for complex refactoring
    Task tool with:
      subagent_type: $SPECIALIST
      description: "Execute refactoring step $CURRENT_STEP"
      prompt: "
Execute this refactoring step:

$STEP_DETAILS

Requirements:
- Make ONLY the changes specified in this step
- Update tests as specified
- Preserve all functionality
- Run tests after changes

Report:
- Files modified
- Tests added/updated
- Test results
"
  else
    # Apply simple refactoring directly via Edit tool
    # [Apply changes using Edit tool based on step details]
  fi

  # 3. Run tests immediately
  echo "Running tests..."
  $TEST_COMMAND

  if [ $? -ne 0 ]; then
    echo "❌ Tests failed after refactoring step $CURRENT_STEP"

    # Log failure
    TEST_FAILURES="$TEST_FAILURES\nStep $CURRENT_STEP: Tests failed"

    # Ask user what to do
    Use AskUserQuestion:
      Question: "Step $CURRENT_STEP caused test failures. How to proceed?"
      Options:
        - "Rollback this step"
          Description: "Undo changes from this step and continue with remaining steps."
        - "Attempt to fix"
          Description: "Try to fix the test failures before proceeding."
        - "Skip and continue"
          Description: "Mark step as failed and continue with next step (risky)."
        - "Abort refactoring"
          Description: "Stop refactoring and rollback all changes."

    if [ "$USER_CHOICE" = "Rollback this step" ]; then
      # Rollback
      git reset --hard HEAD~1
      echo "Rolled back step $CURRENT_STEP"
      ROLLED_BACK_STEPS+=("$CURRENT_STEP")

    elif [ "$USER_CHOICE" = "Attempt to fix" ]; then
      # Try to fix tests
      # [Spawn agent to fix test failures]
      # If fix successful, continue
      # If fix fails, rollback

    elif [ "$USER_CHOICE" = "Abort refactoring" ]; then
      # Abort entire refactoring
      git checkout main
      git branch -D $REFACTOR_BRANCH
      echo "Refactoring aborted, all changes rolled back"
      exit 1
    fi

  else
    echo "✅ All tests passing after step $CURRENT_STEP"

    # 4. Check coverage hasn't decreased
    $COVERAGE_COMMAND > step-coverage.txt
    CURRENT_COVERAGE=$(extract coverage from step-coverage.txt)

    if [ $(bc <<< "$CURRENT_COVERAGE < $BASELINE_COVERAGE") -eq 1 ]; then
      echo "⚠️ Coverage decreased: $BASELINE_COVERAGE% → $CURRENT_COVERAGE%"
      echo "Adding tests to restore coverage..."

      # Add tests to restore coverage
      # [Could spawn test generation agent]

    else
      echo "✅ Coverage maintained: $CURRENT_COVERAGE% (baseline: $BASELINE_COVERAGE%)"
    fi

    # 5. Run linting
    if command -v npm &> /dev/null && grep -q "lint" package.json; then
      npm run lint
      if [ $? -ne 0 ]; then
        echo "⚠️ Linting issues detected, attempting auto-fix..."
        npm run lint:fix
      fi
    fi

    # 6. Commit successful refactoring
    git add .
    git commit -m "refactor: step $CURRENT_STEP - $STEP_DESCRIPTION"

    echo "✅ Step $CURRENT_STEP complete"
    COMPLETED_STEPS+=("$CURRENT_STEP")

    # Update TodoWrite
    TodoWrite: "Step $CURRENT_STEP (completed): $STEP_DESCRIPTION"
  fi

  CURRENT_STEP=$((CURRENT_STEP + 1))
done
```

### Step 4: Track Progress

Continuously update TodoWrite:
```
Refactoring in progress
- Baseline captured: $BASELINE_COVERAGE% coverage ✅
- Step 1 (completed): Extract complex functions ✅
- Step 2 (in_progress): Remove code duplication...
- Step 3 (pending): Improve type safety
- Step 4 (pending): Break circular dependencies
```

---

## Phase 4: Safety Verification (10-15 min)

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->
<!-- Component: prompts/quality-gates/build-verification.md -->
<!-- Component: prompts/quality-gates/type-checking.md -->
<!-- Component: prompts/quality-gates/linting.md -->
<!-- Component: prompts/quality-gates/test-execution.md -->
<!-- Component: prompts/quality-gates/coverage-validation.md -->

**Execute quality gate sequence** following the standard order defined in `prompts/quality-gates/quality-gate-sequence.md`:

### Gate 1: Build Verification (BLOCKING)
Use `prompts/quality-gates/build-verification.md` for framework-specific build commands and error handling.

**Quick Summary**:
```bash
# Run build command for detected framework
$BUILD_COMMAND  # npm run build, cargo build, go build, etc.
```

### Gate 2: Type Checking (BLOCKING)
Use `prompts/quality-gates/type-checking.md` for type verification.

**Quick Summary**:
```bash
# TypeScript projects
npx tsc --noEmit || npm run type-check
```

### Gate 3: Linting (HIGH PRIORITY - Errors block, warnings allow)
Use `prompts/quality-gates/linting.md` with auto-fix attempt.

**Quick Summary**:
```bash
# Run linter with auto-fix first
npm run lint -- --fix || npm run lint
```

### Gate 4: Test Execution (BLOCKING)
Use `prompts/quality-gates/test-execution.md` for comprehensive test execution.

**Critical**: All tests MUST pass before proceeding.

```bash
# Run full test suite
$TEST_COMMAND
```

### Gate 5: Coverage Validation (RECOMMENDED - Non-blocking)
Use `prompts/quality-gates/coverage-validation.md` to check coverage baseline.

**Critical**: Coverage must NOT decrease below baseline ($BASELINE_COVERAGE%).

```bash
# Run coverage
$COVERAGE_COMMAND > final-coverage.txt
FINAL_COVERAGE=$(extract coverage from final-coverage.txt)

# Compare to baseline
if [ $FINAL_COVERAGE < $BASELINE_COVERAGE ]; then
  echo "❌ Coverage decreased: $BASELINE_COVERAGE% → $FINAL_COVERAGE%"
  echo "⚠️ Add tests to restore coverage before proceeding"
fi
```

### Verification Summary

```markdown
## Safety Verification Results

**Gate 1 - Build**: ✅/❌ [Status]
**Gate 2 - Type Check**: ✅/❌ [Status]
**Gate 3 - Linting**: ✅/⚠️ [Status]
**Gate 4 - Tests**: ✅/❌ [Status] ([X] total, [Y] passed, [Z] failed)
**Gate 5 - Coverage**: ✅/⚠️ [Status] ([X]%, baseline: [Y]%)

**Overall Status**: ✅ PASS / ❌ FAIL

[Details from each gate's reporting template]
```

**If any BLOCKING gate fails**:
```
Use AskUserQuestion:
  Question: "Safety verification failed at Gate [X]. How to proceed?"

  Options:
    - "Fix issues (Recommended)"
      Description: "Address the failed quality gate before proceeding."

    - "Rollback refactoring"
      Description: "Undo all refactoring changes and return to original code."

    - "Continue anyway (Not Recommended)"
      Description: "Proceed despite safety issues. May introduce bugs."
```

**Note**: See individual quality gate components in `prompts/quality-gates/` for detailed execution logic, error handling, and reporting templates.

---

## Phase 5: Refactoring Report & Documentation (3-5 min)

### Step 1: Calculate Before/After Metrics

<!-- Component: prompts/reporting/metrics-comparison.md -->

**Re-run code analysis** on refactored code using the same tools from Phase 1.

**Calculate improvements** using formulas from `prompts/reporting/metrics-comparison.md`:

```bash
# Complexity improvement (lower is better)
COMPLEXITY_BEFORE=$AVG_COMPLEXITY
COMPLEXITY_AFTER=$FINAL_AVG_COMPLEXITY
COMPLEXITY_IMPROVEMENT=$(bc <<< "scale=1; ($COMPLEXITY_BEFORE - $COMPLEXITY_AFTER) / $COMPLEXITY_BEFORE * 100")

# Duplication reduction (lower is better)
DUPLICATION_BEFORE=$DUPLICATE_LINES
DUPLICATION_AFTER=$FINAL_DUPLICATE_LINES
DUPLICATION_IMPROVEMENT=$(bc <<< "scale=1; ($DUPLICATION_BEFORE - $DUPLICATION_AFTER) / $DUPLICATION_BEFORE * 100")

# Type coverage increase (higher is better)
TYPE_COVERAGE_BEFORE=$TYPE_COVERAGE
TYPE_COVERAGE_AFTER=$FINAL_TYPE_COVERAGE
TYPE_COVERAGE_IMPROVEMENT=$(($TYPE_COVERAGE_AFTER - $TYPE_COVERAGE_BEFORE))

# Lines of code change
LOC_BEFORE=$TOTAL_LOC
LOC_AFTER=$FINAL_LOC
LOC_CHANGE=$(($LOC_AFTER - $LOC_BEFORE))
```

**Note**: See `prompts/reporting/metrics-comparison.md` for complete metrics table templates, formatting guidelines, and calculation formulas.

### Step 2: Generate Comprehensive Report

```bash
REPORT_FILE=".agency/refactorings/refactor-$(echo $SCOPE_DESCRIPTION | tr ' ' '-')-$(date +%Y%m%d).md"

cat > $REPORT_FILE << 'EOFMARKER'
# Refactoring Report: $SCOPE_DESCRIPTION

**Date**: $(date +%Y-%m-%d)
**Scope**: $SCOPE_DESCRIPTION ($TOTAL_LOC LOC, ${#SCOPE_FILES[@]} files)
**Duration**: $ACTUAL_DURATION
**Status**: ✅ SUCCESS

---

## Summary

Refactored ${#SCOPE_FILES[@]} files to improve code quality, reduce complexity, and eliminate duplication.

**Key Improvements**:
- Complexity reduced from avg $COMPLEXITY_BEFORE to $COMPLEXITY_AFTER (-$COMPLEXITY_IMPROVEMENT%)
- Eliminated $DUPLICATION_REDUCTION lines of duplication (-$DUPLICATION_IMPROVEMENT%)
- Improved type safety from $TYPE_COVERAGE_BEFORE% to $TYPE_COVERAGE_AFTER% (+$TYPE_COVERAGE_IMPROVEMENT%)
- Broke $CIRCULAR_DEPS circular dependencies

---

## Metrics Comparison

<!-- Using template from prompts/reporting/metrics-comparison.md -->

| Metric | Before | After | Change | Improvement |
|--------|--------|-------|--------|-------------|
| Avg Complexity | $COMPLEXITY_BEFORE | $COMPLEXITY_AFTER | -$(bc <<< "$COMPLEXITY_BEFORE - $COMPLEXITY_AFTER") | -$COMPLEXITY_IMPROVEMENT% ↓ |
| Max Complexity | $MAX_COMPLEXITY_BEFORE | $MAX_COMPLEXITY_AFTER | -$(bc <<< "$MAX_COMPLEXITY_BEFORE - $MAX_COMPLEXITY_AFTER") | ✅ Reduced |
| Duplicate Lines | $DUPLICATION_BEFORE | $DUPLICATION_AFTER | -$(bc <<< "$DUPLICATION_BEFORE - $DUPLICATION_AFTER") | -$DUPLICATION_IMPROVEMENT% ↓ |
| Type Coverage | $TYPE_COVERAGE_BEFORE% | $TYPE_COVERAGE_AFTER% | +$TYPE_COVERAGE_IMPROVEMENT% | +$TYPE_COVERAGE_IMPROVEMENT% ↑ |
| Test Coverage | $BASELINE_COVERAGE% | $FINAL_COVERAGE% | +$(($FINAL_COVERAGE - $BASELINE_COVERAGE))% | ✅ Improved |
| Total LOC | $LOC_BEFORE | $LOC_AFTER | $LOC_CHANGE | $([ $LOC_CHANGE -lt 0 ] && echo "↓ Reduced" || echo "↑") |

---

## Changes Made

### Step 1: Extract Complex Functions ✅
**Files**: user.service.ts

**Before**:
- 1 function with 50 lines, complexity 27

**After**:
- 4 functions with avg 12 lines, max complexity 4

**Tests**: Added 12 new unit tests

---

### Step 2: Remove Code Duplication ✅
**Files**: 5 files updated

**Changes**:
- Created \`utils/date.ts\` with shared \`formatDate()\`
- Removed 100 duplicate lines
- Centralized date formatting logic

**Tests**: Created \`date.test.ts\` with 8 tests

---

### Step 3: Improve Type Safety ✅
**Changes**:
- Replaced 12 \`any\` types with proper types
- Added strict null checks
- Type coverage: $TYPE_COVERAGE_BEFORE% → $TYPE_COVERAGE_AFTER%

**Verification**: TypeScript compilation clean

---

### Step 4: Break Circular Dependencies ✅
**Changes**:
- Extracted shared types to \`types/auth-user.ts\`
- Broke 2 circular dependency cycles

**Verification**: \`madge --circular\` reports 0 cycles

---

## Test Results

**Before Refactoring**:
- Total: 234 tests
- Passing: 234
- Coverage: $BASELINE_COVERAGE%

**After Refactoring**:
- Total: 254 tests (+20 new tests)
- Passing: 254
- Coverage: $FINAL_COVERAGE% (+$(($FINAL_COVERAGE - $BASELINE_COVERAGE))%)

**All tests passed ✅**

---

## Files Modified

**Updated Files** ($FILE_COUNT):
$FILE_LIST

**Test Files** ($TEST_FILE_COUNT):
$TEST_FILE_LIST

**Total Changes**: +$ADDITIONS additions, -$DELETIONS deletions

---

## Git Commits

Refactoring committed in $COMMIT_COUNT incremental commits:
$COMMIT_LIST

**Branch**: \`$REFACTOR_BRANCH\`

---

## Recommendations

**Next Steps**:
1. Review refactored code in PR
2. Deploy to staging for integration testing
3. Monitor production for any issues

**Future Refactoring Opportunities**:
$FUTURE_OPPORTUNITIES

---

**Report Location**: \`$REPORT_FILE\`
EOFMARKER
```

### Step 3: Create Pull Request

```bash
# Push refactoring branch
git push origin $REFACTOR_BRANCH

# Create PR
gh pr create \
  --title "Refactor: $SCOPE_DESCRIPTION" \
  --body "$(cat <<'EOF'
## Refactoring Summary

$SUMMARY

## Metrics Improvement

$METRICS_TABLE

## Changes Made

$CHANGES_LIST

## Safety Verification

✅ All $TEST_COUNT tests passing
✅ Coverage maintained: $FINAL_COVERAGE% (was $BASELINE_COVERAGE%)
✅ Build successful
✅ Type checking passed
✅ No functional changes (behavior preserved)

## Report

Full report: \`$REPORT_FILE\`
EOF
)"

PR_URL=$(gh pr view --json url --jq '.url')
echo "Pull request created: $PR_URL"
```

### Step 4: Update TodoWrite

```
Refactoring complete ✅
- ${#COMPLETED_STEPS[@]}/${#TOTAL_STEPS[@]} steps completed
- All tests passing ✅
- Coverage improved: $BASELINE_COVERAGE% → $FINAL_COVERAGE%
- PR created: $PR_URL
```

### Step 5: Display Summary to User

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Refactoring Complete!

**Scope**: $SCOPE_DESCRIPTION
**Duration**: $ACTUAL_DURATION
**Report**: $REPORT_FILE

### Key Improvements

✅ Complexity: $COMPLEXITY_BEFORE → $COMPLEXITY_AFTER (-$COMPLEXITY_IMPROVEMENT%)
✅ Duplication: $DUPLICATION_BEFORE → $DUPLICATION_AFTER lines (-$DUPLICATION_IMPROVEMENT%)
✅ Type Coverage: $TYPE_COVERAGE_BEFORE% → $TYPE_COVERAGE_AFTER% (+$TYPE_COVERAGE_IMPROVEMENT%)
✅ Test Coverage: $BASELINE_COVERAGE% → $FINAL_COVERAGE% (+$(($FINAL_COVERAGE - $BASELINE_COVERAGE))%)

### Safety Verification

✅ All $TEST_COUNT tests passing
✅ Build successful
✅ No behavior changes

### Next Steps

- Review PR: $PR_URL
- Merge when approved
- Deploy to staging

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Important Notes

### Safety Principles

**Never Compromise Safety**:
- If tests fail, rollback immediately
- If coverage decreases, add tests before continuing
- If build breaks, fix before proceeding
- When in doubt, rollback and re-plan

**Incremental Approach**:
- Small steps reduce risk
- Each step independently verifiable
- Easy to identify what caused issues
- Can rollback to any checkpoint

### Code Analysis Tools

**Install if Missing**:
```bash
# TypeScript/JavaScript
npm install -D eslint jscpd madge ts-prune

# Python
pip install radon pylint mypy

# Rust
cargo install cargo-tarpaulin cargo-udeps

# Go
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
go install github.com/mibk/dupl@latest
```

### Common Refactoring Patterns

**Extract Function**: Reduce complexity by breaking large functions into smaller ones

**Remove Duplication**: Create shared utilities or components

**Improve Types**: Replace \`any\` with proper types for type safety

**Break Dependencies**: Extract shared interfaces/types to break circular imports

**Rename for Clarity**: Use descriptive names that reveal intent

### When NOT to Refactor

Don't refactor if:
- Tests don't exist (write tests first)
- On a tight deadline (technical debt is acceptable short-term)
- Code works and won't be modified soon (if it ain't broke...)
- Risk outweighs benefit (complex legacy code)

---

## Error Handling

### If Scope Detection Fails

<!-- Component: prompts/error-handling/scope-detection-failure.md -->

**Use scope detection failure workflow** from `prompts/error-handling/scope-detection-failure.md`:

**Ambiguous Scope**:
- Ask user for clarification with AskUserQuestion
- Provide options: specific file, directory, component pattern
- Show files matching partial pattern

**No Files Found**:
- Verify path is correct
- Check for typos in component name
- Suggest using glob pattern for flexible matching

**Too Many Files** (>50 files):
- Confirm with user before proceeding
- Recommend narrowing scope
- Offer to analyze subset first

**Note**: See `prompts/error-handling/scope-detection-failure.md` for complete error messages, recovery strategies, and user interaction patterns.

### If Code Analysis Fails

**Analysis Tool Not Available**:
- Install tool if possible (npm install -D, pip install)
- Use alternative analysis method
- Provide manual analysis guidance

**Analysis Tool Errors**:
- Check if code compiles first
- Fix syntax errors before analysis
- Skip broken analysis, proceed with manual review

### If Plan Creation Fails

**Specialist Agent Error**:
- Review error from planning agent
- Either fix prerequisites or create plan manually
- Ask user for guidance if complexity too high

**Unclear Refactoring Needs**:
- Code quality is already good (no refactoring needed)
- Inform user, ask if still want to proceed
- Provide recommendations for other improvements

### If Refactoring Execution Fails

**Test Failures After Refactoring Step**:
- **IMMEDIATELY** rollback to last git checkpoint
- Report which step caused failures
- Ask user: "Rollback and skip" / "Attempt to fix" / "Abort refactoring"

**Implementation Error**:
- Review error from implementation agent
- Either fix directly or re-delegate with adjusted instructions
- If repeated failures on same step, mark as "attempted but blocked"

**Coverage Decreased**:
- Rollback the changes
- Analyze why coverage dropped
- Either add tests or adjust refactoring approach
- Never proceed with decreased coverage

**Build Fails**:
- Rollback immediately
- Fix build errors before continuing
- Cannot proceed if build broken

### If Verification Fails

**Final Tests Fail**:
- **Critical failure** - rollback all refactoring
- Investigate which step introduced failure
- Fix or abandon refactoring

**Coverage Below Baseline**:
- Rollback to baseline
- Add tests before refactoring
- Never ship with decreased coverage

**Type Errors Introduced**:
- Fix type errors
- Ensure all types are preserved or improved
- Rollback if types can't be preserved

**Linting Errors**:
- Fix critical linting errors
- Warnings are acceptable if minor
- Don't let refactoring introduce new issues

### If User Requests Changes

**Change Scope Mid-Refactoring**:
- Complete current refactoring step or rollback
- Commit completed work
- Start new refactoring with new scope

**Abort Refactoring**:
- Rollback to baseline (git reset --hard [baseline-commit])
- Generate partial report showing what was attempted
- Preserve analysis results for future reference

**Skip Problematic Step**:
- Mark step as skipped in execution log
- Continue with next refactoring step
- Document why step was skipped

---

## Skills to Reference

**Required**:
- `agency-workflow-patterns` - Orchestration patterns
- `code-review-standards` - Code quality criteria

**Optional** (based on language):
- `typescript-5-expert` - TypeScript refactoring
- `nextjs-16-expert` - Next.js patterns
- `python-best-practices` - Python refactoring
- `rust-best-practices` - Rust refactoring

---

## Related Commands

- `/agency:work [issue]` - May trigger refactoring as part of implementation
- `/agency:review [pr]` - Review refactored code
- `/agency:optimize [target]` - Performance optimization (may include refactoring)
- `/agency:test [component]` - Generate tests for refactored code
