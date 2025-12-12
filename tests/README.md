# Phase 2 Commands Test Suite

Comprehensive testing for Agency Phase 2 commands: sprint, refactor, optimize, document.

## Test Structure

```
tests/
├── README.md                           # This file
├── validate-phase2-commands.sh         # Structural validation script
├── integration/                        # Integration test documentation
│   ├── sprint-integration-tests.md     # Sprint command integration tests
│   ├── refactor-integration-tests.md   # Refactor command integration tests
│   ├── optimize-integration-tests.md   # Optimize command integration tests
│   └── document-integration-tests.md   # Document command integration tests
└── fixtures/                           # Test fixtures (future)
```

## Running Tests

### Structural Validation

Validates YAML frontmatter, required sections, phase structure, and command-specific features:

```bash
cd tests
./validate-phase2-commands.sh
```

**Expected Output**: 100% pass rate (123/123 tests)

**What It Tests**:
- ✓ File existence
- ✓ YAML frontmatter validity
- ✓ Required sections present
- ✓ Phase structure and numbering
- ✓ Project context detection
- ✓ Skill activation
- ✓ TodoWrite usage
- ✓ AskUserQuestion usage
- ✓ Agent spawning patterns
- ✓ Error handling coverage
- ✓ Code examples
- ✓ Command-specific features

### Integration Tests

See `integration/` directory for manual integration test procedures for each command.

## Test Results

### Latest Test Run

**Date**: 2024-12-11
**Test Suite**: validate-phase2-commands.sh
**Result**: ✅ **100% Pass Rate** (123/123 tests)

**Commands Tested**:
1. ✅ `/agency:sprint` - 31/31 tests passed
2. ✅ `/agency:refactor` - 31/31 tests passed
3. ✅ `/agency:optimize` - 31/31 tests passed
4. ✅ `/agency:document` - 30/30 tests passed

**Command Statistics**:

| Command | Size (lines) | Phases | Code Examples | Error Scenarios |
|---------|--------------|--------|---------------|-----------------|
| sprint | 1,722 | 8 | 54 | 6 |
| refactor | 1,617 | 6 | 40 | 6 |
| optimize | 1,253 | 7 | 38 | 4 |
| document | 1,588 | 5 | 47 | 4 |
| **Total** | **6,180** | **26** | **179** | **20** |

## Test Categories

### 1. Structural Tests

**YAML Frontmatter**:
- Opening/closing delimiters (`---`)
- Required fields: `description`, `argument-hint`, `allowed-tools`
- Field format validation

**Command Structure**:
- Title matches pattern: `# [Name]: $ARGUMENTS`
- Required sections: Your Mission, Critical Instructions, Phase 0, Error Handling, Important Notes, Skills, Related Commands
- Section hierarchy and ordering

**Phase Structure**:
- Minimum 4 phases (Phase 0 + at least 3 main phases)
- Sequential phase numbering (0, 1, 2, 3...)
- Phase titles include time estimates

### 2. Pattern Compliance Tests

**Project Detection** (Phase 0):
- Framework detection logic present
- Bash file existence checks used
- Detection results used for agent/tool selection

**Skill Activation**:
- References `agency-workflow-patterns` skill
- Activation instruction in Critical Instructions section
- Uses "IMMEDIATELY" keyword (warning if missing)

**Progress Tracking**:
- TodoWrite tool referenced
- Instructs creating todo list with phases
- Todo updates throughout workflow

**User Interaction**:
- AskUserQuestion used for critical decisions
- Options provided for user choice
- User approval gates before major actions

**Agent Spawning**:
- Task tool usage for delegating to specialists
- Agent selection guidance (tables or lists)
- Context and instructions provided to agents

### 3. Quality Tests

**Error Handling**:
- Minimum 3 error scenarios documented
- Each scenario has recovery strategy
- Critical errors have rollback procedures

**Code Examples**:
- Minimum 5 code examples per command
- Bash script examples included
- Examples demonstrate key workflows

**Documentation**:
- Clear, concise language
- Consistent formatting
- Related commands cross-referenced

### 4. Command-Specific Tests

**Sprint Command**:
- Mentions dependency resolution
- Mentions parallel execution
- References GitHub/Jira provider support
- Includes batch execution logic
- Has integration testing phase

**Refactor Command**:
- Mentions rollback/checkpoint strategy
- Mentions incremental refactoring
- Emphasizes test preservation
- Includes code quality analysis
- Has before/after metrics

**Optimize Command**:
- Mentions benchmarking/profiling
- Mentions baseline measurement
- References specific profiling tools (Lighthouse, autocannon, etc.)
- Includes incremental optimization
- Has performance reporting

