# Quality Gate: Coverage Validation

**Gate Priority**: RECOMMENDED (Gate 5)
**Blocking**: NO - Informational with recommendations
**Max Retry Attempts**: 1 (no retry - report only)

## Purpose

Validate that test coverage meets quality standards (80% baseline). Identify untested code paths and recommend additional tests for improved code quality.

## Framework-Specific Commands

### JavaScript/TypeScript

```bash
# Jest with coverage
npm test -- --coverage
npm run test:coverage

# Jest with coverage threshold
npm test -- --coverage --coverageThreshold='{"global":{"lines":80,"branches":80,"functions":80,"statements":80}}'

# Vitest with coverage
npx vitest run --coverage

# NYC (Istanbul) with Mocha
npx nyc mocha

# pnpm
pnpm test:coverage

# yarn
yarn test:coverage
```

### Python

```bash
# pytest with coverage
pytest --cov=src --cov-report=term-missing --cov-report=html

# pytest with coverage threshold
pytest --cov=src --cov-fail-under=80

# pytest with detailed coverage
pytest --cov=src --cov-report=term-missing:skip-covered

# coverage.py
coverage run -m pytest
coverage report
coverage html
```

### Rust

```bash
# Tarpaulin (code coverage tool)
cargo tarpaulin --out Html --out Lcov

# Tarpaulin with threshold
cargo tarpaulin --fail-under 80

# llvm-cov
cargo llvm-cov --html
```

### Go

```bash
# Go coverage
go test -cover ./...

# Go coverage with profile
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Go coverage with threshold check
go test -cover ./... | grep -E 'coverage: [0-9]+' | awk '{if($2 < 80) exit 1}'
```

### Java/Kotlin

```bash
# JaCoCo with Maven
mvn test jacoco:report

# JaCoCo with Gradle
./gradlew test jacocoTestReport

# JaCoCo with threshold
./gradlew test jacocoTestCoverageVerification
```

### Ruby

```bash
# SimpleCov (add to test helper)
# Results generated automatically when running tests
rspec
```

## Pass/Fail Criteria

### PASS Criteria (80%+ Coverage)
- Overall coverage: ≥ 80%
- Line coverage: ≥ 80%
- Branch coverage: ≥ 80%
- Function coverage: ≥ 80%
- Statement coverage: ≥ 80%

### WARN Criteria (60-79% Coverage)
- Overall coverage: 60-79%
- Significant coverage gaps identified
- Critical paths untested
- New code lowers overall coverage

### FAIL Criteria (< 60% Coverage)
- Overall coverage: < 60%
- Critical functions untested
- No tests for new code
- Coverage trending downward

**Note**: This gate is NON-BLOCKING by default, but provides strong recommendations.

## Execution Flow

1. **Detect Coverage Tool**
   - Check for coverage configuration
   - Identify coverage tool (Jest, pytest-cov, etc.)
   - Verify coverage reporting setup

2. **Run Tests with Coverage**
   - Execute test suite with coverage enabled
   - Generate coverage report
   - Track execution time

3. **Parse Coverage Report**
   - Extract overall coverage percentage
   - Parse per-file coverage
   - Identify uncovered lines/branches
   - Extract coverage by type (line/branch/function)

4. **Analyze Coverage Gaps**
   - Identify files with < 80% coverage
   - Find completely untested files
   - Highlight critical paths without coverage
   - Compare against previous coverage baseline

5. **Generate Recommendations**
   - Prioritize files needing tests
   - Suggest test types (unit/integration)
   - Identify high-value test additions

## Coverage Metrics Explained

### Line Coverage
- **Definition**: Percentage of code lines executed during tests
- **Target**: ≥ 80%
- **Importance**: Basic metric, but can miss logical branches

### Branch Coverage
- **Definition**: Percentage of conditional branches (if/else) tested
- **Target**: ≥ 80%
- **Importance**: More thorough than line coverage, tests decision points

### Function Coverage
- **Definition**: Percentage of functions/methods called during tests
- **Target**: ≥ 80%
- **Importance**: Ensures all functions have some test coverage

### Statement Coverage
- **Definition**: Percentage of executable statements run during tests
- **Target**: ≥ 80%
- **Importance**: Similar to line coverage, more granular

### Uncovered Lines
- **Definition**: Specific lines not executed by any test
- **Importance**: Direct indicators of where to add tests

## Analysis & Recommendations

### High-Priority Coverage Gaps

