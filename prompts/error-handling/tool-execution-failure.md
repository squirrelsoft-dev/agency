# Error Handling: Tool Execution Failure

Handle failures when CLI tools (gh, npm, tsc, pytest, etc.) fail to execute or return errors.

## When to Use

**Triggers**:
- Command not found (tool not installed)
- Command returns non-zero exit code
- Command times out
- Command produces unexpected output
- Permission denied errors
- Network/API failures (for tools like gh)

**Commands Using This**: All 14 commands

---

## Detection Patterns

### Pattern 1: Command Not Found

```bash
# Check if command exists
if ! command -v gh &> /dev/null; then
  echo "TOOL_NOT_FOUND: gh"
  exit 127
fi
```

**Exit code 127**: Command not found

### Pattern 2: Non-Zero Exit Code

```bash
# Run command and capture exit code
npm run build
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "BUILD_FAILED: Exit code $BUILD_EXIT_CODE"
fi
```

**Common exit codes**:
- `1`: General error
- `2`: Misuse of command
- `126`: Command cannot execute
- `127`: Command not found
- `130`: Terminated by Ctrl+C
- `137`: Killed by SIGKILL

### Pattern 3: Timeout Detection

```bash
# Run with timeout
timeout 300 npm test || {
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    echo "TIMEOUT: Command exceeded 300 seconds"
  fi
}
```

**Exit code 124**: Timeout

### Pattern 4: Permission Denied

```bash
# Check for permission errors
npm install 2>&1 | grep -i "permission denied" && {
  echo "PERMISSION_ERROR"
}
```

### Pattern 5: Network Failures

```bash
# For network-dependent tools
gh pr list 2>&1 | grep -i "could not resolve host\|network\|connection" && {
  echo "NETWORK_ERROR"
}
```

---

## Error Messages by Tool Type

### Build Tools (npm, webpack, vite, tsc)

**Error Detection**:
```bash
npm run build 2>&1 | tee build.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  ERROR_COUNT=$(grep -i "error" build.log | wc -l)
  FIRST_ERROR=$(grep -i "error" build.log | head -1)
fi
```

**User Message**:
```markdown
❌ Build Failed

The build process encountered errors:

**Exit Code**: [EXIT_CODE]
**Error Count**: [ERROR_COUNT]
**First Error**: [FIRST_ERROR]

Common causes:
- TypeScript type errors
- Missing dependencies
- Syntax errors in code
- Configuration issues

**Next Steps**:
1. Review the errors above
2. Would you like me to attempt to fix these errors?
   - Yes: I'll analyze and fix the issues
   - No: I'll skip the build step
   - Abort: Stop the entire workflow
```

### Type Checkers (tsc, mypy, pyright)

**Error Detection**:
```bash
npx tsc --noEmit 2>&1 | tee type-check.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  TYPE_ERRORS=$(grep -i "error TS" type-check.log | wc -l)
  CRITICAL_ERRORS=$(grep -i "error TS" type-check.log | head -5)
fi
```

**User Message**:
```markdown
❌ Type Check Failed

TypeScript found type errors:

**Total Errors**: [TYPE_ERRORS]
**Critical Errors**:
[CRITICAL_ERRORS]

**Options**:
A) Fix type errors automatically (I'll analyze and attempt fixes)
B) Add @ts-ignore comments (not recommended, but will unblock)
C) Skip type checking for now (risky)
D) Abort workflow

Please select an option (A/B/C/D):
```

### Linters (eslint, ruff, pylint)

**Error Detection**:
```bash
npm run lint 2>&1 | tee lint.log
LINT_EXIT_CODE=${PIPESTATUS[0]}

if [ $LINT_EXIT_CODE -eq 1 ]; then
  # Errors found
  ERROR_COUNT=$(grep -c "error" lint.log)
  WARNING_COUNT=$(grep -c "warning" lint.log)
fi
```

**User Message**:
```markdown
⚠️ Linting Issues Found

**Errors**: [ERROR_COUNT]
**Warnings**: [WARNING_COUNT]

**Policy**: Errors must be fixed, warnings are acceptable.

**Options**:
A) Auto-fix with `npm run lint -- --fix`
B) Review errors manually and proceed
C) Skip linting (not recommended)

Please select an option (A/B/C):
```

