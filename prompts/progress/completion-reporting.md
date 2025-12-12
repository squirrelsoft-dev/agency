# Progress Tracking: Completion Reporting

Final TodoWrite update with workflow completion summary.

## When to Use

**Trigger conditions**:
- All workflow phases are complete
- Before presenting final summary to user
- As the last TodoWrite call in the command

**Purpose**: Mark workflow as 100% complete and provide clear completion status.

---

## Final Update Pattern

### All Phases Complete

When workflow finishes successfully:

```javascript
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "completed",
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Set up repository and branch",
      status: "completed",
      activeForm: "Setting up repository and branch"
    },
    {
      content: "Generate implementation plan",
      status: "completed",
      activeForm: "Generating implementation plan"
    },
    {
      content: "Select specialist(s) and get approval",
      status: "completed",
      activeForm: "Selecting specialist(s) and getting approval"
    },
    {
      content: "Implement changes via specialist",
      status: "completed",
      activeForm: "Implementing changes via specialist"
    },
    {
      content: "Run quality gates",
      status: "completed",
      activeForm: "Running quality gates"
    },
    {
      content: "Conduct code review",
      status: "completed",
      activeForm: "Conducting code review"
    },
    {
      content: "Commit and create pull request",
      status: "completed",
      activeForm: "Committing and creating pull request"
    }
  ]
});
```

**Validation**: All items should have `status: "completed"`

---

## Completion Summary

### Calculate Final Statistics

After final TodoWrite update, calculate summary metrics:

```javascript
calculate_completion_summary() {
  const total = todos.length;
  const completed = todos.filter(t => t.status === "completed").length;
  const pending = todos.filter(t => t.status === "pending").length;

  return {
    total_phases: total,
    completed_phases: completed,
    pending_phases: pending,
    success: completed === total,
    completion_percentage: Math.round((completed / total) * 100)
  };
}

// Example output:
// {
//   total_phases: 8,
//   completed_phases: 8,
//   pending_phases: 0,
//   success: true,
//   completion_percentage: 100
// }
```

### Success vs Partial Completion

**Full success** (100%):
```javascript
{
  total_phases: 8,
  completed_phases: 8,
  pending_phases: 0,
  success: true,
  completion_percentage: 100
}
```

**Partial completion** (some phases skipped or failed):
```javascript
{
  total_phases: 8,
  completed_phases: 6,
  pending_phases: 2,
  success: false,
  completion_percentage: 75,
  reason: "Quality gates failed, code review skipped"
}
```

---

## Completion Report Format

### Full Success Report

When all phases complete successfully:

```markdown
## Workflow Complete

**Status**: ✅ SUCCESS

**Progress**: 8/8 phases completed (100%)

**Phases Executed**:
- ✅ Fetch and analyze issue
- ✅ Set up repository and branch
- ✅ Generate implementation plan
- ✅ Select specialist(s) and get approval
- ✅ Implement changes via specialist
- ✅ Run quality gates
- ✅ Conduct code review
- ✅ Commit and create pull request

**Deliverables**:
- Pull Request: #123 (https://github.com/owner/repo/pull/123)
- Implementation Summary: .agency/implementations/impl-issue-456-20241212-143022.md
- Branch: feature/issue-456

**Next Steps**:
- Review the pull request
- Merge when CI passes and approvals received
- Close issue #456 after merge
```

### Partial Completion Report

When workflow completes with issues:

```markdown
## Workflow Incomplete

**Status**: ⚠️ PARTIAL

**Progress**: 5/8 phases completed (62%)

**Phases Executed**:
- ✅ Fetch and analyze issue
- ✅ Set up repository and branch
- ✅ Generate implementation plan
- ✅ Select specialist(s) and get approval
- ✅ Implement changes via specialist
- ❌ Run quality gates - **FAILED** (3 test failures)
- ⏭️ Conduct code review - **SKIPPED**
- ⏭️ Commit and create pull request - **SKIPPED**

**Issues Encountered**:
- 3 test failures in quality gates
- Cannot proceed to code review until tests pass
- No pull request created

**Next Steps**:
- Review test failures in implementation summary
- Fix failing tests
- Re-run quality gates with `/agency:test`
- Resume workflow after tests pass
```

---

## Timing Metrics

### Track Workflow Duration

Calculate time spent on workflow:

```javascript
// Store start time at initialization
const workflow_start = Date.now();

// Calculate duration at completion
const workflow_end = Date.now();
const duration_ms = workflow_end - workflow_start;
const duration_seconds = Math.round(duration_ms / 1000);
const duration_minutes = Math.round(duration_seconds / 60);

// Format duration
function format_duration(seconds) {
  if (seconds < 60) {
    return `${seconds} seconds`;
  } else if (seconds < 3600) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  } else {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${mins}m`;
  }
}

// Example output:
// "Duration: 4m 32s"
// "Duration: 1h 15m"
```

### Include in Completion Report

```markdown
## Workflow Complete

