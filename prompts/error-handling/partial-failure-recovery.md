# Error Handling: Partial Failure Recovery

Handle scenarios where some tasks succeed while others fail, requiring selective recovery and continuation.

## When to Use

**Triggers**:
- Multi-file changes where some files fail to process
- Quality gates where some pass, others fail
- Multi-issue sprint where some issues complete, others fail
- Deployment where some services deploy, others fail
- Test suite where some tests pass, others fail
- Multi-specialist workflow where one specialist succeeds, another fails

**Commands Using This**: 4 commands (`sprint`, `optimize`, `deploy`, `review`)

---

## Detection Patterns

### Pattern 1: Track Success/Failure per Task

```bash
# Initialize tracking
declare -A TASK_STATUS
declare -a COMPLETED_TASKS
declare -a FAILED_TASKS
declare -a SKIPPED_TASKS

# Process tasks
for task in "${TASKS[@]}"; do
  echo "Processing: $task"

  if process_task "$task"; then
    TASK_STATUS[$task]="success"
    COMPLETED_TASKS+=("$task")
  else
    EXIT_CODE=$?
    TASK_STATUS[$task]="failed:$EXIT_CODE"
    FAILED_TASKS+=("$task")
  fi
done

# Analyze results
TOTAL=${#TASKS[@]}
SUCCESS_COUNT=${#COMPLETED_TASKS[@]}
FAILURE_COUNT=${#FAILED_TASKS[@]}

echo ""
echo "Results: $SUCCESS_COUNT/$TOTAL succeeded, $FAILURE_COUNT failed"
```

### Pattern 2: Quality Gate Partial Failure

```bash
# Track quality gate results
BUILD_PASSED=false
TYPES_PASSED=false
LINT_PASSED=false
TESTS_PASSED=false

# Run gates
npm run build && BUILD_PASSED=true
npm run type-check && TYPES_PASSED=true
npm run lint && LINT_PASSED=true
npm test && TESTS_PASSED=true

# Evaluate
CRITICAL_PASSED=true
if [ "$BUILD_PASSED" = false ] || [ "$TYPES_PASSED" = false ] || [ "$TESTS_PASSED" = false ]; then
  CRITICAL_PASSED=false
fi

# Different handling based on what failed
if [ "$CRITICAL_PASSED" = true ] && [ "$LINT_PASSED" = false ]; then
  echo "⚠️ Only linting failed - can proceed with warnings"
elif [ "$CRITICAL_PASSED" = false ]; then
  echo "❌ Critical gates failed - must address before proceeding"
fi
```

### Pattern 3: File Processing Partial Failure

```bash
# Process multiple files
declare -a PROCESSED_FILES
declare -a FAILED_FILES

for file in "${FILES_TO_PROCESS[@]}"; do
  echo "Processing: $file"

  if process_file "$file"; then
    PROCESSED_FILES+=("$file")
    echo "  ✅ Success"
  else
    FAILED_FILES+=("$file")
    echo "  ❌ Failed"
  fi
done

# Decide how to proceed
if [ ${#FAILED_FILES[@]} -eq 0 ]; then
  echo "✅ All files processed successfully"
elif [ ${#PROCESSED_FILES[@]} -gt 0 ]; then
  echo "⚠️ Partial success: ${#PROCESSED_FILES[@]} succeeded, ${#FAILED_FILES[@]} failed"
  handle_partial_file_failure
else
  echo "❌ All files failed to process"
  exit 1
fi
```

### Pattern 4: Multi-Specialist Partial Failure

```bash
# Track specialist results
declare -A SPECIALIST_RESULTS

# Run specialists
run_specialist "backend-architect" && SPECIALIST_RESULTS[backend]="success" || SPECIALIST_RESULTS[backend]="failed"
run_specialist "frontend-developer" && SPECIALIST_RESULTS[frontend]="success" || SPECIALIST_RESULTS[frontend]="failed"

# Evaluate integration
if [ "${SPECIALIST_RESULTS[backend]}" = "success" ] && [ "${SPECIALIST_RESULTS[frontend]}" = "failed" ]; then
  echo "⚠️ Backend succeeded but frontend failed"
  echo "The API is ready, but the UI is not."
  handle_partial_specialist_failure
fi
```

---

## User Messages

### Partial Success Summary

