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

Use Glob tool to find the file. If multiple matches, ask user which one.

### Read Component Code

Use Read tool to load the component file contents.

### Detect Component Type

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

### Find Test Framework

Detect testing framework from `package.json`:

```bash
# Read package.json
Read file_path="package.json"

# Check devDependencies for:
```

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

Create comprehensive test scenario list:

**For React Components** (28 unit tests minimum):
```
Rendering Tests (8):
1. Renders without crashing
2. Renders with default props
3. Renders with all props provided
4. Renders with minimal props
5. Renders in loading state
6. Renders in error state
7. Renders with empty data
8. Matches snapshot

Interaction Tests (8):
9. Handles click events
10. Handles form input changes
11. Handles form submission
12. Handles keyboard events
13. Handles focus events
14. Handles hover events (if applicable)
15. Handles touch events (if mobile)
16. Handles disabled state

State Management Tests (6):
17. Initial state is correct
18. State updates on user action
19. State persists correctly
20. State resets when needed
21. Multiple state updates work correctly
22. State updates trigger re-renders

Props Tests (6):
23. Required props validation
24. Optional props work
25. Props with different types
26. Props trigger correct behavior
27. Callback props are called
28. Children props render correctly
```

**For API Endpoints** (12 integration tests minimum):
```
Request Tests (4):
1. GET request returns data
2. POST request creates resource
3. PUT request updates resource
4. DELETE request removes resource

Validation Tests (4):
5. Invalid request body is rejected
6. Missing required fields return 400
7. Invalid data types return 400
8. Request size limits enforced

Authentication Tests (4):
9. Unauthenticated request returns 401
10. Unauthorized access returns 403
11. Valid token allows access
12. Expired token returns 401
```

**For Utility Functions** (10+ unit tests):
```
Happy Path (3):
1. Returns correct result for valid input
2. Handles typical use cases
3. Returns expected type

Edge Cases (4):
4. Empty input ([], "", null, undefined)
5. Zero, negative numbers (if applicable)
6. Very large inputs
7. Boundary values

Error Cases (3):
8. Invalid input type throws/returns error
9. Out of range values handled
10. Null/undefined handled gracefully
```

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

## Phase 4: Test Validation (5-10 min)

### Run Generated Tests

Execute the test suite:

```bash
# Run specific test file
npm test -- $TEST_FILE_PATH

# Or with pattern matching
npm test -- --testPathPattern=$COMPONENT_NAME

# With coverage
npm test -- --coverage --testPathPattern=$COMPONENT_NAME
```

**Expected Result**: All tests should PASS

If tests FAIL:
1. Read failure messages
2. Analyze root cause
3. Fix tests or component (if bug found)
4. Re-run until all pass

### Check Test Coverage

Generate coverage report:

```bash
# Jest/Vitest with coverage
npm test -- --coverage $TEST_FILE_PATH

# View coverage report
# Look for coverage/lcov-report/index.html
```

Extract coverage metrics:
- **Line Coverage**: % of lines executed
- **Branch Coverage**: % of branches (if/else) taken
- **Function Coverage**: % of functions called
- **Statement Coverage**: % of statements executed

**Target**: All metrics ≥ 80%

If coverage < 80%:
1. Identify uncovered lines (coverage report shows them)
2. Add tests for uncovered code paths
3. Re-run coverage
4. Repeat until target met

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

Analyze coverage gaps:

```bash
# View uncovered lines
npm test -- --coverage --testPathPattern=$COMPONENT_NAME

# Check coverage report
cat coverage/coverage-summary.json
```

**If gaps exist**:
- **Uncovered lines < 10**: Acceptable (may be unreachable code)
- **Uncovered lines 10-30**: Should add tests
- **Uncovered lines > 30**: Must add tests

**Common gaps**:
- Error handling paths
- Edge cases
- Conditional branches
- Async callbacks
- Event handlers

### Review for Anti-Patterns

Check tests for common anti-patterns:

**Anti-Pattern 1**: Testing implementation details
```typescript
// BAD - tests implementation
expect(component.state.count).toBe(1)

// GOOD - tests behavior
expect(screen.getByText('Count: 1')).toBeInTheDocument()
```

**Anti-Pattern 2**: Not testing user behavior
```typescript
// BAD - calls function directly
component.handleClick()

// GOOD - simulates user interaction
await userEvent.click(screen.getByRole('button'))
```