#### Untested Critical Functions
```
Pattern: Core business logic functions with 0% coverage
Impact: HIGH - Critical functionality unverified
Recommendation:
1. Identify business-critical functions
2. Write unit tests for each function
3. Test happy path and error cases
4. Verify edge cases

Priority: CRITICAL
```

#### Untested Error Handling
```
Pattern: Error/catch blocks with 0% coverage
Impact: HIGH - Error scenarios untested, potential production issues
Recommendation:
1. Write tests that trigger error conditions
2. Verify error messages and codes
3. Test error recovery mechanisms
4. Ensure proper error propagation

Priority: HIGH
```

#### Untested Edge Cases
```
Pattern: Conditional branches with low coverage (< 50%)
Impact: MEDIUM - Incomplete testing of logic paths
Recommendation:
1. Identify all conditional branches
2. Write tests for true and false paths
3. Test boundary conditions
4. Cover null/undefined cases

Priority: MEDIUM
```

#### Low Coverage in New Code
```
Pattern: Recently added code with < 80% coverage
Impact: MEDIUM - New features not fully verified
Recommendation:
1. Add tests for new functions/modules
2. Ensure new code doesn't lower overall coverage
3. Test new features comprehensively
4. Consider test-driven development (TDD)

Priority: MEDIUM
```

### Coverage Improvement Strategies

#### Strategy 1: Bottom-Up (Utility Functions First)
1. Test pure utility functions (easiest)
2. Test data transformations
3. Test business logic
4. Test integration points
5. Add E2E tests last

#### Strategy 2: Top-Down (Critical Paths First)
1. Identify critical user workflows
2. Add E2E tests for critical paths
3. Fill in integration tests
4. Add unit tests for components
5. Test edge cases and errors

#### Strategy 3: Risk-Based (High-Risk Areas First)
1. Identify high-risk functionality (payments, auth, etc.)
2. Add comprehensive tests for high-risk areas
3. Test error scenarios thoroughly
4. Add integration tests for critical flows
5. Fill in remaining coverage gaps

## Execution Logic

```pseudo
result = run_tests_with_coverage()

coverage = parse_coverage_report(result)

overall_percentage = coverage.overall
line_coverage = coverage.lines
branch_coverage = coverage.branches
function_coverage = coverage.functions

# Determine status
if overall_percentage >= 80:
    status = PASS
    recommendation = "Excellent coverage! Maintain this level."
elif overall_percentage >= 60:
    status = WARN
    recommendation = "Good coverage, but room for improvement."
else:
    status = FAIL
    recommendation = "Coverage below recommended threshold. Add tests."

# Identify gaps
uncovered_files = find_files_below_threshold(coverage, 80)
untested_files = find_files_with_zero_coverage(coverage)
critical_gaps = find_untested_critical_functions(coverage)

# Generate recommendations
priority_files = prioritize_by_importance(uncovered_files)
suggested_tests = generate_test_suggestions(critical_gaps)

# Report (non-blocking)
report_coverage(status, overall_percentage, coverage, priority_files, suggested_tests)

return NON_BLOCKING  # Always proceed to next gate
```

## Non-Blocking Behavior

**This gate is NON-BLOCKING**

- Runs only AFTER Gate 4 (Test Execution) passes
- Coverage below threshold: REPORT but do NOT block
- Provide recommendations for improvement
- Proceed to Gate 6 (Security Scan) regardless of coverage
- User decides if coverage is acceptable for commit/deployment

**Rationale**: Coverage is a quality indicator, not a hard requirement. Some scenarios where low coverage is acceptable:
- Prototype/POC code
- Legacy code being refactored
- UI-heavy code difficult to test
- Third-party integration code

## Success Reporting

```markdown
### Coverage Validation: ✅ PASS (≥ 80%)

- Coverage Tool: Jest / pytest-cov / etc.
- Overall Coverage: [X]%
- Line Coverage: [X]%
- Branch Coverage: [X]%
- Function Coverage: [X]%
- Statement Coverage: [X]%

**Coverage by File** (top 5 well-tested):
1. [file path]: [X]%
2. [file path]: [X]%
3. [file path]: [X]%
4. [file path]: [X]%
5. [file path]: [X]%

**Recommendation**: Excellent coverage! Continue maintaining this standard.
```

## Warning Reporting

