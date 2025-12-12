# Error Handling: Timeout Handling

Handle long-running operations that exceed expected duration or configured timeouts.

## When to Use

**Triggers**:
- Command execution exceeds timeout threshold
- User doesn't respond to prompts within timeout period
- Build/test process hangs or runs indefinitely
- Network operations take too long
- Background processes don't complete

**Commands Using This**: 4 commands (`test`, `review`, `deploy`, `optimize`)

---

## Timeout Types

### 1. Command Execution Timeout

**For CLI tools, builds, tests**:

```bash
# Default timeouts by operation type
TIMEOUT_BUILD=600       # 10 minutes
TIMEOUT_TEST=900        # 15 minutes
TIMEOUT_LINT=300        # 5 minutes
TIMEOUT_DEPLOY=1200     # 20 minutes
TIMEOUT_INSTALL=600     # 10 minutes
```

### 2. User Response Timeout

**For interactive questions**:

```bash
# User prompt timeouts
TIMEOUT_USER_RESPONSE=300     # 5 minutes
TIMEOUT_USER_CRITICAL=600     # 10 minutes (for important decisions)
TIMEOUT_USER_INFO=120         # 2 minutes (for informational prompts)
```

### 3. Background Process Timeout

**For spawned specialists or background jobs**:

```bash
# Specialist/background job timeouts
TIMEOUT_SPECIALIST=1800       # 30 minutes
TIMEOUT_BACKGROUND_JOB=600    # 10 minutes
```

### 4. Network Operation Timeout

**For GitHub API, package downloads**:

```bash
# Network operation timeouts
TIMEOUT_NETWORK_REQUEST=60    # 1 minute
TIMEOUT_DOWNLOAD=300          # 5 minutes
TIMEOUT_GH_API=30             # 30 seconds
```

---

## Detection Patterns

### Pattern 1: Using `timeout` Command

```bash
# Run command with timeout
timeout $TIMEOUT_BUILD npm run build

EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
  echo "❌ TIMEOUT: Build exceeded ${TIMEOUT_BUILD}s"
  handle_build_timeout
elif [ $EXIT_CODE -eq 137 ]; then
  echo "❌ KILLED: Build was forcefully terminated"
  handle_build_killed
fi
```

**Exit codes**:
- `124`: Timeout (command exceeded time limit)
- `137`: Killed with SIGKILL (timeout with --kill-after)

### Pattern 2: Using `read` with Timeout

```bash
# Prompt user with timeout
echo "How should I proceed? (A/B/C):"

if ! read -t $TIMEOUT_USER_RESPONSE USER_RESPONSE; then
  echo ""
  echo "⏱️ No response received within ${TIMEOUT_USER_RESPONSE}s"
  handle_user_timeout
fi
```

### Pattern 3: Background Process Monitoring

```bash
# Start background process
long_running_task &
TASK_PID=$!

# Monitor with timeout
ELAPSED=0
while kill -0 "$TASK_PID" 2>/dev/null; do
  sleep 10
  ELAPSED=$((ELAPSED + 10))

  if [ $ELAPSED -ge $TIMEOUT_BACKGROUND_JOB ]; then
    echo "⏱️ Background task exceeded ${TIMEOUT_BACKGROUND_JOB}s"
    kill -TERM "$TASK_PID"
    sleep 5
    kill -KILL "$TASK_PID" 2>/dev/null || true
    handle_background_timeout
    break
  fi

  # Progress indicator
  if [ $((ELAPSED % 60)) -eq 0 ]; then
    echo "Still running... (${ELAPSED}s elapsed)"
  fi
done
```

### Pattern 4: Detect Hanging Process

```bash
# Check if process is making progress
check_progress() {
  local log_file="$1"
  local last_size=$(stat -f%z "$log_file" 2>/dev/null || echo 0)

  sleep 30

  local current_size=$(stat -f%z "$log_file" 2>/dev/null || echo 0)

  if [ "$current_size" -eq "$last_size" ]; then
    echo "⚠️ No progress detected in 30s (log size unchanged)"
    return 1
  fi

  return 0
}

# Usage
npm test > test.log 2>&1 &
TEST_PID=$!

if ! check_progress "test.log"; then
  echo "Tests appear to be hanging"
  kill -TERM $TEST_PID
fi
```

---

## User Messages

### Build/Test Timeout