### Test Runners (jest, vitest, pytest, playwright)

**Error Detection**:
```bash
npm test 2>&1 | tee test.log
TEST_EXIT_CODE=${PIPESTATUS[0]}

if [ $TEST_EXIT_CODE -ne 0 ]; then
  FAILED_TESTS=$(grep -i "failed" test.log | grep -oP '\d+(?= failed)')
  FAILED_TEST_NAMES=$(grep -i "FAIL" test.log | head -10)
fi
```

**User Message**:
```markdown
❌ Tests Failed

**Exit Code**: [TEST_EXIT_CODE]
**Failed Tests**: [FAILED_TESTS]

**Failed Test Details**:
[FAILED_TEST_NAMES]

**Analysis**:
This could indicate:
- Regression: New changes broke existing functionality
- Test bug: Tests need updating
- Expected: Planned breaking change

**Options**:
A) Review failures and fix code
B) Update tests if they're outdated
C) Skip tests and continue (not recommended)
D) Abort workflow

Please select an option (A/B/C/D):
```

### GitHub CLI (gh)

**Error Detection**:
```bash
gh pr list 2>&1 | tee gh.log
GH_EXIT_CODE=${PIPESTATUS[0]}

if [ $GH_EXIT_CODE -ne 0 ]; then
  if grep -qi "not logged in" gh.log; then
    ERROR_TYPE="AUTH"
  elif grep -qi "not found\|404" gh.log; then
    ERROR_TYPE="NOT_FOUND"
  elif grep -qi "network\|connection" gh.log; then
    ERROR_TYPE="NETWORK"
  fi
fi
```

**User Message (Auth Error)**:
```markdown
❌ GitHub Authentication Required

The GitHub CLI is not authenticated.

**To fix**:
1. Run: `gh auth login`
2. Follow the prompts to authenticate
3. Then retry this command

**Options**:
A) I'll wait while you authenticate (then I'll retry)
B) Skip GitHub operations for now
C) Abort workflow

Please select an option (A/B/C):
```

**User Message (Network Error)**:
```markdown
❌ Network Connection Failed

Unable to connect to GitHub API.

**Possible causes**:
- No internet connection
- GitHub is down
- Firewall/proxy blocking requests
- VPN issues

**Options**:
A) Retry (check connection and try again)
B) Skip GitHub operations for now
C) Abort workflow

Please select an option (A/B/C):
```

### Package Managers (npm, pip, composer)

**Error Detection**:
```bash
npm install 2>&1 | tee install.log
INSTALL_EXIT_CODE=${PIPESTATUS[0]}

if [ $INSTALL_EXIT_CODE -ne 0 ]; then
  if grep -qi "permission denied\|EACCES" install.log; then
    ERROR_TYPE="PERMISSION"
  elif grep -qi "network\|ENOTFOUND\|timeout" install.log; then
    ERROR_TYPE="NETWORK"
  elif grep -qi "version\|could not resolve" install.log; then
    ERROR_TYPE="VERSION"
  fi
fi
```

**User Message (Permission Error)**:
```markdown
❌ Permission Denied During Installation

**Error**: Cannot write to node_modules or package-lock.json

**Common causes**:
- Files owned by root (used sudo in the past)
- Directory permissions incorrect

**Recommended fix**:
```bash
# Fix ownership (macOS/Linux)
sudo chown -R $(whoami) node_modules package-lock.json

# Or use npm's fix
npm cache clean --force
```

**Options**:
A) I'll wait while you fix permissions (then retry)
B) Skip installation
C) Abort workflow

Please select an option (A/B/C):
```

---

## Recovery Strategies

### Strategy 1: Automatic Retry with Backoff

For transient failures (network, rate limiting):

```bash
retry_command() {
  local command="$1"
  local max_attempts=3
  local attempt=1
  local delay=5

  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."

    if eval "$command"; then
      echo "✅ Command succeeded"
      return 0
    fi

    if [ $attempt -lt $max_attempts ]; then
      echo "Failed. Retrying in ${delay}s..."
      sleep $delay
      delay=$((delay * 2))  # Exponential backoff
    fi

    attempt=$((attempt + 1))
  done

  echo "❌ Command failed after $max_attempts attempts"
  return 1
}

# Usage
retry_command "gh pr list"
```