```markdown
⚠️ **Partial Success**

The operation completed with mixed results.

**Summary**:
- ✅ Succeeded: [X] tasks
- ❌ Failed: [Y] tasks
- ⏭️ Skipped: [Z] tasks

**Total**: [X+Y+Z] tasks

---

### Successful Tasks

[List of completed tasks with checkmarks]

### Failed Tasks

[List of failed tasks with details]

**Failure Details**:
1. **[Task 1]**: [Error description]
   - Reason: [Why it failed]
   - Impact: [What this affects]

2. **[Task 2]**: [Error description]
   - Reason: [Why it failed]
   - Impact: [What this affects]

---

**How to proceed?**

Options:
A) Fix failed tasks and retry (recommended)
B) Continue without failed tasks (may cause issues)
C) Rollback all changes (revert successful tasks too)
D) Save progress and abort (I'll create a WIP commit)

Please select an option (A/B/C/D):
```

### Critical vs Non-Critical Failures

```markdown
⚠️ **Mixed Results: Critical Analysis**

**Critical Failures** (⛔ MUST fix):
- [List critical failures that block proceeding]
- Example: Build failed (cannot deploy without working build)

**Non-Critical Failures** (⚠️ Can proceed with caution):
- [List non-critical failures]
- Example: Linting warnings (code works but style issues)

**Recommendation**:
- Fix critical failures before proceeding
- Non-critical failures can be addressed later

**Options**:
A) Fix critical failures now (recommended)
B) Fix all failures (critical + non-critical)
C) Continue despite critical failures (not recommended)
D) Abort workflow

Please select an option (A/B/C/D):
```

### Multi-Issue Sprint Partial Failure

```markdown
⚠️ **Sprint Partial Completion**

**Sprint Summary**:
- Total Issues: [X]
- Completed: [Y] ✅
- Failed: [Z] ❌
- Success Rate: [Y/X * 100]%

---

### Completed Issues

1. ✅ **Issue #123**: User authentication
   - Status: Merged
   - PR: #456

2. ✅ **Issue #124**: Dashboard UI
   - Status: Merged
   - PR: #457

### Failed Issues

1. ❌ **Issue #125**: Payment integration
   - Reason: Stripe API authentication failed
   - Impact: Payment flow incomplete
   - Recommendation: Fix API keys and retry

2. ❌ **Issue #126**: Email notifications
   - Reason: SMTP server unreachable
   - Impact: Users won't receive emails
   - Recommendation: Configure SMTP or use alternative

---

**How to proceed?**

Options:
A) Continue sprint with remaining issues
B) Fix failed issues first, then continue
C) End sprint now (save progress on completed issues)
D) Rollback entire sprint (revert all changes)

Please select an option (A/B/C/D):
```

---

## Recovery Strategies

### Strategy 1: Retry Failed Tasks Only

```bash
retry_failed_tasks() {
  echo "🔄 Retrying failed tasks..."

  local retry_count=0
  local max_retries=3

  while [ ${#FAILED_TASKS[@]} -gt 0 ] && [ $retry_count -lt $max_retries ]; do
    retry_count=$((retry_count + 1))
    echo ""
    echo "Retry attempt $retry_count/$max_retries for ${#FAILED_TASKS[@]} tasks"

    local still_failing=()

    for task in "${FAILED_TASKS[@]}"; do
      echo "Retrying: $task"

      if process_task "$task"; then
        echo "  ✅ Succeeded on retry"
        COMPLETED_TASKS+=("$task")
        TASK_STATUS[$task]="success:retry$retry_count"
      else
        echo "  ❌ Still failing"
        still_failing+=("$task")
      fi
    done

    # Update failed tasks list
    FAILED_TASKS=("${still_failing[@]}")

    # Exit if all succeeded
    if [ ${#FAILED_TASKS[@]} -eq 0 ]; then
      echo ""
      echo "✅ All tasks succeeded after $retry_count retries"
      return 0
    fi
  done

  # Some tasks still failing
  echo ""
  echo "⚠️ ${#FAILED_TASKS[@]} tasks still failing after $max_retries retries"
  return 1
}
```

### Strategy 2: Continue with Degraded Functionality

```bash
continue_with_degraded() {
  echo "⚠️ Continuing with degraded functionality..."

  # Document what's missing
  cat > .agency/degraded-state.md <<EOF
# Degraded State Warning

This implementation is **incomplete** due to partial failures.

## What Failed

$(for task in "${FAILED_TASKS[@]}"; do
  echo "- [ ] $task - ${TASK_STATUS[$task]}"
done)

## What Works

$(for task in "${COMPLETED_TASKS[@]}"; do
  echo "- [x] $task"
done)

## Known Limitations

Due to the failures above, the following functionality is unavailable:
[Auto-generate based on failed tasks]

## To Complete

1. Address the failed tasks listed above
2. Re-run verification: \`npm test\`
3. Remove this file once complete

**Created**: $(date)
EOF

  echo ""
  echo "📝 Degraded state documented: .agency/degraded-state.md"
  echo "⚠️ Please address failures before deploying to production"
}
```