```markdown
⏱️ **Operation Timeout**

The build/test process exceeded the timeout limit.

**Operation**: [BUILD/TEST/LINT]
**Timeout**: [TIMEOUT_VALUE]s ([X] minutes)
**Actual Duration**: [ELAPSED]s ([Y] minutes)

**Possible causes**:
- Infinite loop in code
- Extremely large test suite
- Slow CI/CD environment
- Network issues during dependency download
- Resource constraints (CPU/memory)

**Options**:
A) Retry with extended timeout (add [X] minutes)
B) Run subset only (e.g., changed files only)
C) Skip this step (not recommended)
D) Investigate and fix (I'll help diagnose the issue)
E) Abort workflow

Please select an option (A/B/C/D/E):
```

### User Response Timeout

```markdown
⏱️ **No Response Received**

I asked for your input but didn't receive a response within [TIMEOUT]s.

**Original Question**:
[QUESTION_TEXT]

**Defaulting to**: [DEFAULT_ACTION]

**Options**:
A) Use default action (continue)
B) Let me answer now (restart question)
C) Abort workflow

Please select an option (A/B/C):
```

### Network Timeout

```markdown
⏱️ **Network Operation Timeout**

A network request timed out.

**Operation**: [GH_PR_LIST / NPM_INSTALL / etc.]
**Timeout**: [TIMEOUT]s
**Endpoint**: [URL or service]

**Possible causes**:
- Slow internet connection
- Service unavailable/down
- Firewall/proxy blocking request
- VPN issues

**Options**:
A) Retry with longer timeout
B) Skip this network operation
C) Check connection and retry
D) Abort workflow

Please select an option (A/B/C/D):
```

### Specialist Timeout

```markdown
⏱️ **Specialist Agent Timeout**

A specialist agent exceeded the expected completion time.

**Specialist**: [SPECIALIST_NAME]
**Timeout**: [TIMEOUT]s ([X] minutes)
**Task**: [SPECIALIST_TASK]

**What happened**:
The specialist was working on [TASK] but hasn't completed within
the expected timeframe.

**Options**:
A) Wait longer (extend timeout by [X] minutes)
B) Terminate specialist and continue without
C) Investigate specialist logs
D) Abort entire workflow

Please select an option (A/B/C/D):
```

---

## Recovery Strategies

### Strategy 1: Automatic Retry with Increased Timeout

```bash
retry_with_increased_timeout() {
  local command="$1"
  local initial_timeout="$2"
  local max_retries=3
  local retry=1

  local current_timeout=$initial_timeout

  while [ $retry -le $max_retries ]; do
    echo "Attempt $retry/$max_retries with ${current_timeout}s timeout..."

    if timeout $current_timeout bash -c "$command"; then
      echo "✅ Command succeeded on attempt $retry"
      return 0
    fi

    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
      echo "⏱️ Timeout on attempt $retry"

      # Increase timeout by 50% each retry
      current_timeout=$((current_timeout * 3 / 2))

      if [ $retry -lt $max_retries ]; then
        echo "Retrying with increased timeout: ${current_timeout}s"
      fi
    else
      echo "❌ Command failed with exit code $EXIT_CODE (not a timeout)"
      return $EXIT_CODE
    fi

    retry=$((retry + 1))
  done

  echo "❌ Command failed after $max_retries attempts"
  return 124
}

# Usage
retry_with_increased_timeout "npm test" $TIMEOUT_TEST
```

### Strategy 2: Run Subset of Operation

For tests or builds:

```bash
# If full test suite times out, run subset
echo "⏱️ Full test suite timed out. Running subset..."

# Option A: Only changed files
npm test -- --changedSince=HEAD~1

# Option B: Specific test suite
npm test -- src/__tests__/critical

# Option C: Parallel execution
npm test -- --maxWorkers=4

# Option D: Fail fast
npm test -- --bail --maxWorkers=2
```

### Strategy 3: Graceful Degradation

```bash
# If operation times out, continue with warning
if ! timeout $TIMEOUT_BUILD npm run build; then
  echo "⚠️ Build timed out, but continuing workflow..."
  echo "NOTE: Build verification incomplete. Manual review required."

  # Mark in TodoWrite
  # Add to warnings list
  BUILD_TIMED_OUT=true
else
  BUILD_TIMED_OUT=false
fi

# Continue workflow, but note the timeout in summary
```

### Strategy 4: Investigate Hanging Process