### Strategy 2: Fallback to Alternative Tool

If primary tool fails, try alternative:

```bash
# Try gh first, fall back to git commands
if ! gh pr create --title "Feature" --body "Description"; then
  echo "gh failed, using git + GitHub API..."
  git push origin feature-branch
  # Use curl with GitHub API as fallback
fi
```

### Strategy 3: Graceful Degradation

Continue with reduced functionality:

```bash
# Try to run tests
if ! npm test; then
  echo "⚠️ Tests failed, but continuing with build..."
  echo "NOTE: Tests must pass before PR is merged."
  # Continue workflow but mark as incomplete
fi
```

### Strategy 4: Ask User for Decision

Use `AskUserQuestion` for critical failures:

```markdown
**The build command failed. How should I proceed?**

**Options**:
A) Analyze and fix the errors (I'll attempt automatic fixes)
B) Skip the build step (risky - may cause downstream issues)
C) Abort the entire workflow
D) Let me fix it manually (you'll resolve, then I'll continue)

**Recommendation**: Option A

Please select an option (A/B/C/D):
```

### Strategy 5: Tool Installation Detection

If tool is missing, offer to help install:

```markdown
❌ Required tool not found: `gh` (GitHub CLI)

**This tool is required for**:
- Creating pull requests
- Fetching issue details
- Checking PR status

**Installation instructions**:

macOS:
```bash
brew install gh
```

Linux:
```bash
# Debian/Ubuntu
sudo apt install gh

# Fedora
sudo dnf install gh
```

Windows:
```bash
winget install GitHub.cli
```

**Options**:
A) I'll wait while you install it (then retry)
B) Skip GitHub operations
C) Abort workflow

Please select an option (A/B/C):
```

---

## Exit Codes and Cleanup

### Exit Code Standards

```bash
# Tool execution failure exit codes
EXIT_CODE_TOOL_NOT_FOUND=20
EXIT_CODE_TOOL_FAILED=21
EXIT_CODE_TOOL_TIMEOUT=22
EXIT_CODE_TOOL_PERMISSION=23
EXIT_CODE_TOOL_NETWORK=24
```

### Cleanup Procedures

**Before exiting**:

1. **Save error logs**:
```bash
# Create error report
mkdir -p .agency/logs/tool-failures
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ERROR_LOG=".agency/logs/tool-failures/${TOOL_NAME}-${TIMESTAMP}.log"

cat > "$ERROR_LOG" <<EOF
Tool: $TOOL_NAME
Command: $COMMAND
Exit Code: $EXIT_CODE
Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Working Directory: $(pwd)

=== Error Output ===
$ERROR_OUTPUT

=== Environment ===
PATH=$PATH
NODE_VERSION=$(node --version 2>/dev/null || echo "N/A")
NPM_VERSION=$(npm --version 2>/dev/null || echo "N/A")
EOF

echo "Error log saved to: $ERROR_LOG"
```

2. **Clean up partial artifacts**:
```bash
# Remove incomplete build artifacts
if [ "$TOOL_NAME" = "npm run build" ]; then
  rm -rf .next dist build 2>/dev/null || true
fi

# Remove lock files if install failed
if [ "$TOOL_NAME" = "npm install" ] && [ $EXIT_CODE -ne 0 ]; then
  rm -f package-lock.json 2>/dev/null || true
fi
```

3. **Update TodoWrite**:
```markdown
Update TodoWrite to mark the failed task:

- [❌] Build project - **FAILED**: [Error summary]
  - Error: [First error message]
  - Exit code: [EXIT_CODE]
  - Action needed: [User decision or retry status]
```

4. **Exit with context**:
```bash
echo ""
echo "❌ Tool execution failed: $TOOL_NAME"
echo "See error log: $ERROR_LOG"
echo ""
exit $EXIT_CODE_TOOL_FAILED
```

---

## Preventive Measures

### Pre-Flight Checks

**Before running critical commands**:

```bash
# Check tool availability
check_tools() {
  local tools=("$@")
  local missing=()

  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      missing+=("$tool")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo "❌ Missing required tools: ${missing[*]}"
    return 1
  fi

  echo "✅ All required tools available"
  return 0
}

# Usage
check_tools npm node tsc gh || exit $EXIT_CODE_TOOL_NOT_FOUND
```

