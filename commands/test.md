---
description: Generate comprehensive tests (unit, integration, E2E) for a component
argument-hint: component file path
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion]
---

# Generate Tests: $ARGUMENTS

Generate comprehensive test suite with framework auto-detection and coverage validation.

## Your Mission

Generate tests for: **$ARGUMENTS**

Create comprehensive test suite: analyze → strategy → generate → validate → review.

---

<!-- Component: prompts/specialist-selection/skill-activation.md -->
## Critical Instructions

### 1. Activate Testing Strategy Knowledge

**IMMEDIATELY** activate the testing strategy skill:
```
Use the Skill tool to activate: testing-strategy
```

This skill contains critical testing patterns, frameworks, and best practices you MUST follow.

---

## Phase 1: Component Analysis (3-5 min)

### Locate Component File

Resolve `$ARGUMENTS` to actual file path:

```bash
# If full path provided
[Use $ARGUMENTS directly]

# If filename only
Glob pattern="**/$ARGUMENTS"

# If component name (without extension)
Glob pattern="**/$ARGUMENTS.{ts,tsx,js,jsx,vue,svelte}"
```

<!-- Component: prompts/error-handling/scope-detection-failure.md -->
Use Glob tool to find the file. If multiple matches, ask user which one.

If component cannot be found:
```
❌ Unable to locate component: $ARGUMENTS

Please provide:
1. Full path to component file, OR
2. Component filename with extension, OR
3. More specific search criteria
```

### Read Component Code

Use Read tool to load the component file contents.

<!-- Component: prompts/context/framework-detection.md -->
### Detect Component Type and Framework

Analyze the code to determine component type:

**React Component** if contains:
- `import React` or `from 'react'`
- `export default function` or `export const`
- JSX syntax (`<div>`, `<Component />`)
- React hooks (`useState`, `useEffect`, `useCallback`)

**API Endpoint** if contains:
- Express: `app.get()`, `app.post()`, `router.use()`
- Next.js API: `export default function handler(req, res)`
- Fastify: `fastify.route()`
- tRPC: `.query()`, `.mutation()`

**Utility Function** if:
- Pure function exports
- No UI rendering
- No HTTP handling
- Business logic, calculations, transformations

**Service/Repository** if contains:
- Database queries (Prisma, Drizzle, TypeORM)
- External API calls
- Data access layer
- Business service logic

**Hook** (React) if:
- Starts with `use` prefix
- Uses React hooks internally
- Returns state/functions

**Vue Component** if contains:
- `<template>`, `<script>`, `<style>`
- Vue-specific syntax

**Svelte Component** if contains:
- `<script>`, `<style>` in .svelte file
- Svelte reactive declarations (`$:`)

<!-- Component: prompts/context/testing-framework-detection.md -->
### Find Test Framework

Detect testing framework from `package.json`:

**Jest** if contains:
- `"jest"`
- `"@types/jest"`
- `"ts-jest"`

**Vitest** if contains:
- `"vitest"`
- `"@vitest/ui"`

**Mocha + Chai** if contains:
- `"mocha"` + `"chai"`

**Playwright** (E2E) if contains:
- `"@playwright/test"`

**Cypress** (E2E) if contains:
- `"cypress"`

**Testing Library** if contains:
- `"@testing-library/react"`
- `"@testing-library/vue"`
- `"@testing-library/user-event"`

**If no test framework detected**, see `prompts/context/testing-framework-detection.md` for fallback strategy and recommendations.

### Analyze Existing Tests

Check if tests already exist:

```bash
# Common test file patterns
Glob pattern="**/$COMPONENT_NAME.{test,spec}.{ts,tsx,js,jsx}"
Glob pattern="**/__tests__/$COMPONENT_NAME.*"
```

If tests exist:
- Read existing tests
- Identify coverage gaps
- Enhance rather than replace

If no tests:
- Start from scratch
- Follow test pyramid (70% unit, 20% integration, 10% E2E)

### Extract Component Interface

Analyze the component to understand:

**For React Components**:
- Props interface/type
- State variables
- Event handlers
- Side effects (useEffect)
- Context usage
- Async operations

**For API Endpoints**:
- Request method (GET, POST, PUT, DELETE)
- Request parameters (query, body, headers)
- Response shape
- Status codes
- Error conditions
- Authentication requirements

**For Utility Functions**:
- Function signature (params, return type)
- Input validation
- Edge cases
- Error conditions
- Dependencies

**For Services**:
- Public methods
- Database operations
- External dependencies
- Error handling
- Transaction boundaries

---

## Phase 2: Test Strategy (2-3 min)

### Determine Test Types Needed

Based on component type:

**React Component Tests**:
1. **Unit Tests** (70%):
   - Renders without crashing
   - Renders with different props
   - Handles user interactions (clicks, input)
   - Conditional rendering
   - State updates
   - Event handlers

