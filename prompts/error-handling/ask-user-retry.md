# Error Handling: Ask User Retry

Standardized retry/skip/abort pattern using AskUserQuestion for interactive error recovery.

## When to Use

**Triggers**:
- Any recoverable error where user input is needed
- Tool execution failure that might succeed on retry
- Network/API errors that could be transient
- Build/test failures that user may want to fix
- Permission errors requiring user action
- Configuration issues needing user resolution

**Commands Using This**: 10 commands (all except `help`, `adr`, `plan`, and `document`)

---

## Standard Question Format

### Basic Retry/Skip/Abort

```markdown
**[Error Type] Detected**

[Brief description of what went wrong]

**Error Details**:
- Operation: [What was being attempted]
- Error: [Error message or description]
- Impact: [What this affects]

**Options**:
A) Retry (attempt the operation again)
B) Skip (continue without this operation)
C) Abort (stop the entire workflow)

**Recommendation**: [A/B/C] - [Why this is recommended]

Please select an option (A/B/C):
```

### Extended Options (with Fix)

```markdown
**[Error Type] Detected**

[Brief description of what went wrong]

**Error Details**:
- Operation: [What was being attempted]
- Error: [Error message or description]
- Likely Cause: [Why this happened]
- Impact: [What this affects]

**Options**:
A) Retry (attempt the operation again)
B) Fix and retry (I'll attempt to fix the issue, then retry)
C) Manual fix (you fix it, then I'll retry)
D) Skip (continue without this operation)
E) Abort (stop the entire workflow)

**Recommendation**: [A/B/C/D/E] - [Why this is recommended]

Please select an option (A/B/C/D/E):
```

---

## Response Handling

### Process User Response

```bash
ask_user_retry() {
  local error_type="$1"
  local operation="$2"
  local error_msg="$3"
  local recommendation="$4"

  # Show error and options
  cat <<EOF

⚠️ **$error_type Detected**

**Operation**: $operation
**Error**: $error_msg

**Options**:
A) Retry (attempt the operation again)
B) Skip (continue without this operation)
C) Abort (stop the entire workflow)

**Recommendation**: $recommendation

Please select an option (A/B/C):
EOF

  # Read user response with timeout
  local response
  if ! read -t 300 response; then
    echo ""
    echo "⏱️ No response received. Defaulting to: Abort"
    response="C"
  fi

  # Normalize response
  response=$(echo "$response" | tr '[:lower:]' '[:upper:]' | tr -d ' ')

  # Handle response
  case "$response" in
    A|RETRY)
      return 0  # Retry
      ;;
    B|SKIP)
      return 1  # Skip
      ;;
    C|ABORT)
      return 2  # Abort
      ;;
    *)
      echo "Invalid response. Please select A, B, or C."
      ask_user_retry "$error_type" "$operation" "$error_msg" "$recommendation"
      ;;
  esac
}

# Usage
if ! npm run build; then
  ask_user_retry "Build Failure" "npm run build" "Build script returned exit code 1" "B (Fix and retry)"

  case $? in
    0)
      echo "Retrying build..."
      npm run build || exit 1
      ;;
    1)
      echo "Skipping build..."
      BUILD_SKIPPED=true
      ;;
    2)
      echo "Aborting workflow..."
      exit 130
      ;;
  esac
fi
```

### Extended Response Handling (with Fix)

```bash
ask_user_retry_extended() {
  local error_type="$1"
  local operation="$2"
  local error_msg="$3"
  local can_auto_fix="$4"  # true/false

  local options="A) Retry
B) Skip
C) Abort"

  if [ "$can_auto_fix" = true ]; then
    options="A) Retry
B) Fix and retry (I'll attempt to fix)
C) Manual fix (you fix it, I'll wait)
D) Skip
E) Abort"
  fi

  cat <<EOF

⚠️ **$error_type**

**Operation**: $operation
**Error**: $error_msg

**Options**:
$options

Please select an option:
EOF

  local response
  read -t 300 response || response="E"  # Default to abort on timeout

  response=$(echo "$response" | tr '[:lower:]' '[:upper:]' | tr -d ' ')

  if [ "$can_auto_fix" = true ]; then
    case "$response" in
      A|RETRY) return 0 ;;
      B|FIX) return 3 ;;      # Auto-fix
      C|MANUAL) return 4 ;;   # Manual fix
      D|SKIP) return 1 ;;
      E|ABORT) return 2 ;;
      *)
        echo "Invalid response."
        ask_user_retry_extended "$error_type" "$operation" "$error_msg" "$can_auto_fix"
        ;;
    esac
  else
    case "$response" in
      A|RETRY) return 0 ;;
      B|SKIP) return 1 ;;
      C|ABORT) return 2 ;;
      *)
        echo "Invalid response."
        ask_user_retry_extended "$error_type" "$operation" "$error_msg" "false"
        ;;
    esac
  fi
}
```