### Strategy 3: Rollback Successful Changes

```bash
rollback_partial_success() {
  echo "🔄 Rolling back successful changes..."

  # Confirm first
  echo "⚠️ This will undo ${#COMPLETED_TASKS[@]} successful tasks"
  echo "Are you sure? (yes/no)"
  read -r confirm

  if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    return 1
  fi

  # Git rollback
  if [ -n "$(git status --short)" ]; then
    echo "Resetting git changes..."
    git reset --hard HEAD
    git clean -fd
  fi

  # File-specific rollback
  for task in "${COMPLETED_TASKS[@]}"; do
    if [ -f ".agency/backups/${task}.backup" ]; then
      echo "Restoring backup for: $task"
      restore_backup "$task"
    fi
  done

  echo "✅ Rollback complete"
  COMPLETED_TASKS=()
}
```

### Strategy 4: Selective Commit (Success Only)

```bash
commit_successful_tasks() {
  echo "💾 Committing successful tasks only..."

  # Stage only files from successful tasks
  for task in "${COMPLETED_TASKS[@]}"; do
    # Get files modified by this task
    if [ -f ".agency/task-files/${task}.txt" ]; then
      while read -r file; do
        if [ -f "$file" ]; then
          git add "$file"
          echo "  Staged: $file"
        fi
      done < ".agency/task-files/${task}.txt"
    fi
  done

  # Create commit
  git commit -m "$(cat <<EOF
feat: partial implementation - ${#COMPLETED_TASKS[@]} of ${#TASKS[@]} tasks

Completed:
$(for task in "${COMPLETED_TASKS[@]}"; do echo "- $task"; done)

Failed (not included):
$(for task in "${FAILED_TASKS[@]}"; do echo "- $task"; done)

Ref: .agency/degraded-state.md
EOF
)"

  echo "✅ Committed successful tasks: $(git rev-parse --short HEAD)"
  echo "⚠️ Failed tasks remain uncommitted"
}
```

### Strategy 5: Dependency-Aware Recovery

```bash
# Recover based on task dependencies
recover_with_dependencies() {
  echo "🔍 Analyzing task dependencies..."

  # Build dependency graph
  declare -A DEPENDENCIES
  DEPENDENCIES["task-b"]="task-a"  # task-b depends on task-a
  DEPENDENCIES["task-c"]="task-a task-b"

  # Check if failures block downstream tasks
  declare -a BLOCKED_TASKS

  for task in "${COMPLETED_TASKS[@]}"; do
    # Check if this task's dependencies failed
    for dep in ${DEPENDENCIES[$task]:-}; do
      if [[ " ${FAILED_TASKS[@]} " =~ " ${dep} " ]]; then
        echo "⚠️ Task '$task' depends on failed task '$dep'"
        BLOCKED_TASKS+=("$task")
      fi
    done
  done

  if [ ${#BLOCKED_TASKS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Warning: ${#BLOCKED_TASKS[@]} tasks may not work correctly"
    echo "They depend on failed tasks:"
    for task in "${BLOCKED_TASKS[@]}"; do
      echo "  - $task (depends on: ${DEPENDENCIES[$task]})"
    done

    echo ""
    echo "Recommendation: Fix dependencies first"
    return 1
  fi

  echo "✅ No dependency issues detected"
  return 0
}
```

---

## Exit Codes and State Management

### Exit Codes

```bash
# Partial failure exit codes
EXIT_CODE_PARTIAL_SUCCESS=50      # Some tasks succeeded, some failed
EXIT_CODE_PARTIAL_CRITICAL=51     # Critical tasks failed, non-critical passed
EXIT_CODE_PARTIAL_DEGRADED=52     # Continuing with degraded functionality
EXIT_CODE_PARTIAL_ROLLBACK=53     # User chose to rollback partial success
```

### State Persistence