### Validate Tool Versions

```bash
# Check minimum versions
check_version() {
  local tool=$1
  local min_version=$2
  local current_version

  current_version=$($tool --version 2>&1 | grep -oP '\d+\.\d+\.\d+' | head -1)

  # Simple version comparison (use proper tool in production)
  if [ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]; then
    echo "❌ $tool version $current_version is below minimum $min_version"
    return 1
  fi

  echo "✅ $tool version $current_version meets minimum $min_version"
  return 0
}

# Usage
check_version node 18.0.0 || {
  echo "Please upgrade Node.js to at least v18.0.0"
  exit $EXIT_CODE_TOOL_FAILED
}
```

---

## Common Tool Failures

### npm/pnpm/yarn

**Failure**: `EACCES` permission denied
- **Cause**: Global install without sudo, or root-owned node_modules
- **Fix**: Change ownership, use nvm, or fix npm permissions

**Failure**: `ERESOLVE` dependency conflicts
- **Cause**: Incompatible dependency versions
- **Fix**: Use `--legacy-peer-deps` or update conflicting packages

**Failure**: `ENOTFOUND` registry error
- **Cause**: Network issue, registry down, or proxy issue
- **Fix**: Check network, try different registry, or retry

### TypeScript (tsc)

**Failure**: Type errors
- **Cause**: Type mismatches, missing types, or strict mode issues
- **Fix**: Fix types, add type annotations, or adjust tsconfig

**Failure**: `Cannot find module`
- **Cause**: Missing type declarations or incorrect paths
- **Fix**: Install `@types/*` packages or fix tsconfig paths

### ESLint

**Failure**: Parsing errors
- **Cause**: Invalid syntax or unsupported ECMAScript features
- **Fix**: Update parser, fix syntax, or adjust ESLint config

**Failure**: Max warnings exceeded
- **Cause**: Too many warnings with `--max-warnings 0`
- **Fix**: Fix warnings or adjust threshold

### Jest/Vitest

**Failure**: Test timeout
- **Cause**: Async test not completing or infinite loop
- **Fix**: Increase timeout or fix hanging test

**Failure**: Module not found in tests
- **Cause**: Jest config missing moduleNameMapper
- **Fix**: Update Jest config for path aliases

### GitHub CLI (gh)

**Failure**: Not authenticated
- **Cause**: No auth token or expired token
- **Fix**: Run `gh auth login`

**Failure**: Rate limited
- **Cause**: Too many API calls
- **Fix**: Wait and retry, or use authenticated requests

**Failure**: Repository not found
- **Cause**: Not in a git repo or no remote
- **Fix**: Initialize git, add remote, or specify repo

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `ask-user-retry.md` - For retry/skip/abort decisions
- `quality-gates/quality-gate-sequence.md` - For quality gate failures
- `error-handling/timeout-handling.md` - For timeout scenarios

**Often used with**:
- `error-handling/partial-failure-recovery.md` - When some tools succeed, others fail
- `reporting/summary-template.md` - Document tool failures in summary

---

## Testing Tool Failures

### Test Case 1: Missing Tool

```bash
# Temporarily hide tool
alias tsc='false'

# Run command
/agency:test "Run type check"

# Expected: Detects missing tool, offers installation help
```

### Test Case 2: Build Failure

```bash
# Introduce type error
echo "const x: string = 123;" >> src/index.ts

# Run command
/agency:implement "Add feature"

# Expected: Detects build failure, offers to fix
```

### Test Case 3: Network Failure

```bash
# Simulate network failure
alias gh='curl http://invalid-url'

# Run command
/agency:deploy "Deploy to staging"

# Expected: Detects network error, offers retry
```

---

## Success Metrics

**Tool execution handling is successful when**:
- Failures are detected immediately
- Clear, actionable error messages provided
- User is offered appropriate recovery options
- Workflow continues or exits gracefully
- Error logs are saved for debugging

**Failure indicators**:
- Silent failures (errors not caught)
- Cryptic error messages
- No recovery options offered
- Workflow continues with broken state
- No error logs or context saved