---

## Common Scenarios

### Scenario 1: Build Failure

```bash
handle_build_failure() {
  local build_log="$1"

  # Extract error details
  local error_count=$(grep -c "error" "$build_log")
  local first_error=$(grep "error" "$build_log" | head -1)

  ask_user_retry_extended \
    "Build Failure" \
    "npm run build" \
    "$error_count error(s) found. First: $first_error" \
    true  # Can auto-fix

  case $? in
    0)  # Retry
      echo "Retrying build..."
      npm run build
      ;;
    3)  # Auto-fix
      echo "Analyzing build errors and attempting fixes..."
      auto_fix_build_errors "$build_log"
      echo "Retrying build after fixes..."
      npm run build
      ;;
    4)  # Manual fix
      echo "Please fix the build errors, then press Enter to continue..."
      read -r
      echo "Retrying build..."
      npm run build
      ;;
    1)  # Skip
      echo "⚠️ Skipping build verification"
      BUILD_SKIPPED=true
      ;;
    2)  # Abort
      cleanup_and_exit "User aborted due to build failure" 130
      ;;
  esac
}
```

### Scenario 2: Test Failure

```bash
handle_test_failure() {
  local failed_count="$1"
  local total_count="$2"

  ask_user_retry_extended \
    "Test Failure" \
    "npm test" \
    "$failed_count of $total_count tests failed" \
    true  # Can attempt to fix

  case $? in
    0)  # Retry
      echo "Retrying tests..."
      npm test
      ;;
    3)  # Auto-fix
      echo "Analyzing test failures..."
      # Attempt to update snapshots or fix obvious issues
      npm test -- -u  # Update snapshots
      ;;
    4)  # Manual fix
      echo "Please review and fix the failing tests."
      echo "Press Enter when ready to retry..."
      read -r
      npm test
      ;;
    1)  # Skip
      echo "⚠️ Skipping test verification (NOT recommended)"
      TESTS_SKIPPED=true
      ;;
    2)  # Abort
      cleanup_and_exit "User aborted due to test failures" 130
      ;;
  esac
}
```

### Scenario 3: Network/API Failure

```bash
handle_network_failure() {
  local operation="$1"
  local error_msg="$2"

  ask_user_retry \
    "Network Failure" \
    "$operation" \
    "$error_msg" \
    "A (Retry) - Network issues are often transient"

  case $? in
    0)  # Retry
      echo "Retrying after 5 seconds..."
      sleep 5
      eval "$operation"
      ;;
    1)  # Skip
      echo "⚠️ Skipping network operation"
      NETWORK_SKIPPED=true
      ;;
    2)  # Abort
      cleanup_and_exit "User aborted due to network failure" 130
      ;;
  esac
}
```

### Scenario 4: Permission Error

```bash
handle_permission_error() {
  local file="$1"
  local operation="$2"

  cat <<EOF

❌ **Permission Denied**

**File**: $file
**Operation**: $operation

**Common fixes**:
1. Change file permissions: \`chmod +w $file\`
2. Change ownership: \`sudo chown $(whoami) $file\`
3. Use sudo (not recommended): \`sudo $operation\`

**Options**:
A) I fixed it, retry now
B) Skip this file
C) Abort workflow

Please select an option (A/B/C):
EOF

  local response
  read -t 300 response || response="C"

  case "$response" in
    A|a)
      eval "$operation"
      ;;
    B|b)
      echo "⚠️ Skipping $file"
      ;;
    C|c)
      cleanup_and_exit "User aborted due to permission error" 130
      ;;
  esac
}
```