**Document Command**:
- Mentions documentation templates
- Includes code example validation
- References documentation types (API, Architecture, Component, Feature, Code)
- Has documentation review phase
- Includes link validation

## Adding New Tests

### To Add a Structural Test

Edit `validate-phase2-commands.sh` and add a new test function:

```bash
test_new_feature() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  if grep -q "expected pattern" "$file"; then
    pass "New feature present"
  else
    fail "New feature missing"
  fi
}
```

Then call it in the `main()` function for each command.

### To Add an Integration Test

Create a new markdown file in `integration/` directory:

```markdown
# [Command] Integration Tests

## Test Case 1: [Name]

**Objective**: [What this test validates]

**Setup**:
1. [Prerequisite step 1]
2. [Prerequisite step 2]

**Execution**:
1. Run: `/agency:[command] [args]`
2. [Interaction step]
3. [Verification step]

**Expected Result**:
- [Expected outcome 1]
- [Expected outcome 2]

**Success Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

## Test Maintenance

### When to Update Tests

- **Command Structure Changes**: Update `validate-phase2-commands.sh` if new required sections added
- **New Commands**: Add command to `COMMANDS` array and add command-specific tests
- **Pattern Changes**: Update pattern compliance tests if workflow patterns change
- **Bug Fixes**: Add regression test for fixed bugs

### Test Coverage Goals

Target metrics:
- **Structural Validation**: 100% (all required sections and patterns)
- **Command-Specific Features**: 100% (all key features tested)
- **Error Scenarios**: ≥3 per command (critical error paths)
- **Code Examples**: ≥5 per command (key workflows demonstrated)

## Common Issues

### Test Failures

**Missing Section**:
```
✗ Missing section: ## Error Handling
```
**Fix**: Add the missing section to the command file before "Skills to Reference"

**Invalid YAML**:
```
✗ YAML frontmatter missing opening '---'
```
**Fix**: Ensure YAML frontmatter starts on line 1 with `---`

**Phase Numbering**:
```
✗ Phase numbering is not sequential
```
**Fix**: Ensure phases are numbered 0, 1, 2, 3... without gaps

**Missing Skill Reference**:
```
✗ Missing reference to 'agency-workflow-patterns' skill
```
**Fix**: Add `agency-workflow-patterns` skill reference in Critical Instructions

## CI/CD Integration

### GitHub Actions (Future)

```yaml
name: Phase 2 Commands Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run validation tests
        run: |
          cd tests
          chmod +x validate-phase2-commands.sh
          ./validate-phase2-commands.sh
```

### Pre-commit Hook (Recommended)

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run tests before allowing commit
cd tests
./validate-phase2-commands.sh

if [ $? -ne 0 ]; then
  echo "❌ Phase 2 command validation failed. Please fix errors before committing."
  exit 1
fi

echo "✅ All validation tests passed"
exit 0
```

## Test Reports

Test results are printed to stdout with colored output:
- ✅ Green: Tests passed
- ❌ Red: Tests failed
- ⚠️ Yellow: Warnings (non-critical)
- ℹ️ Blue: Informational

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Tests: 123
Passed: 123
Failed: 0

✓ All tests passed! (100%)
```

## Future Enhancements

### Planned Test Additions

1. **E2E Integration Tests**: Actual command execution in test environments
2. **Performance Tests**: Measure command execution time benchmarks
3. **Regression Tests**: Automated tests for previously fixed bugs
4. **Cross-Platform Tests**: Validate commands work on macOS, Linux, Windows
5. **Fixture-Based Tests**: Reusable test fixtures for common scenarios

### Test Infrastructure Improvements

1. **Test Fixtures**: Sample projects for testing commands
2. **Mock Providers**: Mock GitHub/Jira APIs for isolated testing
3. **Coverage Reporting**: Detailed test coverage reports
4. **Continuous Monitoring**: Dashboard showing test health over time

## Contributing

When contributing new commands or modifying existing ones:

1. **Run validation tests** before committing:
   ```bash
   cd tests && ./validate-phase2-commands.sh
   ```

2. **Ensure 100% pass rate** - All tests must pass

3. **Add command-specific tests** if introducing new features

4. **Update documentation** to reflect changes

5. **Follow established patterns** from existing commands

## Support

For questions about testing:
- Review this README
- Check existing test implementations in `validate-phase2-commands.sh`
- Review integration test documentation in `integration/`
- Open an issue if you find gaps in test coverage

---

**Test Suite Version**: 1.0.0
**Last Updated**: 2024-12-11
**Maintainer**: Agency Plugin Team