**Status**: ✅ SUCCESS
**Duration**: 4m 32s
**Progress**: 8/8 phases completed (100%)

...
```

---

## Phase Timing Breakdown

For detailed analysis, track time per phase:

```javascript
// Track phase timings
const phase_timings = [
  {phase: "Fetch and analyze issue", duration: "12s"},
  {phase: "Set up repository and branch", duration: "8s"},
  {phase: "Generate implementation plan", duration: "45s"},
  {phase: "Select specialist(s)", duration: "5s"},
  {phase: "Implement changes", duration: "2m 15s"},
  {phase: "Run quality gates", duration: "48s"},
  {phase: "Conduct code review", duration: "22s"},
  {phase: "Commit and create PR", duration: "11s"}
];

// Include in detailed summary
```

**Detailed timing report**:
```markdown
### Phase Timing Breakdown

| Phase | Duration | Status |
|-------|----------|--------|
| Fetch and analyze issue | 12s | ✅ |
| Set up repository and branch | 8s | ✅ |
| Generate implementation plan | 45s | ✅ |
| Select specialist(s) | 5s | ✅ |
| Implement changes | 2m 15s | ✅ |
| Run quality gates | 48s | ✅ |
| Conduct code review | 22s | ✅ |
| Commit and create PR | 11s | ✅ |
| **Total** | **4m 32s** | **100%** |
```

---

## Multi-Specialist Completion

For multi-specialist workflows, break down by specialist:

```markdown
## Workflow Complete - Multi-Specialist

**Status**: ✅ SUCCESS
**Duration**: 6m 18s
**Progress**: 8/8 phases completed (100%)

**Specialist Contributions**:

### Backend Architect
- Duration: 2m 45s
- Files changed: 5 created, 3 modified
- Status: ✅ Verified

### Frontend Developer
- Duration: 2m 10s
- Files changed: 7 created, 2 modified
- Status: ✅ Verified

### Integration
- Duration: 35s
- Status: ✅ Passed

**Total Changes**: 12 files created, 5 files modified
```

---

## Resource Links in Summary

Include links to all generated resources:

```markdown
## Generated Resources

**Implementation Artifacts**:
- Implementation Summary: `.agency/implementations/impl-issue-456-20241212-143022.md`
- Plan File: `.agency/plans/plan-issue-456.md`

**Git Artifacts**:
- Branch: `feature/issue-456`
- Pull Request: [#123](https://github.com/owner/repo/pull/123)
- Commits: 1 commit with 17 file changes

**Specialist Outputs** (if multi-specialist):
- Backend Summary: `.agency/handoff/issue-456/backend-architect/summary.md`
- Frontend Summary: `.agency/handoff/issue-456/frontend-developer/summary.md`

**Quality Reports**:
- Test Results: 24/24 tests passed (100%)
- Code Coverage: 87%
- Linter: 0 errors, 2 warnings
- Type Check: ✅ Passed
```

---

## Completion Validation

Before generating final report:

- [ ] All todos are marked `completed` (or explicitly noted as skipped)
- [ ] No items remain `in_progress`
- [ ] Completion percentage calculated correctly
- [ ] All deliverables are documented
- [ ] Resource links are accurate and absolute paths
- [ ] Next steps are clear and actionable

---

## Example: Full Completion Flow

```javascript
// 1. Final TodoWrite update (all completed)
TodoWrite({
  todos: [
    {content: "Fetch and analyze issue", status: "completed", activeForm: "..."},
    {content: "Set up repository and branch", status: "completed", activeForm: "..."},
    {content: "Generate implementation plan", status: "completed", activeForm: "..."},
    {content: "Select specialist(s)", status: "completed", activeForm: "..."},
    {content: "Implement changes", status: "completed", activeForm: "..."},
    {content: "Run quality gates", status: "completed", activeForm: "..."},
    {content: "Conduct code review", status: "completed", activeForm: "..."},
    {content: "Commit and create PR", status: "completed", activeForm: "..."}
  ]
});

// 2. Calculate metrics
const completion = {
  total_phases: 8,
  completed_phases: 8,
  completion_percentage: 100,
  duration: "4m 32s"
};

// 3. Generate completion report
const report = `
## Workflow Complete

**Status**: ✅ SUCCESS
**Duration**: ${completion.duration}
**Progress**: ${completion.completed_phases}/${completion.total_phases} phases (${completion.completion_percentage}%)

**Pull Request**: #123 - https://github.com/owner/repo/pull/123
**Implementation Summary**: .agency/implementations/impl-issue-456-20241212-143022.md

**Next Steps**:
- Review and merge the pull request
- Close issue #456 after merge
`;

// 4. Present to user
console.log(report);
```

---

## Notes

- Final TodoWrite should mark ALL phases as `completed`
- Include comprehensive completion summary for user
- Calculate and display timing metrics
- Provide clear next steps
- Link to all generated artifacts
- Distinguish between full success and partial completion
- Multi-specialist workflows need per-specialist breakdown
- Always validate completion state before final report