### Scenario 5: Configuration Error

```bash
handle_config_error() {
  local config_file="$1"
  local error_msg="$2"

  cat <<EOF

❌ **Configuration Error**

**File**: $config_file
**Error**: $error_msg

**Options**:
A) Fix automatically (I'll attempt to correct the config)
B) Open file for manual edit (I'll wait)
C) Use default configuration
D) Abort workflow

Please select an option (A/B/C/D):
EOF

  local response
  read -t 300 response || response="D"

  case "$response" in
    A|a)
      echo "Attempting automatic fix..."
      fix_config "$config_file" "$error_msg"
      ;;
    B|b)
      echo "Opening $config_file in editor..."
      ${EDITOR:-vim} "$config_file"
      echo "Press Enter when done editing..."
      read -r
      ;;
    C|c)
      echo "Using default configuration..."
      use_default_config "$config_file"
      ;;
    D|d)
      cleanup_and_exit "User aborted due to config error" 130
      ;;
  esac
}
```

---

## Retry Logic

### Simple Retry with Backoff

```bash
retry_with_backoff() {
  local command="$1"
  local max_attempts="${2:-3}"
  local initial_delay="${3:-5}"

  local attempt=1
  local delay=$initial_delay

  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."

    if eval "$command"; then
      echo "✅ Succeeded on attempt $attempt"
      return 0
    fi

    local exit_code=$?

    if [ $attempt -lt $max_attempts ]; then
      echo "❌ Failed with exit code $exit_code"

      # Ask user before retrying
      ask_user_retry \
        "Operation Failed" \
        "$command" \
        "Exit code: $exit_code" \
        "A (Retry)"

      case $? in
        0)  # Retry
          echo "Retrying in ${delay}s..."
          sleep $delay
          delay=$((delay * 2))  # Exponential backoff
          ;;
        1)  # Skip
          echo "Skipping after $attempt attempts"
          return 1
          ;;
        2)  # Abort
          cleanup_and_exit "User aborted during retry" 130
          ;;
      esac
    fi

    attempt=$((attempt + 1))
  done

  echo "❌ Failed after $max_attempts attempts"
  return $exit_code
}

# Usage
retry_with_backoff "npm install" 3 5
```

### Conditional Retry

```bash
conditional_retry() {
  local command="$1"
  local error_pattern="$2"  # Only retry if error matches pattern

  local output
  output=$(eval "$command" 2>&1)
  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    # Check if error matches retry-worthy pattern
    if echo "$output" | grep -qi "$error_pattern"; then
      echo "Detected retry-worthy error: $error_pattern"

      ask_user_retry \
        "Transient Error" \
        "$command" \
        "$(echo "$output" | grep -i "$error_pattern" | head -1)" \
        "A (Retry) - This error is often transient"

      case $? in
        0)  # Retry
          eval "$command"
          ;;
        1)  # Skip
          return 1
          ;;
        2)  # Abort
          cleanup_and_exit "User aborted" 130
          ;;
      esac
    else
      # Non-transient error, just ask
      ask_user_retry \
        "Command Failed" \
        "$command" \
        "$output" \
        "B (Skip) - This error may require investigation"

      case $? in
        0) eval "$command" ;;
        1) return 1 ;;
        2) cleanup_and_exit "User aborted" 130 ;;
      esac
    fi
  fi

  return 0
}

# Usage
conditional_retry "gh pr list" "network\|timeout\|rate limit"
```

---

## Response Defaults

### Timeout-Based Defaults

```bash
# Critical operations: default to Abort
ask_user_retry_critical() {
  local response

  echo "This is a critical operation. No response will abort."

  if ! read -t 300 response; then
    echo ""
    echo "⏱️ Timeout - defaulting to Abort (critical operation)"
    return 2  # Abort
  fi

  # Process response...
}

# Non-critical operations: default to Skip
ask_user_retry_noncritical() {
  local response

  echo "This is a non-critical operation. No response will skip."

  if ! read -t 300 response; then
    echo ""
    echo "⏱️ Timeout - defaulting to Skip (non-critical)"
    return 1  # Skip
  fi

  # Process response...
}
```

### Intelligent Defaults

