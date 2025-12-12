# Error Handling: User Cancellation

Handle scenarios where the user cancels or aborts an operation mid-workflow.

## When to Use

**Triggers**:
- User presses Ctrl+C during execution
- User responds "abort" or "cancel" to AskUserQuestion
- User closes terminal/session
- User explicitly requests to stop
- User timeout (no response to prompts after extended period)

**Commands Using This**: 12 commands (all except `help` and `adr`)

---

## Detection Patterns

### Pattern 1: Ctrl+C Detection

```bash
# Set up trap for SIGINT (Ctrl+C)
trap 'handle_user_interrupt' INT TERM

handle_user_interrupt() {
  echo ""
  echo "⚠️ Interrupt signal received (Ctrl+C)"
  cleanup_and_exit "User cancelled via Ctrl+C"
}
```

### Pattern 2: Abort Response to Questions

When using `AskUserQuestion`:

```markdown
**Options**:
A) Continue with fixes
B) Skip this step
C) Abort workflow

User response: C
```

**Detection**: User selected "Abort" or similar option

### Pattern 3: Empty/Invalid Response Detection

```bash
# After prompting user
if [ -z "$USER_RESPONSE" ]; then
  TIMEOUT_COUNT=$((TIMEOUT_COUNT + 1))

  if [ $TIMEOUT_COUNT -ge 3 ]; then
    echo "No response after 3 attempts. Assuming cancellation."
    cleanup_and_exit "User timeout - no response"
  fi
fi
```

### Pattern 4: Explicit Cancel Command

User types any of:
- "cancel"
- "abort"
- "quit"
- "exit"
- "stop"

```bash
# Case-insensitive check
if echo "$USER_RESPONSE" | grep -iE '^(cancel|abort|quit|exit|stop)$' &>/dev/null; then
  cleanup_and_exit "User requested cancellation"
fi
```

---

## User Messages

### Initial Cancellation Confirmation

When cancellation is detected, confirm before proceeding:

```markdown
⚠️ **Cancellation Detected**

You've requested to stop the current operation.

**Current Progress**:
- Phase: [CURRENT_PHASE]
- Completed: [X/Y] tasks
- In Progress: [CURRENT_TASK]

**Cancelling will**:
- Stop all in-progress operations
- Clean up temporary files
- Preserve completed work (if any)
- NOT create a commit or PR

**Are you sure you want to cancel?**

Options:
A) Yes, cancel and exit
B) No, continue the workflow

Please confirm (A/B):
```

### Cancellation with Partial Work

If some work has been completed:

```markdown
⚠️ **Cancellation with Partial Work**

You've made progress on this task. Cancelling now will:

**Completed** ✅:
- [List of completed tasks]

**Not Completed** ❌:
- [List of incomplete tasks]

**Cleanup options**:
A) Save partial work (create WIP commit)
B) Discard all changes (git reset)
C) Keep changes uncommitted (no action)
D) Continue workflow (don't cancel)

Please select an option (A/B/C/D):
```

### Graceful Exit Message

After cleanup:

```markdown
✅ **Workflow Cancelled Successfully**

**Summary**:
- Duration: [TIME_ELAPSED]
- Phase reached: [PHASE_NAME]
- Tasks completed: [X/Y]
- Changes: [Saved/Discarded/Uncommitted]

**What happened**:
[Brief summary of what was completed before cancellation]

**To resume later**:
[Instructions on how to continue, if applicable]

**Cleanup performed**:
- ✅ Temporary files removed
- ✅ TodoWrite cleared
- ✅ State saved to .agency/logs/cancelled-sessions.log

Thank you for using Agency! 👋
```

---

## Cleanup Procedures

### Critical Cleanup Tasks

Execute in this order:

#### 1. Stop All Background Processes

```bash
cleanup_background_processes() {
  echo "🧹 Stopping background processes..."

  # Kill any background jobs started by this session
  jobs -p | xargs -r kill 2>/dev/null || true

  # Stop any spawned specialist agents
  if [ -f .agency/tmp/specialist-pids.txt ]; then
    while read -r pid; do
      kill -TERM "$pid" 2>/dev/null || true
    done < .agency/tmp/specialist-pids.txt
    rm -f .agency/tmp/specialist-pids.txt
  fi

  echo "  ✅ Background processes stopped"
}
```