**Anti-Pattern 3**: Vague test names
```typescript
// BAD
it('works', () => {})

// GOOD
it('should display error message when form submission fails', () => {})
```

**Anti-Pattern 4**: Multiple unrelated assertions
```typescript
// BAD
it('component works', () => {
  expect(component).toBeTruthy()
  expect(component.props.name).toBe('John')
  expect(component.state.count).toBe(0)
})

// GOOD - separate tests
it('should render component', () => {
  expect(component).toBeTruthy()
})

it('should receive name prop', () => {
  expect(component.props.name).toBe('John')
})
```

**Anti-Pattern 5**: Shared state between tests
```typescript
// BAD
let component
beforeEach(() => { component = render(<Component />) })

it('test 1', () => { component.click() })
it('test 2', () => { /* uses modified component */ })

// GOOD - fresh state each test
it('test 1', () => {
  const component = render(<Component />)
  component.click()
})

it('test 2', () => {
  const component = render(<Component />)
  // ...
})
```

---

## Phase 6: Test Documentation & Reporting (2-3 min)

### Save Test Report

Create test documentation:

```bash
# Generate filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
COMPONENT_NAME=[extracted from $ARGUMENTS]
REPORT_FILE=".agency/tests/test-report-${COMPONENT_NAME}-${TIMESTAMP}.md"

# Create directory if needed
mkdir -p .agency/tests
```

Write report using Write tool:

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
- Line Coverage: [X]% ([target: 80%])
- Branch Coverage: [X]% ([target: 80%])
- Function Coverage: [X]% ([target: 80%])
- Statement Coverage: [X]% ([target: 80%])

**Coverage Status**: ✅ MEETS TARGET / ⚠️ BELOW TARGET

**Uncovered Lines**: [X]
[List if significant]

---

## Test Scenarios Covered

### Rendering Tests (8 scenarios)
- [x] Renders without crashing
- [x] Renders with default props
- [x] Renders with all props provided
- [x] Renders with minimal props
- [x] Renders in loading state
- [x] Renders in error state
- [x] Renders with empty data
- [x] Matches snapshot

### Interaction Tests (8 scenarios)
- [x] Handles click events
- [x] Handles form input changes
- [x] Handles form submission
- [x] Handles keyboard events
- [x] Handles focus events
- [x] Handles hover events
- [x] Handles touch events
- [x] Handles disabled state

### State Management Tests (6 scenarios)
[...]

### Props Tests (6 scenarios)
[...]

[Additional scenario groups based on component type]

---

## Test Quality Assessment

**Quality Score**: [X]/10

**Strengths**:
- ✅ [Quality aspect 1]
- ✅ [Quality aspect 2]
- ✅ [Quality aspect 3]

**Areas for Improvement**:
- ⚠️ [Improvement area 1]
- ⚠️ [Improvement area 2]

**Anti-Patterns Found**: [X]
[List if any, or "None"]

---

## Coverage Gaps

**Uncovered Code Paths**: [X]

1. **[File:Line]**: [Description]
   - **Reason**: [Why uncovered]
   - **Recommendation**: [Add test scenario or mark as unreachable]

[List significant gaps]

---

## Test Files Created

### Test File
**Path**: `[test file path]`
**Lines**: [X]
**Test Count**: [Y]

### Supporting Files (if any)
- Test utilities: `[path]`
- Fixtures: `[path]`
- Factories: `[path]`

---

## Next Steps

[If coverage ≥ 80% and all tests pass]:
✅ **Test Suite Complete**
- Coverage target met ([X]%)
- All tests passing
- Good test quality
- Ready for code review

[If coverage < 80%]:
⚠️ **Additional Tests Needed**
- Current coverage: [X]%
- Target coverage: 80%
- Gap: [Y]%
- Add tests for: [uncovered areas]

[If test failures]:
❌ **Test Failures to Address**
- [X] tests failing
- Fix: [recommendations]

---

## Recommendations

1. **Immediate**:
   [Actions to take right now]

2. **Short-term**:
   [Actions for next iteration]

3. **Long-term**:
   [Ongoing test improvements]

---

## Appendix: Test Commands