```markdown
### Coverage Validation: ⚠️ WARN (60-79%)

- Coverage Tool: Jest / pytest-cov / etc.
- Overall Coverage: [X]%
- Line Coverage: [X]%
- Branch Coverage: [X]%
- Function Coverage: [X]%
- Statement Coverage: [X]%
- **Target**: 80%
- **Gap**: [80 - X]%

**Files Below 80% Coverage** (top 10):
1. [file path]: [X]% coverage ([Y] uncovered lines)
2. [file path]: [X]% coverage ([Y] uncovered lines)
3. [file path]: [X]% coverage ([Y] uncovered lines)
...

**Completely Untested Files** ([count]):
- [file path] (0%)
- [file path] (0%)
...

**Critical Coverage Gaps**:
- [function/module name]: [description of gap]
- [function/module name]: [description of gap]

**Recommended Test Additions**:
1. **[file path]**: Add tests for [specific functions/scenarios]
   - Priority: HIGH/MEDIUM/LOW
   - Estimated Impact: +[X]% coverage

2. **[file path]**: Add tests for [specific functions/scenarios]
   - Priority: HIGH/MEDIUM/LOW
   - Estimated Impact: +[X]% coverage

**Next Steps**:
1. Add tests for high-priority gaps
2. Focus on critical business logic
3. Test error handling paths
4. Re-run coverage validation
```

## Failure Reporting

```markdown
### Coverage Validation: ❌ FAIL (< 60%)

- Coverage Tool: Jest / pytest-cov / etc.
- Overall Coverage: [X]%
- **Target**: 80%
- **Gap**: [80 - X]%
- **Status**: Below recommended threshold

**Coverage Breakdown**:
- Line Coverage: [X]%
- Branch Coverage: [X]%
- Function Coverage: [X]%
- Statement Coverage: [X]%

**Files with Lowest Coverage** (bottom 10):
1. [file path]: [X]%
2. [file path]: [X]%
...

**Completely Untested Files** ([count]):
- [file path]
- [file path]
...

**Untested Critical Functions**:
- [function name] in [file path]
- [function name] in [file path]
...

**Recommended Actions** (High Priority):
1. **Add unit tests for critical functions**: [specific functions]
2. **Test error handling**: [specific error paths]
3. **Add integration tests**: [specific workflows]
4. **Test edge cases**: [specific scenarios]

**Estimated Test Effort**:
- To reach 60%: ~[X] tests
- To reach 80%: ~[Y] tests

**Note**: This is a non-blocking gate, but strongly recommend improving coverage before production deployment.
```

## Integration with Quality Gate Sequence

This is **Gate 5** in the quality gate sequence:

```
Gate 1: Build Verification → BLOCKING ✅ (prerequisite)
Gate 2: Type Checking → BLOCKING ✅ (prerequisite)
Gate 3: Linting → HIGH PRIORITY ✅ (prerequisite)
Gate 4: Test Execution → BLOCKING ✅ (prerequisite)
Gate 5: Coverage Validation (THIS GATE) → RECOMMENDED
Gate 6: Security Scan (Quick) → RECOMMENDED
```

**Sequential Execution**: Runs after Gate 4 passes, does NOT block Gate 6.

## Special Considerations

### Coverage Thresholds
- **New Code**: Should aim for 100% coverage
- **Modified Code**: Should maintain or improve coverage
- **Overall**: 80% is a good baseline, 90%+ is excellent
- **Critical Modules**: Consider 95%+ requirement

### Excluding Files from Coverage
- Test files themselves
- Configuration files
- Generated code
- Vendor/third-party code
- Migration scripts

Configuration example (Jest):
```json
{
  "coveragePathIgnorePatterns": [
    "/node_modules/",
    "/test/",
    "/*.config.js",
    "/dist/",
    "/coverage/"
  ]
}
```

### Coverage vs Quality
- 100% coverage ≠ bug-free code
- Coverage measures test quantity, not quality
- Focus on meaningful tests, not just coverage numbers
- Test behavior, not implementation details

### Monorepo Considerations
- Generate coverage per package
- Aggregate coverage across packages
- Set per-package thresholds
- Identify packages needing attention

### Performance Impact
- Coverage adds overhead to test execution
- Typical impact: +20-50% execution time
- Use coverage in CI/CD, optional in local dev
- Cache coverage results when possible

### Coverage Trends
- Track coverage over time
- Alert on coverage decreases
- Celebrate coverage improvements
- Set coverage improvement goals

## Related Quality Gates

- **Test Execution (Gate 4)**: Must pass before coverage validation runs
- **Security Scan (Gate 6)**: Runs after coverage validation (non-blocking)