```bash
get_default_action() {
  local error_type="$1"
  local severity="$2"

  case "$error_type" in
    "Network Failure")
      echo "A"  # Retry (network issues often transient)
      ;;
    "Build Failure")
      if [ "$severity" = "critical" ]; then
        echo "C"  # Abort (build must succeed)
      else
        echo "B"  # Skip (warnings acceptable)
      fi
      ;;
    "Test Failure")
      echo "C"  # Abort (tests should pass)
      ;;
    "Linting Error")
      echo "B"  # Skip (linting can be fixed later)
      ;;
    *)
      echo "C"  # Default to abort for unknown errors
      ;;
  esac
}
```

---

## Integration with TodoWrite

### Update Tasks Based on Response

```bash
handle_error_with_todo() {
  local task="$1"
  local error="$2"

  ask_user_retry "Task Failed" "$task" "$error" "A (Retry)"

  case $? in
    0)  # Retry
      # Keep task as in_progress
      update_todowrite "$task" "in_progress" "Retrying after error"
      ;;
    1)  # Skip
      # Mark as skipped
      update_todowrite "$task" "completed" "Skipped due to error: $error"
      ;;
    2)  # Abort
      # Mark as failed
      update_todowrite "$task" "pending" "Failed: $error"
      cleanup_and_exit "User aborted" 130
      ;;
  esac
}
```

---

## Logging and Metrics

### Log User Decisions

```bash
log_user_decision() {
  local error_type="$1"
  local response="$2"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "$timestamp | $error_type | $response" >> .agency/logs/user-decisions.log
}

# Usage
ask_user_retry "Build Failure" "npm build" "Syntax error" "A"
DECISION=$?
log_user_decision "Build Failure" "$DECISION"
```

### Track Retry Statistics

```bash
# Track retries
declare -A RETRY_COUNT

track_retry() {
  local operation="$1"
  RETRY_COUNT[$operation]=$((${RETRY_COUNT[$operation]:-0} + 1))
}

# Report in summary
report_retry_stats() {
  if [ ${#RETRY_COUNT[@]} -gt 0 ]; then
    echo ""
    echo "## Retry Statistics"
    echo ""
    for op in "${!RETRY_COUNT[@]}"; do
      echo "- $op: ${RETRY_COUNT[$op]} retries"
    done
  fi
}
```

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `tool-execution-failure.md` - For tool failures
- `timeout-handling.md` - For timeout recovery
- `user-cancellation.md` - Abort option leads here
- `partial-failure-recovery.md` - For multi-task scenarios

**Often used with**:
- `quality-gates/quality-gate-sequence.md` - For quality gate failures
- `progress/phase-tracking.md` - Update progress based on decisions

---

## Testing Ask User Retry

### Test Case 1: Build Failure with Retry

```bash
# Introduce temporary build error
echo "syntax error" >> src/index.ts

# Run command
/agency:implement "Add feature"

# When build fails:
# - Select "A" (Retry) - should fail again
# - Fix error manually
# - Select "A" (Retry) - should succeed

# Expected: Offers retry, respects user choice, proceeds after fix
```

### Test Case 2: Skip Non-Critical

```bash
# Introduce linting warning
echo "var x = 1" >> src/index.ts  # var instead of const

# Run command
/agency:work "Task"

# When lint fails:
# - Select "B" (Skip)

# Expected: Skips linting, continues workflow, notes in summary
```

### Test Case 3: Abort on Critical Failure

```bash
# Introduce critical test failure
echo "test('critical', () => { expect(true).toBe(false); });" >> src/critical.test.ts

# Run command
/agency:test "Run tests"

# When tests fail:
# - Select "C" (Abort)

# Expected: Cleans up, exits gracefully, preserves logs
```

---

## Success Metrics

**Ask user retry is successful when**:
- Clear, actionable options presented
- User choice respected and executed
- Appropriate defaults for timeouts
- Decision logged for audit trail
- Workflow continues or exits cleanly based on choice
- User feels in control of the process

**Failure indicators**:
- Options unclear or confusing
- Invalid responses not handled
- No default for timeout
- User choice ignored or misinterpreted
- Workflow proceeds incorrectly
- User frustrated by repetitive questions