2. **Integration Tests** (20%):
   - Component with child components
   - Context provider interactions
   - Form submissions with validation
   - API calls (mocked)

3. **E2E Tests** (10%):
   - Critical user flows only
   - Complete interactions
   - Multiple page navigations

**API Endpoint Tests**:
1. **Unit Tests** (70%):
   - Request validation
   - Response formatting
   - Error handling
   - Authorization logic

2. **Integration Tests** (20%):
   - With database (test DB)
   - With external APIs (mocked)
   - Complete request-response cycle

3. **E2E Tests** (10%):
   - Real database operations
   - Authentication flow
   - Critical business operations

**Utility Function Tests**:
1. **Unit Tests** (100%):
   - Happy path with valid inputs
   - Edge cases (empty, null, undefined, zero)
   - Invalid inputs
   - Boundary conditions
   - Error conditions

**Service Tests**:
1. **Unit Tests** (70%):
   - Business logic isolated
   - Dependencies mocked

2. **Integration Tests** (30%):
   - With real database (test DB)
   - With real external services (if fast)
   - Transaction handling

### Identify Test Scenarios

Create comprehensive test scenario list based on component type:

**For React Components** (28 unit tests minimum):
- **Rendering Tests** (8): Renders without crashing, with default/all/minimal props, loading/error/empty states, snapshot
- **Interaction Tests** (8): Click, form input/submission, keyboard, focus, hover, touch, disabled state
- **State Management Tests** (6): Initial state, updates on action, persistence, reset, multiple updates, re-renders
- **Props Tests** (6): Required/optional props, different types, behavior triggers, callbacks, children

**For API Endpoints** (12 integration tests minimum):
- **Request Tests** (4): GET, POST, PUT, DELETE
- **Validation Tests** (4): Invalid body, missing fields, invalid types, size limits
- **Authentication Tests** (4): Unauthenticated (401), unauthorized (403), valid token, expired token

**For Utility Functions** (10+ unit tests):
- **Happy Path** (3): Valid input, typical use cases, expected type
- **Edge Cases** (4): Empty/null/undefined, zero/negative, very large, boundaries
- **Error Cases** (3): Invalid type, out of range, null handling

**Note**: Detailed test scenario checklists are available in the `testing-strategy` skill (activated in Phase 1).

### Calculate Coverage Target

Set coverage goals:

**New Components**: 80%+ coverage
- Unit tests: Must have
- Integration tests: Should have
- E2E tests: Nice to have (critical flows only)

**Existing Components**: Improve by 20%+
- If currently 40%, target 60%
- If currently 60%, target 80%
- If currently 80%, maintain or improve

**Critical Components**: 90%+ coverage
- Authentication
- Payment processing
- Data validation
- Security-related

---

## Phase 3: Test Generation (10-30 min)

### Spawn Testing Specialist

Use Task tool to spawn test generation agent:

```bash
Task tool with:
- subagent_type: [select based on component type]
  * React: frontend-developer
  * API: backend-architect
  * Utility: senior-developer
  * Service: backend-architect

- description: "Generate tests for $ARGUMENTS"

- prompt: "Generate comprehensive test suite for component at: $ARGUMENTS

**Component Type**: [React Component / API Endpoint / Utility Function / Service]

**Test Framework**: [Jest / Vitest / Mocha + Chai]

**Test Library**: [Testing Library / Supertest / None]

**Component Code**:
```
[Full component code from Phase 1]
```

**Test Requirements**:

1. **Unit Tests** (70% of test suite):
   [List of unit test scenarios from Phase 2]

2. **Integration Tests** (20% of test suite):
   [List of integration test scenarios from Phase 2]

3. **E2E Tests** (10% of test suite):
   [List of E2E test scenarios if applicable]

**Test Structure**:
```typescript
import { describe, it, expect } from '[framework]'
// Additional imports

describe('ComponentName', () => {
  describe('Rendering', () => {
    it('should render without crashing', () => {
      // Test implementation
    })

    // More rendering tests
  })

  describe('Interactions', () => {
    it('should handle click events', () => {
      // Test implementation
    })

    // More interaction tests
  })

  // Additional test groups
})
```

**Testing Best Practices**:
- Use AAA pattern (Arrange, Act, Assert)
- Descriptive test names ('should...' format)
- One assertion per test (when possible)
- Test behavior, not implementation
- Mock external dependencies
- Avoid testing framework internals
- Fast tests (< 100ms for unit tests)
- Independent tests (no shared state)

**Coverage Target**: 80%+

**Output**:
Create test file at: [test file path]
- For component at `src/components/Button.tsx`
- Create test at `src/components/Button.test.tsx`

Follow existing test patterns in the codebase if any exist."
```