#### 2. Save Partial State

```bash
save_partial_state() {
  echo "💾 Saving partial state..."

  local timestamp=$(date +%Y%m%d-%H%M%S)
  local state_file=".agency/logs/cancelled-sessions/${timestamp}.json"

  mkdir -p .agency/logs/cancelled-sessions

  cat > "$state_file" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "$AGENCY_COMMAND",
  "phase": "$CURRENT_PHASE",
  "completed_tasks": $COMPLETED_TASK_COUNT,
  "total_tasks": $TOTAL_TASK_COUNT,
  "specialist": "$SELECTED_SPECIALIST",
  "cancellation_reason": "$CANCELLATION_REASON",
  "duration_seconds": $ELAPSED_SECONDS,
  "working_directory": "$(pwd)",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'N/A')",
  "git_status": "$(git status --short 2>/dev/null | base64 || echo '')"
}
EOF

  echo "  ✅ State saved to: $state_file"
}
```

#### 3. Clean Up Temporary Files

```bash
cleanup_temp_files() {
  echo "🧹 Cleaning temporary files..."

  # Remove temp directories
  rm -rf .agency/tmp/* 2>/dev/null || true

  # Remove lock files
  rm -f .agency/locks/*.lock 2>/dev/null || true

  # Clean up build artifacts if incomplete
  if [ "$BUILD_INCOMPLETE" = "true" ]; then
    rm -rf .next dist build 2>/dev/null || true
  fi

  # Remove partial test reports
  rm -rf coverage .coverage htmlcov 2>/dev/null || true

  echo "  ✅ Temporary files cleaned"
}
```

#### 4. Handle Git State

Based on user selection:

**Option A: Save as WIP Commit**
```bash
save_wip_commit() {
  echo "💾 Saving work-in-progress..."

  git add .
  git commit -m "WIP: Cancelled during $(date -u +"%Y-%m-%dT%H:%M:%SZ")

Agency Command: $AGENCY_COMMAND
Phase: $CURRENT_PHASE
Completed: $COMPLETED_TASK_COUNT/$TOTAL_TASK_COUNT tasks

This is a work-in-progress commit created automatically when
the workflow was cancelled. Continue with caution." \
    --no-verify  # Skip hooks for WIP

  echo "  ✅ WIP commit created: $(git rev-parse --short HEAD)"
  echo "  📝 Note: This commit has --no-verify (skipped hooks)"
}
```

**Option B: Discard All Changes**
```bash
discard_changes() {
  echo "🗑️ Discarding all changes..."

  # Confirm first
  echo "⚠️ WARNING: This will permanently delete all uncommitted changes."
  echo "Are you absolutely sure? Type 'yes' to confirm:"
  read -r confirm

  if [ "$confirm" != "yes" ]; then
    echo "Discard cancelled. Changes preserved."
    return 1
  fi

  # Reset everything
  git reset --hard HEAD
  git clean -fd

  echo "  ✅ All changes discarded"
}
```

**Option C: Keep Uncommitted**
```bash
keep_uncommitted() {
  echo "📝 Keeping changes uncommitted..."

  # Just show status
  echo ""
  echo "Current git status:"
  git status --short
  echo ""
  echo "  ✅ Changes preserved (uncommitted)"
  echo "  💡 You can commit manually when ready"
}
```

#### 5. Clear TodoWrite

```bash
clear_todowrite() {
  echo "📋 Clearing TodoWrite..."

  # Mark all in-progress as cancelled
  # (Actual implementation depends on TodoWrite API)

  echo "  ✅ TodoWrite cleared"
}
```

#### 6. Log Cancellation

```bash
log_cancellation() {
  local log_file=".agency/logs/cancellations.log"

  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | $AGENCY_COMMAND | $CURRENT_PHASE | $CANCELLATION_REASON | ${ELAPSED_SECONDS}s" >> "$log_file"

  echo "  ✅ Cancellation logged"
}
```

### Complete Cleanup Function