```bash
investigate_hanging_process() {
  local pid="$1"
  local process_name="$2"

  echo "🔍 Investigating hanging process: $process_name (PID: $pid)"

  # Check if process is alive
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Process is no longer running"
    return 1
  fi

  # Get process info
  echo "Process info:"
  ps -p "$pid" -o pid,ppid,cpu,mem,etime,command

  # Check CPU usage
  CPU_USAGE=$(ps -p "$pid" -o %cpu= | tr -d ' ')
  if (( $(echo "$CPU_USAGE < 1" | bc -l) )); then
    echo "⚠️ Process is using <1% CPU - likely hanging or waiting"
  fi

  # Check what it's doing (macOS)
  echo ""
  echo "Process stack trace:"
  sample "$pid" 1 2>/dev/null || echo "Unable to get stack trace"

  # Check open files/network connections
  echo ""
  echo "Open files and connections:"
  lsof -p "$pid" 2>/dev/null | head -20

  echo ""
  echo "**Recommendation**: Process appears to be [hung/active/waiting]"
}

# Usage
if timeout $TIMEOUT_TEST npm test; then
  echo "✅ Tests passed"
else
  TEST_PID=$(pgrep -f "npm test")
  if [ -n "$TEST_PID" ]; then
    investigate_hanging_process "$TEST_PID" "npm test"
  fi
fi
```

### Strategy 5: Default User Response

```bash
# For non-critical prompts, use sensible defaults
prompt_with_default() {
  local question="$1"
  local default="$2"
  local timeout="$3"

  echo "$question"
  echo "(Default: $default in ${timeout}s)"

  if read -t "$timeout" USER_RESPONSE; then
    echo "$USER_RESPONSE"
  else
    echo ""
    echo "⏱️ Timeout - using default: $default"
    echo "$default"
  fi
}

# Usage
RESPONSE=$(prompt_with_default "Continue? (yes/no)" "yes" 60)
```

---

## Exit Codes and Cleanup

### Exit Codes

```bash
# Timeout exit codes
EXIT_CODE_TIMEOUT_BUILD=40
EXIT_CODE_TIMEOUT_TEST=41
EXIT_CODE_TIMEOUT_USER=42
EXIT_CODE_TIMEOUT_NETWORK=43
EXIT_CODE_TIMEOUT_SPECIALIST=44
EXIT_CODE_TIMEOUT_GENERIC=45
```

### Cleanup After Timeout

```bash
cleanup_after_timeout() {
  local operation="$1"
  local pid="$2"

  echo "🧹 Cleaning up after $operation timeout..."

  # Try graceful termination first
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    echo "Sending SIGTERM to PID $pid..."
    kill -TERM "$pid"

    # Wait up to 10 seconds for graceful shutdown
    local waited=0
    while kill -0 "$pid" 2>/dev/null && [ $waited -lt 10 ]; do
      sleep 1
      waited=$((waited + 1))
    done

    # Force kill if still alive
    if kill -0 "$pid" 2>/dev/null; then
      echo "Process didn't terminate gracefully. Forcing..."
      kill -KILL "$pid" 2>/dev/null || true
    fi
  fi

  # Operation-specific cleanup
  case "$operation" in
    "build")
      echo "Removing partial build artifacts..."
      rm -rf .next dist build 2>/dev/null || true
      ;;
    "test")
      echo "Removing partial test reports..."
      rm -rf coverage .coverage htmlcov 2>/dev/null || true
      ;;
    "install")
      echo "Cleaning package manager state..."
      rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null || true
      ;;
  esac

  # Log timeout
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | TIMEOUT | $operation | PID:$pid" \
    >> .agency/logs/timeouts.log

  echo "✅ Cleanup complete"
}
```

---

## Timeout Configuration

### Dynamic Timeout Calculation

```bash
# Calculate timeout based on project size
calculate_timeout() {
  local operation="$1"
  local base_timeout="$2"

  # Get project size metrics
  local file_count=$(find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | wc -l)
  local test_count=$(find . -type f -name "*.test.*" -o -name "*.spec.*" | wc -l)

  # Adjust based on size
  local multiplier=1

  if [ "$file_count" -gt 1000 ]; then
    multiplier=3
  elif [ "$file_count" -gt 500 ]; then
    multiplier=2
  elif [ "$file_count" -gt 100 ]; then
    multiplier=1.5
  fi

  # Calculate final timeout
  local final_timeout=$(echo "$base_timeout * $multiplier" | bc)

  echo "${final_timeout%.*}"  # Return as integer
}

# Usage
TIMEOUT_BUILD=$(calculate_timeout "build" 600)
echo "Calculated build timeout: ${TIMEOUT_BUILD}s based on project size"
```

### User-Configurable Timeouts