### Monitor Test Generation

The specialist will:
1. Analyze component structure
2. Generate test file with all scenarios
3. Add necessary imports and setup
4. Create test utilities if needed (factories, fixtures)
5. Write clear, maintainable tests

---

<!-- Component: prompts/quality-gates/test-execution.md -->
## Phase 4: Test Validation (5-10 min)

### Run Generated Tests

Execute the test suite using framework-specific commands (see `prompts/quality-gates/test-execution.md` for full details):

```bash
# Run specific test file
npm test -- $TEST_FILE_PATH

# Or with pattern matching
npm test -- --testPathPattern=$COMPONENT_NAME

# With coverage
npm test -- --coverage --testPathPattern=$COMPONENT_NAME
```

**Expected Result**: All tests should PASS

**If tests FAIL**: See `prompts/quality-gates/test-execution.md` for:
- Common failure patterns (assertion, timeout, mock failures)
- Root cause analysis steps
- Suggested fixes
- Retry logic

<!-- Component: prompts/quality-gates/coverage-validation.md -->
### Check Test Coverage

Generate coverage report:

```bash
# Jest/Vitest with coverage
npm test -- --coverage $TEST_FILE_PATH
```

**Coverage Metrics**:
- **Line Coverage**: % of lines executed
- **Branch Coverage**: % of branches (if/else) taken
- **Function Coverage**: % of functions called
- **Statement Coverage**: % of statements executed

**Target**: All metrics ≥ 80%

**Coverage Analysis**: See `prompts/quality-gates/coverage-validation.md` for:
- Coverage gap identification
- High-priority untested areas
- Improvement strategies
- Coverage recommendations

### Verify Test Quality

Check generated tests for quality:

**Good Tests**:
- [ ] Descriptive test names
- [ ] Clear AAA structure
- [ ] Testing behavior, not implementation
- [ ] No hardcoded values (use variables)
- [ ] Proper assertions (specific, not generic)
- [ ] Fast execution (< 100ms each)
- [ ] Independent (can run in any order)

**Bad Tests** to avoid:
- [ ] Testing implementation details
- [ ] Brittle tests (break on refactor)
- [ ] Slow tests (> 1s for unit test)
- [ ] Tests that test the framework
- [ ] Vague test names
- [ ] Multiple unrelated assertions

---

## Phase 5: Test Quality Review (3-5 min)

### Review Test Coverage

Analyze coverage gaps (see `prompts/quality-gates/coverage-validation.md` for detailed analysis):

```bash
npm test -- --coverage --testPathPattern=$COMPONENT_NAME
```

**Gap Assessment**:
- **Uncovered lines < 10**: Acceptable (may be unreachable code)
- **Uncovered lines 10-30**: Should add tests
- **Uncovered lines > 30**: Must add tests

**Common gaps**: Error handling, edge cases, conditional branches, async callbacks, event handlers

### Review for Anti-Patterns

**Check tests for common anti-patterns**:

1. **Testing implementation details** - Test behavior users see, not internal state
2. **Not testing user behavior** - Simulate user interactions, don't call functions directly
3. **Vague test names** - Use descriptive "should..." format
4. **Multiple unrelated assertions** - One logical assertion per test
5. **Shared state between tests** - Create fresh state in each test

**Detailed examples and fixes**: See the `testing-strategy` skill for comprehensive anti-pattern examples with good/bad code comparisons.

---

<!-- Component: prompts/reporting/summary-template.md -->
## Phase 6: Test Documentation & Reporting (2-3 min)

### Save Test Report

Create test documentation in `.agency/tests/`:

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
COMPONENT_NAME=[extracted from $ARGUMENTS]
REPORT_FILE=".agency/tests/test-report-${COMPONENT_NAME}-${TIMESTAMP}.md"
mkdir -p .agency/tests
```

**Report Structure** (adapted from `prompts/reporting/summary-template.md`):

```markdown
# Test Report: [Component Name]

**Date**: [Current date]
**Component**: $ARGUMENTS
**Test File**: [Generated test file path]
**Framework**: [Jest/Vitest/Mocha]

---

## Test Suite Summary

**Total Tests**: [X]
- Unit Tests: [Y] (70%)
- Integration Tests: [Z] (20%)
- E2E Tests: [W] (10%)

**Test Results**: ✅ ALL PASS / ❌ FAILURES
- Passed: [X]
- Failed: [Y]
- Skipped: [Z]

**Execution Time**: [X]ms

---

## Coverage Report

**Overall Coverage**: [X]%

**Detailed Metrics**:
- Line Coverage: [X]% (target: 80%)
- Branch Coverage: [X]% (target: 80%)
- Function Coverage: [X]% (target: 80%)
- Statement Coverage: [X]% (target: 80%)