```bash
cleanup_and_exit() {
  local reason="$1"
  local exit_code="${2:-130}"  # 130 = terminated by Ctrl+C

  CANCELLATION_REASON="$reason"

  echo ""
  echo "═══════════════════════════════════════"
  echo "   Cancellation Cleanup in Progress"
  echo "═══════════════════════════════════════"
  echo ""

  # Execute cleanup steps
  cleanup_background_processes
  save_partial_state
  cleanup_temp_files

  # Ask user about git state (if changes exist)
  if [ -n "$(git status --short 2>/dev/null)" ]; then
    handle_git_cleanup
  fi

  clear_todowrite
  log_cancellation

  echo ""
  echo "═══════════════════════════════════════"
  echo "   Cleanup Complete"
  echo "═══════════════════════════════════════"
  echo ""

  # Show final summary
  show_cancellation_summary

  exit $exit_code
}
```

---

## Exit Codes

### Standard Cancellation Exit Codes

```bash
# User-initiated cancellations
EXIT_CODE_USER_CANCEL=130        # Ctrl+C (standard Unix convention)
EXIT_CODE_USER_ABORT=131         # Explicit abort command
EXIT_CODE_USER_TIMEOUT=132       # User didn't respond to prompts
EXIT_CODE_USER_QUIT=133          # User selected quit option

# Graceful vs Forced
EXIT_CODE_GRACEFUL_CANCEL=0      # Clean cancellation, all cleanup done
EXIT_CODE_FORCED_CANCEL=134      # Forced exit, cleanup incomplete
```

### Exit Code Usage

```bash
# Graceful cancellation (all cleanup successful)
cleanup_and_exit "User requested cancellation" $EXIT_CODE_GRACEFUL_CANCEL

# Ctrl+C interrupt
cleanup_and_exit "SIGINT received" $EXIT_CODE_USER_CANCEL

# Timeout
cleanup_and_exit "No user response after 3 attempts" $EXIT_CODE_USER_TIMEOUT

# Forced exit (cleanup failed)
cleanup_and_exit "Cleanup incomplete" $EXIT_CODE_FORCED_CANCEL
```

---

## Cancellation Summary

### Summary Template

```markdown
## Cancellation Summary

**Command**: /agency:[COMMAND] "[REQUEST]"
**Cancelled At**: [TIMESTAMP]
**Duration**: [HH:MM:SS]
**Reason**: [CANCELLATION_REASON]

---

### Progress Report

**Phase Reached**: [PHASE_NAME] (Phase [X] of [Y])

**Completed Tasks**: [X/Y]
[List of completed tasks with checkmarks]

**In Progress**:
[Task that was running when cancelled]

**Not Started**:
[List of remaining tasks]

---

### Changes Made

**Files Modified**: [X]
**Files Created**: [Y]
**Files Deleted**: [Z]

**Git Status**:
[Saved as WIP commit / Discarded / Uncommitted]
[If commit: Commit hash and message]

---

### Cleanup Actions

- ✅ Background processes stopped
- ✅ Temporary files removed
- ✅ State saved
- ✅ TodoWrite cleared
- ✅ Git state handled

**Cleanup Status**: Complete / Incomplete

---

### How to Resume

[If resumable]:
To continue where you left off:

1. Review the saved state: `.agency/logs/cancelled-sessions/[FILE]`
2. Check git status: `git status`
3. [If WIP commit] Review commit: `git show HEAD`
4. Re-run command: `/agency:[COMMAND] "[REQUEST]"`

[If not resumable]:
To start fresh:

1. [If uncommitted] Decide whether to keep or discard changes
2. Start a new command
3. The previous attempt has been logged for reference

---

### Resources

**Logs**:
- State: `.agency/logs/cancelled-sessions/[FILE].json`
- Cancellation log: `.agency/logs/cancellations.log`

**Support**:
If you encountered issues, please review the logs above.
```

---

## Prevention and Best Practices

### For Command Authors

1. **Implement Checkpoints**:
```markdown
After each major phase, save state so users can resume if needed.
```

2. **Make Cancellation Safe**:
```bash
# Always use trap
trap 'cleanup_and_exit "User interrupt" $EXIT_CODE_USER_CANCEL' INT TERM

# Check for cancellation in long loops
for item in "${items[@]}"; do
  # Check if cancelled
  if [ -f .agency/tmp/cancel-requested ]; then
    cleanup_and_exit "Cancellation requested" $EXIT_CODE_USER_CANCEL
  fi

  # Do work
  process_item "$item"
done
```

