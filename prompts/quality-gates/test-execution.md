# Quality Gate: Test Execution

**Gate Priority**: CRITICAL (Gate 4)
**Blocking**: YES - Must pass before proceeding
**Max Retry Attempts**: 3

## Purpose

Execute the test suite to verify code functionality, catch regressions, and ensure new changes don't break existing features.

## Framework-Specific Commands

### JavaScript/TypeScript

```bash
# Jest
npm test || npx jest
npm run test:unit
npm run test:integration

# Jest with coverage
npm test -- --coverage

# Vitest
npm run test || npx vitest run

# Mocha
npm run test || npx mocha

# Playwright (E2E)
npm run test:e2e || npx playwright test

# Cypress (E2E)
npm run cypress:run || npx cypress run

# pnpm
pnpm test

# yarn
yarn test
```

### Python

```bash
# pytest
pytest

# pytest with specific markers
pytest -m "not slow"

# pytest with coverage
pytest --cov=src --cov-report=term-missing

# pytest verbose
pytest -v

# unittest
python -m unittest discover

# nose2
nose2
```

### Rust

```bash
# Cargo test
cargo test

# Cargo test with output
cargo test -- --nocapture

# Cargo test specific test
cargo test test_name

# Cargo test with coverage
cargo tarpaulin --out Html
```

### Go

```bash
# Go test
go test ./...

# Go test with verbose
go test -v ./...

# Go test with coverage
go test -cover ./...

# Go test specific package
go test ./pkg/...
```

### Java/Kotlin

```bash
# Maven
mvn test

# Gradle
./gradlew test

# Gradle with specific test
./gradlew test --tests "TestClassName.testMethod"
```

### Ruby

```bash
# RSpec
rspec

# RSpec with specific file
rspec spec/models/user_spec.rb

# Minitest
rake test
```

### PHP

```bash
# PHPUnit
./vendor/bin/phpunit

# PHPUnit with coverage
./vendor/bin/phpunit --coverage-html coverage/
```

## Pass/Fail Criteria

### PASS Criteria
- Exit code: 0
- All tests passing
- No test failures
- No test errors
- No unexpected skipped tests
- Test execution time within acceptable range

### FAIL Criteria (BLOCKING)
- Exit code: non-zero
- One or more test failures
- Test errors (not failures)
- Test timeouts
- Setup/teardown failures
- Test suite didn't run (configuration issues)

### Special Cases
- **Skipped Tests**: Acceptable if documented and intentional
- **Flaky Tests**: Retry mechanism (1-2 retries per test)
- **Slow Tests**: Document if execution time > baseline + 50%

## Execution Flow

1. **Detect Test Framework**
   - Check package.json for test script
   - Identify test framework (Jest, pytest, etc.)
   - Verify test configuration exists

2. **Pre-Test Validation**
   - Ensure build passed (Gate 1)
   - Ensure type check passed (Gate 2)
   - Ensure linter passed with no errors (Gate 3)
   - Check for test files existence

3. **Run Test Suite**
   - Execute test command
   - Capture stdout and stderr
   - Track execution time per test file
   - Monitor for timeouts

4. **Parse Test Results**
   - Count total tests
   - Count passed tests
   - Count failed tests
   - Count skipped tests
   - Identify failed test names and locations

5. **Analyze Failures**
   - Categorize failure types
   - Extract error messages
   - Identify patterns (regression, flaky, new code)

## Error Analysis & Suggestions

### Common Test Failures

#### Assertion Failures
```
Error Pattern: Expected X but got Y, Assertion failed
Root Causes:
- Code logic bug
- Test expectation outdated
- Data fixture issue
- State management problem

Analysis Steps:
1. Review test assertion: Is it correct?
2. Check recent code changes: Did logic change?
3. Verify test data: Is fixture valid?
4. Check test isolation: Is state properly reset?

Suggested Fixes:
- Fix code bug if logic is wrong
- Update test expectation if intentional behavior change
- Update fixtures if data structure changed
- Add proper setup/teardown for state management

Retry: After fixing code or test
```

