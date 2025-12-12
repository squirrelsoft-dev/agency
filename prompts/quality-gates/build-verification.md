# Quality Gate: Build Verification

**Gate Priority**: CRITICAL (Gate 1)
**Blocking**: YES - Must pass before proceeding
**Max Retry Attempts**: 3

## Purpose

Verify that the codebase compiles/builds successfully across all supported package managers and build systems.

## Framework-Specific Commands

### JavaScript/TypeScript (Node.js)

```bash
# npm
npm run build

# pnpm
pnpm run build || pnpm build

# yarn
yarn build

# Fallback for TypeScript-only projects
npm run compile || npx tsc

# Next.js specific
npm run build && npm run lint
```

### Python

```bash
# pip with setup.py
python setup.py build

# Poetry
poetry build

# setuptools with pyproject.toml
python -m build

# Django
python manage.py check --deploy

# Flask (typically no build, but validate imports)
python -c "import app; print('Build verification: OK')"
```

### Rust

```bash
# Cargo
cargo build --release

# Check without building artifacts
cargo check --all-targets
```

### Go

```bash
# Build
go build ./...

# Verify all packages
go build -v ./...
```

### Java/Kotlin

```bash
# Maven
mvn clean compile

# Gradle
gradle build --no-daemon
```

## Pass/Fail Criteria

### PASS Criteria
- Exit code: 0
- No compilation errors
- All dependencies resolved
- Build artifacts generated (if applicable)
- No fatal warnings (language-specific)

### FAIL Criteria
- Exit code: non-zero
- Compilation/syntax errors
- Missing dependencies
- Type errors (in TypeScript/compiled languages)
- Out of memory errors
- Timeout (> 10 minutes)

## Execution Flow

1. **Detect Build System**
   - Check for package.json (npm/pnpm/yarn)
   - Check for Cargo.toml (Rust)
   - Check for go.mod (Go)
   - Check for pyproject.toml/setup.py (Python)
   - Check for pom.xml/build.gradle (Java/Kotlin)

2. **Run Build Command**
   - Execute appropriate build command
   - Capture stdout and stderr
   - Track execution time

3. **Analyze Results**
   - Check exit code
   - Parse error messages
   - Identify failure category

## Error Analysis & Suggestions

### Common Errors

#### Syntax/Compilation Errors
```
Error Pattern: SyntaxError, unexpected token, parse error
Action:
- Review recent code changes
- Check for unclosed brackets, missing semicolons
- Verify language syntax compliance
Retry: After fixing syntax errors
```

#### Dependency Issues
```
Error Pattern: Cannot find module, package not found, dependency resolution failed
Action:
- Run package manager install: npm install, pip install -r requirements.txt
- Clear package manager cache: npm cache clean --force
- Verify package.json/requirements.txt correctness
Retry: After dependency resolution
```

#### Type Errors (TypeScript)
```
Error Pattern: TS[0-9]+, type mismatch, property does not exist
Action:
- Run type checker separately: npx tsc --noEmit
- Review type annotations
- Check for missing @types packages
Retry: After fixing type errors
```

#### Memory Errors
```
Error Pattern: JavaScript heap out of memory, OOM
Action:
- Increase Node.js memory: NODE_OPTIONS=--max-old-space-size=4096 npm run build
- Check for circular dependencies
- Consider incremental builds
Retry: With increased memory allocation
```

#### Configuration Errors
```
Error Pattern: Invalid configuration, plugin not found, loader error
Action:
- Review build configuration files (webpack.config.js, tsconfig.json, etc.)
- Verify plugin versions compatibility
- Check for breaking changes in build tool versions
Retry: After configuration fixes
```

## Retry Logic

```pseudo
attempt = 0
max_attempts = 3

while attempt < max_attempts:
    result = run_build_command()

    if result.success:
        report_success()
        return PASS

    attempt += 1

    if attempt < max_attempts:
        analyze_error(result.stderr)
        suggest_fixes()

        if auto_fixable(result.error):
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

**This gate is BLOCKING**

- If build fails after 3 attempts: HALT execution
- Do NOT proceed to Gate 2 (Type Checking)
- Do NOT proceed to Gate 3 (Linting)
- Do NOT proceed to Gate 4 (Tests)
- Trigger rollback procedure

## Success Reporting

```markdown
### Build Verification: ✅ PASS

- Build Tool: [npm/pnpm/yarn/cargo/etc.]
- Build Time: [X.X seconds]
- Artifacts Generated: [list if applicable]
- Warnings: [count if any]
```

## Failure Reporting

```markdown
### Build Verification: ❌ FAIL

- Build Tool: [npm/pnpm/yarn/cargo/etc.]
- Attempt: [X/3]
- Exit Code: [code]
- Error Category: [Syntax/Dependency/Type/Memory/Configuration]

**Error Output**:
```
[First 50 lines of error output]
```

**Suggested Fix**:
[Specific actionable recommendations]

**Next Steps**:
1. [Specific action item]
2. [Specific action item]
3. Re-run build verification
```

## Integration with Quality Gate Sequence

This is **Gate 1** in the quality gate sequence:

```
Gate 1: Build Verification (THIS GATE) → BLOCKING
Gate 2: Type Checking → BLOCKING
Gate 3: Linting → HIGH PRIORITY
Gate 4: Test Execution → BLOCKING
Gate 5: Coverage Validation → RECOMMENDED
Gate 6: Security Scan (Quick) → RECOMMENDED
```

**Sequential Execution**: This gate MUST complete successfully before any other gates run.

## Special Considerations

### Monorepo Projects
- Build all packages: `npm run build --workspaces`
- Verify build order for dependent packages
- Check for cross-package type errors

### Incremental Builds
- Leverage build caching when available
- Clear cache only if suspected to be corrupted
- Document cache behavior in report

### Environment-Specific Builds
- Development: May allow warnings
- Production: Must be warning-free
- CI/CD: Stricter validation

### Performance Thresholds
- Baseline build time: Record on first successful build
- Alert if build time increases > 50%
- Investigate build performance degradation

## Related Quality Gates

- **Type Checking (Gate 2)**: Runs after build passes, focuses on TypeScript type validation
- **Linting (Gate 3)**: Code style validation, can auto-fix many issues
- **Test Execution (Gate 4)**: Functional verification after successful build
