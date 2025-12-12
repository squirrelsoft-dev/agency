# Quality Gate: Linting

**Gate Priority**: HIGH PRIORITY (Gate 3)
**Blocking**: PARTIAL - Errors block, warnings allow proceed
**Max Retry Attempts**: 3

## Purpose

Enforce code style, quality standards, and best practices. Detect potential bugs, code smells, and maintainability issues before they reach production.

## Framework-Specific Commands

### JavaScript/TypeScript

```bash
# ESLint (npm)
npm run lint || npx eslint .

# ESLint with auto-fix
npm run lint -- --fix || npx eslint . --fix

# pnpm
pnpm lint || pnpm exec eslint .

# yarn
yarn lint || yarn eslint .

# Specific files/directories
npx eslint src/ --ext .ts,.tsx,.js,.jsx

# With custom config
npx eslint . --config .eslintrc.json
```

### Python

```bash
# Ruff (modern, fast linter)
ruff check .

# Ruff with auto-fix
ruff check . --fix

# Pylint
pylint src/ --rcfile=.pylintrc

# Flake8
flake8 src/ --config=.flake8

# Black (formatter check)
black --check src/

# isort (import sorting)
isort --check-only src/
```

### Rust

```bash
# Clippy
cargo clippy -- -D warnings

# Clippy with auto-fix
cargo clippy --fix

# Rustfmt check
cargo fmt -- --check
```

### Go

```bash
# golangci-lint (comprehensive)
golangci-lint run

# golint
golint ./...

# go fmt check
test -z $(gofmt -l .)

# go vet
go vet ./...
```

### Java/Kotlin

```bash
# Checkstyle (Java)
mvn checkstyle:check

# SpotBugs (Java)
mvn spotbugs:check

# ktlint (Kotlin)
./gradlew ktlintCheck

# detekt (Kotlin)
./gradlew detekt
```

### Ruby

```bash
# RuboCop
rubocop

# RuboCop with auto-fix
rubocop -a
```

## Pass/Fail Criteria

### PASS Criteria
- Exit code: 0
- Zero linting errors
- Warnings acceptable (document count)
- Auto-fixable issues resolved

### FAIL Criteria (BLOCKING)
- Exit code: non-zero
- Linting errors present (not warnings)
- Code style violations (error level)
- Security-related lint rules triggered
- Deprecated API usage (if configured as error)

### WARN Criteria (NON-BLOCKING)
- Warnings only, no errors
- Code complexity warnings
- TODO/FIXME comments
- Console.log statements (in production code)
- Unused variables (warning level)

## Execution Flow

1. **Detect Linter Configuration**
   - Check for .eslintrc.*, .pylintrc, .ruff.toml, etc.
   - Identify linter type and version
   - Verify configuration validity

2. **Run Linter**
   - Execute lint command
   - Capture stdout and stderr
   - Parse output format (json/stylish/compact)

3. **Categorize Issues**
   - Separate errors from warnings
   - Group by rule type
   - Identify auto-fixable issues

4. **Auto-Fix Attempt**
   - Run linter with --fix flag
   - Verify fixes don't break code
   - Re-run linter to confirm fixes

5. **Analyze Remaining Issues**
   - Count errors and warnings
   - Prioritize by severity
   - Generate fix suggestions

## Error Analysis & Suggestions

### Common Linting Errors

#### ESLint: no-unused-vars
```
Error Pattern: 'X' is defined but never used
Root Causes:
- Variable declared but not referenced
- Import statement unused
- Function parameter unused
- Dead code

Suggested Fixes:
1. Remove unused variable/import
2. Prefix with underscore if intentionally unused: _unusedParam
3. Add eslint-disable comment if needed for API compatibility
4. Use the variable or remove the declaration

Auto-Fixable: Partially (can remove imports)
Retry: After removing unused code
```

#### ESLint: no-console
```
Error Pattern: Unexpected console statement
Root Causes:
- Console.log left in production code
- Debugging statements not removed
- Missing proper logging framework

Suggested Fixes:
1. Remove console statements
2. Replace with proper logger: logger.info(), logger.error()
3. Add eslint-disable for intentional console usage
4. Use conditional console in development only

Auto-Fixable: No (requires decision on replacement)
Retry: After removing or replacing console statements
```

#### ESLint: @typescript-eslint/no-explicit-any
```
Error Pattern: Unexpected any. Specify a different type
Root Causes:
- Using 'any' type defeats TypeScript benefits
- Lazy type annotation
- Unknown type structure

Suggested Fixes:
1. Define proper type/interface
2. Use 'unknown' and type guards instead
3. Use generic type parameters
4. Create union type for known possibilities

Auto-Fixable: No (requires type definition)
Retry: After adding proper types
```

#### Python Ruff: F401 - Unused import
```
Error Pattern: Module imported but unused
Root Causes:
- Import not referenced in file
- Refactored code removed usage
- Auto-import added unnecessarily

Suggested Fixes:
1. Remove unused import
2. Use import in code
3. Mark as re-export: __all__ = ['X']

Auto-Fixable: Yes
Retry: Auto-fix will resolve
```

#### Python Ruff: E501 - Line too long
```
Error Pattern: Line exceeds maximum length (79/88/120 chars)
Root Causes:
- Long string literals
- Complex expressions
- Long import statements
- Long URLs in comments

Suggested Fixes:
1. Break line into multiple lines
2. Extract variables for readability
3. Use parentheses for implicit line continuation
4. Add noqa comment if truly unavoidable

Auto-Fixable: Partially
Retry: After reformatting code
```