#### Reference Errors (Undefined/Null)
```
Error Pattern: Cannot read property 'X' of undefined/null, ReferenceError
Root Causes:
- Uninitialized variable
- Async timing issue
- Missing mock setup
- Incorrect object structure

Analysis Steps:
1. Check variable initialization
2. Verify async operations complete before assertion
3. Review mock configuration
4. Validate data structure matches expected shape

Suggested Fixes:
- Initialize variables properly
- Use await for async operations
- Add missing mocks: jest.mock('./module')
- Add null checks or optional chaining

Retry: After fixing initialization or async handling
```

#### Timeout Errors
```
Error Pattern: Test exceeded timeout, Async operation timed out
Root Causes:
- Infinite loop or recursion
- Network request not mocked
- Promise never resolves
- Slow test operation

Analysis Steps:
1. Check for infinite loops
2. Verify all external calls are mocked
3. Ensure all promises resolve/reject
4. Profile test execution time

Suggested Fixes:
- Fix infinite loops
- Mock network requests: jest.mock('axios')
- Add promise resolution: resolve() or reject()
- Increase timeout for legitimately slow tests
- Optimize slow operations

Retry: After fixing async issues or adding mocks
```

#### Mock/Spy Failures
```
Error Pattern: Expected mock to be called, Spy not invoked
Root Causes:
- Function not called as expected
- Mock not properly configured
- Incorrect mock assertion
- Execution path changed

Analysis Steps:
1. Verify function is actually called in code path
2. Check mock setup timing (before vs after import)
3. Review mock assertion syntax
4. Trace execution flow

Suggested Fixes:
- Update code to call expected function
- Move mock setup before import
- Fix assertion: expect(mock).toHaveBeenCalledWith(...)
- Update test to match new execution path

Retry: After fixing mock setup or assertions
```

#### Snapshot Mismatches
```
Error Pattern: Snapshot doesn't match, Received value does not match stored snapshot
Root Causes:
- Intentional component/output change
- Unintentional regression
- Dynamic data in snapshot (timestamps, IDs)
- Environment-specific differences

Analysis Steps:
1. Review snapshot diff carefully
2. Determine if change is intentional
3. Check for dynamic values in output
4. Verify test environment consistency

Suggested Fixes:
- Update snapshot if change is intentional: npm test -- -u
- Fix regression if unintentional
- Mock dynamic values (Date.now(), Math.random())
- Stabilize test environment

Retry: After updating snapshots or fixing code
```

#### Database/Setup Errors
```
Error Pattern: Connection failed, Table doesn't exist, Fixture load error
Root Causes:
- Test database not initialized
- Migrations not run
- Fixtures not loaded
- Connection configuration wrong

Analysis Steps:
1. Check test database setup
2. Verify migrations executed
3. Review fixture loading order
4. Check database connection config

Suggested Fixes:
- Initialize test database: npm run db:test:setup
- Run migrations: npm run db:migrate:test
- Fix fixture loading sequence
- Update test database configuration

Retry: After database setup
```

## Flaky Test Handling

```pseudo
for each test:
    max_retries = 2  # Allow 2 retries for flaky tests
    attempts = 0

    while attempts <= max_retries:
        result = run_test(test)

        if result.passed:
            mark_as_passed(test)
            break
        else:
            attempts += 1

            if attempts > max_retries:
                mark_as_failed(test)
                log_flaky_behavior(test, attempts)
            else:
                log_retry(test, attempts)
                wait_before_retry(1_second)
```

**Flaky Test Identification**: If a test passes after retry, flag it as potentially flaky for investigation.

## Retry Logic

```pseudo
attempt = 0
max_attempts = 3
previous_failure_count = infinity

while attempt < max_attempts:
    result = run_tests()
    failures = count_failures(result)

    if result.success and failures == 0:
        report_success()
        return PASS

    attempt += 1

    # Check if making progress
    if failures >= previous_failure_count:
        escalate_to_user("No progress on test failures")
        return FAIL

    previous_failure_count = failures

    if attempt < max_attempts:
        analyze_failures(result)
        categorize_failure_types()
        suggest_fixes()

        if failures_are_flaky():
            log_flaky_tests()
            continue  # Retry without changes
        else:
            prompt_user_for_fix()
            wait_for_user_confirmation()
    else:
        report_failure()
        trigger_rollback()
        return FAIL
```

