# Quality Gate: Type Checking

**Gate Priority**: CRITICAL (Gate 2)
**Blocking**: YES - Must pass before proceeding
**Max Retry Attempts**: 3

## Purpose

Verify TypeScript type correctness without emitting build artifacts. Ensures type safety and catches type-related bugs before runtime.

## Framework-Specific Commands

### TypeScript (Node.js)

```bash
# npm
npm run type-check || npx tsc --noEmit

# pnpm
pnpm type-check || pnpm exec tsc --noEmit

# yarn
yarn type-check || yarn tsc --noEmit

# Project-specific type checking
npx tsc --noEmit --project tsconfig.json

# Check specific directories
npx tsc --noEmit --project src/tsconfig.json
```

### TypeScript with Monorepo

```bash
# Turborepo
npx turbo run type-check

# Nx
npx nx run-many --target=type-check --all

# Lerna
npx lerna run type-check

# Workspaces
npm run type-check --workspaces
```

### Python (Type Checking with mypy/pyright)

```bash
# mypy
mypy . --strict

# mypy with configuration
mypy --config-file mypy.ini src/

# pyright
pyright

# pyright with configuration
pyright --project pyrightconfig.json
```

### Other Languages

```bash
# Flow (JavaScript)
npx flow check

# Kotlin
kotlinc -Werror -d /dev/null src/

# Scala
scalac -Xfatal-warnings src/*.scala
```

## Pass/Fail Criteria

### PASS Criteria
- Exit code: 0
- No type errors (TS[0-9]+)
- All types properly resolved
- No `any` escapes (if strict mode enabled)
- No implicit `any` violations

### FAIL Criteria
- Exit code: non-zero
- Type errors present (TS2304, TS2322, TS2345, etc.)
- Unresolved type references
- Missing type declarations
- Type assertion errors

## Execution Flow

1. **Detect TypeScript Configuration**
   - Check for tsconfig.json
   - Identify strict mode settings
   - Detect project references

2. **Run Type Checker**
   - Execute tsc --noEmit (or equivalent)
   - Capture all type errors
   - Track execution time

3. **Parse Type Errors**
   - Count total errors
   - Categorize by error code
   - Group by file/module
   - Identify error severity

4. **Analyze and Report**
   - Provide error summaries
   - Suggest fixes for common patterns
   - Prioritize errors by impact

## Error Analysis & Suggestions

### Common Type Errors

#### TS2304: Cannot find name 'X'
```
Error Pattern: Cannot find name, identifier not found
Root Causes:
- Missing import statement
- Typo in variable/function name
- Variable declared in different scope
- Missing type declaration file

Suggested Fixes:
1. Add missing import: import { X } from './module'
2. Install type definitions: npm install --save-dev @types/X
3. Declare global type: declare const X: Type
4. Check spelling and case sensitivity

Retry: After adding imports or type declarations
```

#### TS2322: Type 'X' is not assignable to type 'Y'
```
Error Pattern: Type mismatch, incompatible types
Root Causes:
- Incorrect return type annotation
- Wrong argument type passed to function
- Union type narrowing needed
- Missing null/undefined handling

Suggested Fixes:
1. Update type annotation to match actual type
2. Add type guard: if (typeof x === 'string')
3. Use type assertion (carefully): value as ExpectedType
4. Handle null/undefined: value ?? defaultValue

Retry: After fixing type annotations
```

#### TS2345: Argument of type 'X' is not assignable to parameter of type 'Y'
```
Error Pattern: Function argument type mismatch
Root Causes:
- Passing wrong type to function
- Missing required properties
- Incorrect generic type parameter
- Array/tuple type mismatch

Suggested Fixes:
1. Verify function signature and arguments
2. Add missing object properties
3. Specify correct generic type: fn<Type>(arg)
4. Convert type if necessary: Array.from(value)

Retry: After fixing function arguments
```

#### TS2339: Property 'X' does not exist on type 'Y'
```
Error Pattern: Undefined property access
Root Causes:
- Property not defined in interface/type
- Optional property accessed without check
- Type inference failure
- Accessing property on wrong type

Suggested Fixes:
1. Add property to interface/type definition
2. Use optional chaining: obj.prop?.value
3. Add type guard to narrow type
4. Use type assertion if absolutely certain

Retry: After updating type definitions
```

#### TS2571: Object is of type 'unknown'
```
Error Pattern: Cannot operate on unknown type
Root Causes:
- Untyped catch clause: catch (error)
- Untyped JSON.parse result
- Type narrowing required
- Missing type annotation

Suggested Fixes:
1. Add type guard before using value
2. Type catch clause: catch (error: Error)
3. Create type predicate function
4. Add explicit type annotation

Retry: After adding type guards
```

