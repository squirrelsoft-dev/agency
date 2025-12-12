# Quality Gates: Sequential Execution

Execute quality gates in the correct order. **Do NOT skip any gate.**

## Gate 1: Build (CRITICAL)

**Purpose**: Verify code compiles/builds successfully

**Commands**:
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

**Never Proceed** to next gate if build fails.

---

## Gate 2: Type Check (CRITICAL)

**Purpose**: Verify TypeScript types are correct

**Commands**:
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

**Common Type Issues**:
- Missing type annotations
- Incorrect return types
- Null/undefined handling
- Generic type constraints

---

## Gate 3: Linter (HIGH PRIORITY)

**Purpose**: Check code style and quality

**Commands**:
```bash
# ESLint
npm run lint

# Or direct
npx eslint .
```

**Quality Standard**:
- Linting errors MUST be fixed
- Warnings are acceptable but should be minimized

**On Failure**:
1. Review linting errors
2. Fix errors (auto-fix when possible: `npm run lint -- --fix`)
3. Re-run linter
4. **BLOCK** on errors, proceed with warnings (note them)

---

## Gate 4: Tests (CRITICAL)

**Purpose**: Execute test suite to verify functionality

**Commands**:
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

**Test Failure Analysis**:
- Is the test correct? (test bug vs code bug)
- Is it a regression? (broke existing functionality)
- Is it expected? (planned breaking change)

---

## Gate 5: Test Coverage (RECOMMENDED)

**Purpose**: Verify sufficient test coverage

**Commands**:
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

**Coverage Metrics**:
- Line coverage
- Branch coverage
- Function coverage
- Uncovered files

---

## Execution Rules

1. **Sequential Only**: Gates MUST run in order 1→2→3→4→5
2. **No Skipping**: Can't skip gates even if previous similar task passed
3. **Block on Critical**: Gates 1, 2, 4 are BLOCKERS - do not proceed if they fail
4. **Fix and Retry**: On failure, fix and re-run from the failed gate
5. **Max Retries**: 3 attempts per gate, then escalate to user

---

## Reporting Format

```markdown
## Verification Results

### Build: ✅ PASS / ❌ FAIL
[Build output summary if failed]

### Type Check: ✅ PASS / ❌ FAIL
[Type errors if failed]

### Linter: ✅ PASS / ⚠️ WARNINGS
[Error/warning count and summary]

### Tests: ✅ PASS / ❌ FAIL
- Total: X tests
- Passed: Y tests
- Failed: Z tests
[Test failure summary if failed]

### Coverage: [X]%
- Target: 80%
- Actual: [X]%
[Coverage gaps if below target]
```