```bash
# Run all tests for this component
npm test -- [test file name]

# Run with coverage
npm test -- --coverage [test file name]

# Run in watch mode
npm test -- --watch [test file name]

# Run specific test
npm test -- --testNamePattern="test name"

# Update snapshots
npm test -- --updateSnapshot [test file name]
```
```

### Present Summary to User

Provide concise report:

```
## Test Generation Complete: [Component Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Test Suite**:
- Total Tests: [X]
- Unit: [Y] (70%)
- Integration: [Z] (20%)
- E2E: [W] (10%)

**Coverage**:
- Line: [X]% ([✅ Above / ⚠️ Below] 80%)
- Branch: [X]% ([✅ Above / ⚠️ Below] 80%)
- Function: [X]% ([✅ Above / ⚠️ Below] 80%)
- Statement: [X]% ([✅ Above / ⚠️ Below] 80%)

**Test Results**: [X/Y passed]

**Quality Score**: [X]/10

**Test File**: [path]

**Detailed Report**: $REPORT_FILE

**Next Steps**:
[Recommendations]
```

### Update TodoWrite

Mark all test generation tasks as completed.

---

## Framework-Specific Patterns

### Jest + Testing Library (React)

```typescript
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('should render with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('should call onClick when clicked', async () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)

    await userEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### Vitest (Similar to Jest)

```typescript
import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'

describe('Component', () => {
  it('should work', () => {
    // Same as Jest, but imports from 'vitest'
  })
})
```

### Supertest (API Testing)

```typescript
import request from 'supertest'
import { app } from './app'

describe('GET /api/users', () => {
  it('should return users list', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200)

    expect(response.body).toHaveLength(5)
    expect(response.body[0]).toHaveProperty('name')
  })
})
```

### Playwright (E2E)

```typescript
import { test, expect } from '@playwright/test'

test('user can login', async ({ page }) => {
  await page.goto('/login')
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'password')
  await page.click('button[type="submit"]')

  await expect(page).toHaveURL('/dashboard')
})
```

---

## Error Handling

### If Component Not Found

```
Error: Component not found: $ARGUMENTS

Searched locations:
- [path 1]
- [path 2]
- [path 3]

Please provide:
1. Full path to component file, OR
2. Component filename, OR
3. Use Glob pattern to search
```

### If Test Framework Not Detected

```
Error: No test framework found in package.json

Common frameworks:
- Jest: npm install -D jest @types/jest
- Vitest: npm install -D vitest
- Mocha: npm install -D mocha chai

Please install a test framework first.
```

### If Generated Tests Fail

```
Warning: [X] generated tests are failing

Failed tests:
[List of failures]

Possible causes:
1. Component has bugs
2. Test assumptions incorrect
3. Dependencies not mocked properly
4. Async operations not handled

Recommendation:
1. Review component code
2. Fix bugs if found
3. Adjust test expectations
4. Re-run tests
```

---

## Best Practices

1. **Test Pyramid**: 70% unit, 20% integration, 10% E2E
2. **Coverage Target**: Aim for 80%+, but don't obsess over 100%
3. **Test Behavior**: What users see, not implementation details
4. **Fast Tests**: Unit tests should run in milliseconds
5. **Independent Tests**: No shared state between tests
6. **Descriptive Names**: Test names should describe expected behavior
7. **AAA Pattern**: Arrange, Act, Assert structure
8. **Mock External**: Mock HTTP calls, databases, external dependencies

---

## Example Usage

```bash
# Generate tests for a React component
/agency:test src/components/Button.tsx

# Generate tests for an API endpoint
/agency:test src/api/users.ts

# Generate tests for a utility function
/agency:test src/lib/formatDate.ts

# Generate tests for a service
/agency:test src/services/UserService.ts

# Generate tests using glob pattern
/agency:test Button
```

---

## Tips

- **Start with existing tests**: Review patterns in codebase first
- **Use factories**: Create test data factories for complex objects
- **Mock wisely**: Mock external dependencies, not internal logic
- **Test edge cases**: Empty arrays, null, undefined, boundaries
- **Run tests often**: Use watch mode during development
- **Refactor tests**: Tests are code too, keep them clean

---

## Related Commands

- `/agency:work [issue]` - Full workflow with testing included
- `/agency:implement [plan]` - Implementation includes test validation
- `/agency:review [pr]` - Reviews test coverage and quality