#### Rust Clippy: clippy::unwrap_used
```
Error Pattern: Used unwrap() which can panic
Root Causes:
- Using .unwrap() on Option/Result
- Not handling error cases
- Potential runtime panic

Suggested Fixes:
1. Use .unwrap_or(), .unwrap_or_else(), .unwrap_or_default()
2. Use pattern matching: match result { Ok(v) => ..., Err(e) => ... }
3. Use ? operator for error propagation
4. Use .expect() with descriptive message

Auto-Fixable: No (requires error handling decision)
Retry: After adding proper error handling
```

## Auto-Fix Strategy

1. **First Pass: Safe Auto-Fixes**
   - Run linter with --fix flag
   - Apply formatting corrections
   - Remove unused imports
   - Sort imports
   - Fix simple style issues

2. **Verification After Auto-Fix**
   - Re-run linter to confirm fixes
   - Verify code still compiles/builds
   - Check tests still pass (quick smoke test)

3. **Manual Fix Required**
   - Report issues that need human decision
   - Provide specific suggestions per issue
   - Prioritize by severity and impact

## Retry Logic

```pseudo
attempt = 0
max_attempts = 3
previous_error_count = infinity

while attempt < max_attempts:
    result = run_linter()
    errors = count_errors(result)
    warnings = count_warnings(result)

    if errors == 0:
        if warnings > 0:
            report_warnings(warnings)
        report_success()
        return PASS

    attempt += 1

    # Check if making progress
    if errors >= previous_error_count:
        # No progress, escalate
        if attempt == 1:
            # Try auto-fix on first attempt
            auto_fix_result = run_linter_with_fix()
            continue
        else:
            escalate_to_user("No progress on linting errors")
            return FAIL

    previous_error_count = errors

    if attempt < max_attempts:
        categorize_errors(result)
        suggest_fixes_by_rule()

        if has_auto_fixable_errors():
            apply_auto_fix()
        else:
            prompt_user_for_fix()
            wait_for_user_confirmation()
    else:
        report_failure()
        trigger_rollback()
        return FAIL
```

## Blocking Behavior

**This gate is PARTIALLY BLOCKING**

- Runs only AFTER Gate 2 (Type Checking) passes
- **Errors**: BLOCKING - Must fix before proceeding
- **Warnings**: NON-BLOCKING - Document and proceed
- If linting errors persist after 3 attempts: HALT execution
- Do NOT proceed to Gate 4 (Tests) if errors exist
- Warnings allow proceeding to next gate

## Success Reporting

```markdown
### Linting: ✅ PASS

- Linter: ESLint v[version] / Ruff v[version] / etc.
- Configuration: .eslintrc.json / .ruff.toml / etc.
- Files Checked: [count]
- Errors: 0
- Warnings: [count]
- Auto-Fixed Issues: [count]
- Lint Time: [X.X seconds]

**Warning Summary** (if any):
- no-console: [count] occurrences
- complexity: [count] functions exceed threshold
- TODO comments: [count]
```

## Failure Reporting

```markdown
### Linting: ❌ FAIL

- Linter: ESLint v[version] / Ruff v[version] / etc.
- Attempt: [X/3]
- Total Errors: [count]
- Total Warnings: [count]
- Auto-Fixed Issues: [count]
- Exit Code: [code]

**Error Breakdown by Rule**:
1. no-unused-vars: [count]
2. @typescript-eslint/no-explicit-any: [count]
3. no-console: [count]
4. [other rules]: [count]

**Top 5 Files with Errors**:
1. [file path]: [error count]
2. [file path]: [error count]
3. [file path]: [error count]
4. [file path]: [error count]
5. [file path]: [error count]

**Sample Errors** (first 10):
```
[file:line:col] [rule-id] [message]
```

**Auto-Fixable**: [count] errors can be auto-fixed

**Suggested Fixes**:
[Rule-specific actionable recommendations]

**Next Steps**:
1. Run linter with --fix: npm run lint -- --fix
2. Manually fix remaining [count] errors
3. Review warnings and address high-priority ones
4. Re-run linting
```

## Integration with Quality Gate Sequence

This is **Gate 3** in the quality gate sequence:

```
Gate 1: Build Verification → BLOCKING ✅ (prerequisite)
Gate 2: Type Checking → BLOCKING ✅ (prerequisite)
Gate 3: Linting (THIS GATE) → HIGH PRIORITY
Gate 4: Test Execution → BLOCKING
Gate 5: Coverage Validation → RECOMMENDED
Gate 6: Security Scan (Quick) → RECOMMENDED
```

**Sequential Execution**: Runs after Gate 2 passes, errors block Gate 4.

## Special Considerations

### Linter Configuration Quality
- Verify .eslintrc.* / .pylintrc / etc. exists
- Check for recommended rule sets
- Ensure consistent configuration across team
- Document any rule overrides

### Incremental Linting
- Lint only changed files in large projects
- Use git diff to identify files: `eslint $(git diff --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$')`
- Cache linting results for unchanged files

### Performance Optimization
- Use linter caching: ESLint --cache
- Parallel linting for monorepos
- Baseline lint time: Record on first successful run
- Alert if lint time increases significantly

### Auto-Fix Safety
- Always verify auto-fixes don't break functionality
- Run quick smoke test after auto-fix
- Review auto-fix changes before committing
- Some auto-fixes may change semantics (rare)

### Custom Rules
- Document project-specific linting rules
- Explain rationale for strict rules
- Provide examples of compliant code
- Consider rule severity: error vs warning

### Monorepo Considerations
- Lint all packages: `npm run lint --workspaces`
- Shared vs package-specific configurations
- Ensure consistent linting across packages

## Related Quality Gates

- **Build Verification (Gate 1)**: Must pass before linting runs
- **Type Checking (Gate 2)**: Must pass before linting runs
- **Test Execution (Gate 4)**: Runs after linting passes (if no errors)