```bash
# Check for user overrides in settings
load_timeout_settings() {
  local settings_file=".agency/settings.json"

  if [ -f "$settings_file" ]; then
    # Read custom timeouts (requires jq)
    TIMEOUT_BUILD=$(jq -r '.timeouts.build // 600' "$settings_file")
    TIMEOUT_TEST=$(jq -r '.timeouts.test // 900' "$settings_file")
    TIMEOUT_DEPLOY=$(jq -r '.timeouts.deploy // 1200' "$settings_file")

    echo "Loaded custom timeout settings"
  else
    # Use defaults
    TIMEOUT_BUILD=600
    TIMEOUT_TEST=900
    TIMEOUT_DEPLOY=1200
  fi
}
```

---

## Progress Indicators

### For Long-Running Operations

```bash
# Show progress during long operations
run_with_progress() {
  local command="$1"
  local timeout="$2"
  local description="$3"

  echo "Starting: $description"
  echo "Timeout: ${timeout}s"
  echo ""

  # Run in background
  eval "$command" &
  local pid=$!

  # Show progress
  local elapsed=0
  local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local spinner_idx=0

  while kill -0 $pid 2>/dev/null && [ $elapsed -lt $timeout ]; do
    # Update progress
    local percent=$((elapsed * 100 / timeout))
    printf "\r${spinner[$spinner_idx]} $description... ${elapsed}s / ${timeout}s (${percent}%%)"

    # Update spinner
    spinner_idx=$(( (spinner_idx + 1) % ${#spinner[@]} ))

    sleep 1
    elapsed=$((elapsed + 1))
  done

  # Check result
  if kill -0 $pid 2>/dev/null; then
    # Still running - timeout
    kill -TERM $pid
    echo ""
    echo "⏱️ Timeout after ${timeout}s"
    return 124
  else
    # Completed
    wait $pid
    local exit_code=$?
    echo ""
    if [ $exit_code -eq 0 ]; then
      echo "✅ Completed in ${elapsed}s"
    else
      echo "❌ Failed with exit code $exit_code after ${elapsed}s"
    fi
    return $exit_code
  fi
}

# Usage
run_with_progress "npm test" $TIMEOUT_TEST "Running test suite"
```

---

## Common Timeout Scenarios

### Scenario 1: Test Suite Timeout

**Cause**: Large test suite or slow tests
**Detection**: Tests exceed TIMEOUT_TEST
**Solution**:
- Run in parallel: `npm test -- --maxWorkers=4`
- Run subset: `npm test -- --changedSince=main`
- Increase timeout for CI environment

### Scenario 2: Build Timeout

**Cause**: Large project or slow build tools
**Detection**: Build exceeds TIMEOUT_BUILD
**Solution**:
- Enable caching: Next.js SWC, webpack cache
- Increase timeout
- Optimize build config
- Use faster build tools (Vite vs webpack)

### Scenario 3: Deployment Timeout

**Cause**: Slow deployment platform or large assets
**Detection**: Deploy exceeds TIMEOUT_DEPLOY
**Solution**:
- Deploy in stages
- Increase timeout
- Optimize asset sizes
- Use CDN for static assets

### Scenario 4: Network Request Timeout

**Cause**: Slow API, network issues, or large downloads
**Detection**: gh, npm, or API calls timeout
**Solution**:
- Retry with backoff
- Use alternative endpoints
- Check network connectivity
- Increase timeout for large operations

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `ask-user-retry.md` - For retry/skip/abort after timeout
- `tool-execution-failure.md` - Timeouts are a type of tool failure
- `user-cancellation.md` - User may cancel during timeout recovery

**Often used with**:
- `quality-gates/test-execution.md` - For test timeouts
- `quality-gates/build-verification.md` - For build timeouts

---

## Testing Timeout Handling

### Test Case 1: Simulate Slow Build

```bash
# Add artificial delay to build
echo "sleep 300" >> build-script.sh

# Run with short timeout
TIMEOUT_BUILD=10 /agency:implement "Add feature"

# Expected: Detects timeout, offers retry/skip/abort
```

### Test Case 2: User Response Timeout

```bash
# Run command that prompts
/agency:work "Task requiring input"

# Don't respond to prompt

# Expected: After timeout, uses default or prompts again
```

### Test Case 3: Hanging Test

```bash
# Create hanging test
echo "test('hangs', () => { while(true) {} });" >> src/test.spec.ts

# Run tests
/agency:test "Run all tests"

# Expected: Detects timeout, investigates, offers to terminate
```

---

## Success Metrics

**Timeout handling is successful when**:
- Timeouts detected promptly
- Clear explanation of what timed out and why
- Appropriate recovery options offered
- Hung processes terminated cleanly
- Partial work cleaned up properly
- User kept informed of progress

**Failure indicators**:
- Silent hangs (no timeout detection)
- Processes not terminated
- No cleanup after timeout
- User left waiting without feedback
- Unclear what happened or how to proceed