```bash
save_partial_state() {
  local state_file=".agency/partial-state.json"

  # Save current state
  cat > "$state_file" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_tasks": ${#TASKS[@]},
  "completed": ${#COMPLETED_TASKS[@]},
  "failed": ${#FAILED_TASKS[@]},
  "skipped": ${#SKIPPED_TASKS[@]},
  "completed_tasks": [
    $(printf '"%s",' "${COMPLETED_TASKS[@]}" | sed 's/,$//')
  ],
  "failed_tasks": [
    $(printf '"%s",' "${FAILED_TASKS[@]}" | sed 's/,$//')
  ],
  "task_status": {
    $(for task in "${!TASK_STATUS[@]}"; do
      echo "\"$task\": \"${TASK_STATUS[$task]}\","
    done | sed '$ s/,$//')
  },
  "can_continue": $([ "$CRITICAL_PASSED" = true ] && echo "true" || echo "false"),
  "recommendation": "$(get_recommendation)"
}
EOF

  echo "State saved: $state_file"
}

load_partial_state() {
  local state_file=".agency/partial-state.json"

  if [ -f "$state_file" ]; then
    echo "Found previous partial state. Would you like to:"
    echo "A) Resume from partial state"
    echo "B) Start fresh (discard previous state)"

    read -r choice

    if [ "$choice" = "A" ]; then
      # Load state (requires jq)
      # Parse JSON and restore arrays
      echo "Resuming from previous state..."
      return 0
    fi
  fi

  return 1
}
```

---

## Quality Gate Specific Handling

### Build Passes, Tests Fail

```markdown
⚠️ **Build Success, Test Failure**

**Status**:
- ✅ Build: Passed
- ✅ Type Check: Passed
- ✅ Linter: Passed
- ❌ Tests: Failed (12 of 150 tests)

**Analysis**:
The code compiles and has no type/lint errors, but tests are failing.

**Failed Tests**:
1. `user.test.ts` - Authentication tests (5 failures)
2. `api.test.ts` - API integration tests (7 failures)

**Recommendation**:
This suggests a behavioral regression or test data issue, not a code error.

**Options**:
A) Fix failing tests (I'll analyze and attempt fixes)
B) Review test failures manually
C) Continue without tests (NOT recommended for production)
D) Abort workflow

Please select an option (A/B/C/D):
```

### Some Services Deploy, Others Fail

```markdown
⚠️ **Partial Deployment**

**Deployment Status**:
- ✅ Frontend: Deployed successfully
- ✅ API: Deployed successfully
- ❌ Worker Service: Deployment failed
- ❌ Database Migration: Failed

**Impact**:
- User-facing features are live
- Background jobs won't process (worker down)
- Database may be out of sync

**Risk Level**: 🔴 HIGH

**Recommendation**: Rollback entire deployment

**Options**:
A) Rollback all services (recommended)
B) Fix failed services and redeploy
C) Leave partial deployment (high risk)
D) Investigate failures first

Please select an option (A/B/C/D):
```

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `ask-user-retry.md` - For retry/skip/abort decisions
- `reporting/summary-template.md` - Document partial success
- `progress/completion-reporting.md` - Show partial completion status

**Often used with**:
- `error-handling/tool-execution-failure.md` - When tools fail
- `quality-gates/rollback-on-failure.md` - For rollback operations
- `error-handling/user-cancellation.md` - User may cancel during recovery

---

## Testing Partial Failure Recovery

### Test Case 1: Partial File Processing

```bash
# Create mixed scenario
touch file1.ts file2.ts file3.ts
echo "syntax error" > file2.ts  # This will fail processing

# Run command
/agency:refactor "Update all files"

# Expected: file1 and file3 succeed, file2 fails, offers recovery options
```

### Test Case 2: Quality Gate Mix

```bash
# Introduce test failures but keep build working
echo "test('fails', () => { expect(true).toBe(false); });" >> src/test.spec.ts

# Run command
/agency:implement "Add feature"

# Expected: Build passes, tests fail, asks how to proceed
```

### Test Case 3: Multi-Issue Sprint

```bash
# Create multiple issues, make one fail
# Issue 1: Should succeed
# Issue 2: Introduce error that causes failure
# Issue 3: Should succeed

# Run command
/agency:sprint "Process 3 issues"

# Expected: 2 succeed, 1 fails, offers to continue or fix
```

---

## Success Metrics

**Partial failure recovery is successful when**:
- All successes and failures accurately tracked
- Clear reporting of what worked and what didn't
- Appropriate recovery options offered based on criticality
- User can choose to continue, rollback, or fix
- State is preserved for resume/recovery
- Dependencies between tasks are considered

**Failure indicators**:
- Lost track of which tasks succeeded/failed
- Silent failures (not reported)
- No recovery options offered
- Cannot determine impact of failures
- Successful work lost during rollback
- Dependency issues not detected