**Coverage Status**: ✅ MEETS TARGET / ⚠️ BELOW TARGET

**Coverage Gaps**: See `prompts/quality-gates/coverage-validation.md` for gap analysis

---

## Test Scenarios Covered

[List test scenarios by category: Rendering, Interaction, State Management, Props, etc.]

---

## Test Quality Assessment

**Quality Score**: [X]/10

**Strengths**: [List strengths]
**Areas for Improvement**: [List improvements]
**Anti-Patterns Found**: [List or "None"]

---

## Test Files Created

**Test File**: `[test file path]` ([X] lines, [Y] tests)
**Supporting Files**: [List utilities, fixtures, factories if any]

---

## Next Steps

[Based on coverage and test results - see `prompts/reporting/summary-template.md` for recommendations format]

---

## Test Commands

```bash
# Run tests
npm test -- [test file name]

# Run with coverage
npm test -- --coverage [test file name]

# Watch mode
npm test -- --watch [test file name]
```
```

### Present Summary to User

```
## Test Generation Complete: [Component Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Test Suite**: [X] total ([Y] unit, [Z] integration, [W] E2E)
**Coverage**: Line [X]%, Branch [Y]%, Function [Z]%, Statement [W]%
**Test Results**: [X/Y passed]
**Quality Score**: [X]/10

**Test File**: [path]
**Detailed Report**: $REPORT_FILE

**Next Steps**: [Recommendations]
```

<!-- Component: prompts/progress/todo-initialization.md -->
### Update TodoWrite

Mark all test generation tasks as completed.

---

<!-- Component: prompts/context/testing-framework-detection.md -->
## Framework-Specific Patterns

**Reference**: See `prompts/context/testing-framework-detection.md` for complete framework-specific patterns and examples.

**Key Patterns**:

- **Jest + Testing Library (React)**: `render`, `screen`, `userEvent`, `waitFor`
- **Vitest**: Similar to Jest, imports from `vitest`
- **Supertest (API Testing)**: `request(app).get().expect()`
- **Playwright (E2E)**: `page.goto()`, `page.fill()`, `expect(page).toHaveURL()`
- **Cypress (E2E)**: `cy.visit()`, `cy.get()`, `cy.contains()`
- **pytest (Python)**: fixtures, parametrize, markers

See the testing framework detection component for detailed syntax and best practices per framework.

---

<!-- Component: prompts/error-handling/scope-detection-failure.md -->
## Error Handling

### If Component Not Found

Use error handling pattern from `prompts/error-handling/scope-detection-failure.md`:

```
❌ Unable to locate component: $ARGUMENTS

Searched locations:
- [path 1]
- [path 2]
- [path 3]

Please provide:
1. Full path to component file, OR
2. Component filename with extension, OR
3. More specific search criteria
```

### If Test Framework Not Detected

```
❌ No test framework found in package.json

See `prompts/context/testing-framework-detection.md` for recommendations.

Common frameworks:
- Jest: npm install -D jest @types/jest
- Vitest: npm install -D vitest
- Mocha: npm install -D mocha chai

Please install a test framework first, or specify which framework to use.
```

### If Generated Tests Fail

See `prompts/quality-gates/test-execution.md` for comprehensive failure analysis:

```
⚠️ [X] generated tests are failing

**Failure Analysis**: See `prompts/quality-gates/test-execution.md` for:
- Common failure patterns (assertion, timeout, mock, reference errors)
- Root cause analysis steps
- Suggested fixes per failure type
- Retry logic and recovery strategies

**Immediate Actions**:
1. Review test failure output
2. Identify failure category
3. Apply recommended fixes
4. Re-run tests
```

---

## Best Practices

**Core Principles** (from `testing-strategy` skill):
1. **Test Pyramid**: 70% unit, 20% integration, 10% E2E
2. **Coverage Target**: 80%+ (see `prompts/quality-gates/coverage-validation.md`)
3. **Test Behavior**: What users see, not implementation details
4. **Fast Tests**: Unit tests in milliseconds
5. **Independent Tests**: No shared state between tests
6. **Descriptive Names**: "should..." format describing expected behavior
7. **AAA Pattern**: Arrange, Act, Assert structure
8. **Mock External**: Mock HTTP, databases, external dependencies

**Detailed best practices**: Available in `testing-strategy` skill (activated in Phase 1).

---

## Example Usage

```bash
# Generate tests for a React component
/agency:test src/components/Button.tsx

# Generate tests for an API endpoint
/agency:test src/api/users.ts

# Generate tests for a utility function
/agency:test src/lib/formatDate.ts

# Using component name only (will search)
/agency:test Button
```

---

## Related Commands

- `/agency:work [issue]` - Full workflow with testing included
- `/agency:implement [plan]` - Implementation includes test validation
- `/agency:review [pr]` - Reviews test coverage and quality