3. **Provide Clear Cancellation Points**:
```markdown
Before each major phase, give user option to continue or abort:

**Ready to proceed with [PHASE_NAME]?**
A) Continue
B) Skip this phase
C) Abort workflow
```

### For Users

**How to cancel safely**:

1. **Preferred**: Wait for a natural checkpoint, then select "Abort" option
2. **Acceptable**: Press Ctrl+C once and wait for cleanup
3. **Avoid**: Pressing Ctrl+C multiple times (may skip cleanup)
4. **Never**: Killing the terminal without cancelling (may leave artifacts)

---

## Edge Cases

### Scenario 1: Cancellation During Git Operation

```bash
# If cancelled during git commit
if git status | grep -q "interactive rebase in progress"; then
  echo "⚠️ Git rebase in progress. Aborting rebase..."
  git rebase --abort
fi

if git status | grep -q "merge in progress"; then
  echo "⚠️ Git merge in progress. Aborting merge..."
  git merge --abort
fi
```

### Scenario 2: Cancellation During Specialist Spawn

```bash
# If cancelled while specialist is running
if [ -f .agency/tmp/specialist-active ]; then
  echo "⚠️ Specialist agent is active. Sending termination signal..."

  SPECIALIST_PID=$(cat .agency/tmp/specialist-pid 2>/dev/null)
  if [ -n "$SPECIALIST_PID" ]; then
    kill -TERM "$SPECIALIST_PID"
    sleep 2
    kill -KILL "$SPECIALIST_PID" 2>/dev/null || true
  fi

  rm -f .agency/tmp/specialist-active .agency/tmp/specialist-pid
fi
```

### Scenario 3: Cancellation During File Operations

```bash
# If cancelled during file write
if [ -f .agency/tmp/file-write-in-progress ]; then
  echo "⚠️ File write was in progress. Checking integrity..."

  TARGET_FILE=$(cat .agency/tmp/file-write-target)
  BACKUP_FILE="${TARGET_FILE}.backup"

  if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring from backup..."
    mv "$BACKUP_FILE" "$TARGET_FILE"
  else
    echo "No backup available. File may be incomplete: $TARGET_FILE"
  fi

  rm -f .agency/tmp/file-write-in-progress .agency/tmp/file-write-target
fi
```

### Scenario 4: Cancellation During Network Operation

```bash
# If cancelled during gh or network operation
if [ -f .agency/tmp/network-operation-active ]; then
  echo "⚠️ Network operation was in progress. No cleanup needed."
  rm -f .agency/tmp/network-operation-active

  # Network operations are generally safe to interrupt
  # No special cleanup required
fi
```

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `ask-user-retry.md` - For abort options in questions
- `progress/todo-initialization.md` - For clearing TodoWrite
- `reporting/summary-template.md` - For cancellation summary

**Often used with**:
- `error-handling/partial-failure-recovery.md` - When partially complete
- `error-handling/tool-execution-failure.md` - If tool failure led to cancellation

---

## Testing User Cancellation

### Test Case 1: Ctrl+C During Execution

```bash
# Start a command
/agency:implement "Add feature" &
COMMAND_PID=$!

# Wait a few seconds
sleep 5

# Send SIGINT
kill -INT $COMMAND_PID

# Expected: Graceful cleanup, summary shown
```

### Test Case 2: Abort During Question

```bash
# Run command that prompts
/agency:work "Complex task"

# When prompted, respond: "abort"

# Expected: Confirms cancellation, cleans up, exits
```

### Test Case 3: Timeout (No Response)

```bash
# Run command
/agency:review "Check code"

# Don't respond to any prompts (simulate timeout)

# Expected: After 3 attempts, treats as cancellation
```

---

## Success Metrics

**Cancellation handling is successful when**:
- All background processes terminated
- Temporary files cleaned up
- Git state properly handled (user choice)
- Partial work preserved or discarded as requested
- Clear summary provided
- State logged for debugging/resume

**Failure indicators**:
- Orphaned processes still running
- Temp files left behind
- Git in inconsistent state
- No summary or logs
- Unclear what was completed