#### TS7006: Parameter 'X' implicitly has an 'any' type
```
Error Pattern: Implicit any in strict mode
Root Causes:
- Missing parameter type annotation
- Callback function without types
- Array method without explicit types
- Event handler parameter untyped

Suggested Fixes:
1. Add explicit type: function fn(x: Type)
2. Type callback: array.map((item: Type) => ...)
3. Use typed event: (e: React.MouseEvent) => {}
4. Infer from context or add explicit type

Retry: After adding type annotations
```

## Retry Logic

```pseudo
attempt = 0
max_attempts = 3
previous_error_count = infinity

while attempt < max_attempts:
    result = run_type_check()
    current_error_count = count_errors(result)

    if result.success:
        report_success()
        return PASS

    attempt += 1

    # Check if making progress
    if current_error_count >= previous_error_count:
        escalate_to_user("No progress on type errors")
        return FAIL

    previous_error_count = current_error_count

    if attempt < max_attempts:
        categorize_errors(result.stderr)
        suggest_fixes_by_category()

        if auto_fixable_errors_exist():
            apply_auto_fixes()  # Add missing imports, basic type annotations
        else:
            prompt_user_for_fix()
            wait_for_user_confirmation()
    else:
        report_failure()
        trigger_rollback()
        return FAIL
```

## Auto-Fixable Type Errors

Some type errors can be automatically resolved:

1. **Missing Imports**: Add import statements for known types
2. **Basic Type Annotations**: Add explicit types where inference failed
3. **Null Checks**: Add optional chaining or null checks
4. **Type Declarations**: Generate basic type declaration files

**Caution**: Always verify auto-fixes maintain code correctness.

## Blocking Behavior

**This gate is BLOCKING**

- Runs only AFTER Gate 1 (Build Verification) passes
- If type check fails after 3 attempts: HALT execution
- Do NOT proceed to Gate 3 (Linting)
- Do NOT proceed to Gate 4 (Tests)
- Trigger rollback procedure

## Success Reporting

```markdown
### Type Checking: ✅ PASS

- Type Checker: TypeScript [version]
- Configuration: tsconfig.json (strict: true/false)
- Files Checked: [count]
- Type Check Time: [X.X seconds]
- Warnings: [count if any]
```

## Failure Reporting

```markdown
### Type Checking: ❌ FAIL

- Type Checker: TypeScript [version]
- Attempt: [X/3]
- Total Type Errors: [count]
- Exit Code: [code]

**Error Breakdown**:
- TS2304 (Cannot find name): [count]
- TS2322 (Type not assignable): [count]
- TS2345 (Argument type mismatch): [count]
- TS2339 (Property does not exist): [count]
- Other errors: [count]

**Top 5 Files with Errors**:
1. [file path]: [error count]
2. [file path]: [error count]
3. [file path]: [error count]
4. [file path]: [error count]
5. [file path]: [error count]

**Sample Errors** (first 10):
```
[Error output with file:line:col and message]
```

**Suggested Fixes**:
[Category-specific actionable recommendations]

**Next Steps**:
1. Fix type errors in [highest priority file]
2. Add missing type declarations
3. Re-run type check
```

## Integration with Quality Gate Sequence

This is **Gate 2** in the quality gate sequence:

```
Gate 1: Build Verification → BLOCKING ✅ (prerequisite)
Gate 2: Type Checking (THIS GATE) → BLOCKING
Gate 3: Linting → HIGH PRIORITY
Gate 4: Test Execution → BLOCKING
Gate 5: Coverage Validation → RECOMMENDED
Gate 6: Security Scan (Quick) → RECOMMENDED
```

**Sequential Execution**: Runs after Gate 1 passes, must complete successfully before Gate 3.

## Special Considerations

### Strict Mode vs Non-Strict
- **Strict Mode** (`"strict": true`): More type errors, higher quality
- **Non-Strict**: More permissive, easier to pass
- Recommendation: Enable strict mode for new projects

### Project References
- For monorepos with TypeScript project references
- Verify composite builds: `tsc --build --verbose`
- Check dependency order in type checking

### Type Declaration Files
- Ensure all `.d.ts` files are included
- Verify `@types/*` packages are installed
- Check `types` and `typeRoots` in tsconfig.json

### Performance Optimization
- Use incremental compilation: `"incremental": true`
- Enable build info caching
- Type check only changed files in watch mode
- Baseline type check time: Record on first successful run

### Excluding Files
- Use `exclude` in tsconfig.json for generated files
- Skip type checking for vendored/third-party code
- Document any exclusions in report

## Related Quality Gates

- **Build Verification (Gate 1)**: Must pass before type checking runs
- **Linting (Gate 3)**: May catch additional type-related style issues
- **Test Execution (Gate 4)**: Runtime verification after type safety confirmed