## Blocking Behavior

**This gate is BLOCKING**

- Runs only AFTER Gate 3 (Linting) passes with no errors
- If tests fail after 3 attempts: HALT execution
- Do NOT proceed to Gate 5 (Coverage Validation)
- Do NOT proceed to Gate 6 (Security Scan)
- Trigger rollback procedure
- Do NOT commit code with failing tests

## Success Reporting

```markdown
### Test Execution: ✅ PASS

- Test Framework: Jest v[version] / pytest v[version] / etc.
- Total Tests: [count]
- Passed: [count]
- Failed: 0
- Skipped: [count] (if any, list reasons)
- Test Suites: [count] passed / [total]
- Execution Time: [X.X seconds]
- Flaky Tests Detected: [count] (list if any)

**Performance**:
- Fastest Test: [name] ([X]ms)
- Slowest Test: [name] ([X]s)
- Average Test Time: [X]ms
```

## Failure Reporting

```markdown
### Test Execution: ❌ FAIL

- Test Framework: Jest v[version] / pytest v[version] / etc.
- Attempt: [X/3]
- Total Tests: [count]
- Passed: [count]
- Failed: [count]
- Skipped: [count]
- Test Suites: [count] failed, [count] passed / [total]
- Exit Code: [code]

**Failed Tests**:
1. [test file path] > [test suite] > [test name]
   - Error: [error message]
   - Expected: [expected value]
   - Received: [actual value]
   - Location: [file:line:col]

2. [test file path] > [test suite] > [test name]
   - Error: [error message]
   ...

**Failure Categories**:
- Assertion Failures: [count]
- Timeout Errors: [count]
- Reference Errors: [count]
- Mock Failures: [count]
- Setup/Teardown Errors: [count]

**Suggested Fixes**:
[Specific actionable recommendations per failure type]

**Next Steps**:
1. Fix [highest priority failure]
2. Review test expectations for intentional changes
3. Update mocks if needed
4. Re-run tests
```

## Integration with Quality Gate Sequence

This is **Gate 4** in the quality gate sequence:

```
Gate 1: Build Verification → BLOCKING ✅ (prerequisite)
Gate 2: Type Checking → BLOCKING ✅ (prerequisite)
Gate 3: Linting → HIGH PRIORITY ✅ (prerequisite)
Gate 4: Test Execution (THIS GATE) → BLOCKING
Gate 5: Coverage Validation → RECOMMENDED
Gate 6: Security Scan (Quick) → RECOMMENDED
```

**Sequential Execution**: Runs after Gate 3 passes, must complete successfully before Gate 5.

## Special Considerations

### Test Types
- **Unit Tests**: Fast, isolated, high coverage
- **Integration Tests**: Test component interactions
- **E2E Tests**: Full application flow (slower)
- Run unit tests first, then integration, then E2E

### Parallel Test Execution
- Enable parallel testing for speed: `jest --maxWorkers=4`
- Ensure tests are independent and isolated
- Watch for race conditions in parallel execution

### Test Database Management
- Use separate test database
- Reset database state between tests
- Use transactions for test isolation
- Clean up test data after suite

### Environment Variables
- Set TEST_ENV or NODE_ENV=test
- Load test-specific configuration
- Mock external services
- Use test-specific API keys (if needed)

### Performance Thresholds
- Baseline test time: Record on first successful run
- Alert if total time increases > 30%
- Identify slow tests: threshold > 5 seconds
- Consider splitting slow test suites

### Watch Mode
- For development: `npm test -- --watch`
- Not recommended for quality gates
- Quality gates should run full suite

### Monorepo Considerations
- Run tests for all affected packages
- Use dependency graph to identify affected tests
- Consider test parallelization across packages

## Related Quality Gates

- **Build Verification (Gate 1)**: Must pass before tests run
- **Type Checking (Gate 2)**: Must pass before tests run
- **Linting (Gate 3)**: Must pass (no errors) before tests run
- **Coverage Validation (Gate 5)**: Runs after successful test execution
