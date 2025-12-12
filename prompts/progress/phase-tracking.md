# Progress Tracking: Phase Tracking

Update TodoWrite list as workflow phases complete.

## When to Use

**Trigger conditions**:
- After completing each workflow phase
- Before starting the next phase
- When phase status changes (success/failure)

**Purpose**: Keep todo list synchronized with actual workflow progress.

---

## Core Update Pattern

### Standard Phase Transition

When completing a phase and moving to the next:

```javascript
// BEFORE starting Phase 2 work:
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "completed",           // ← Mark previous as completed
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Set up repository and branch",
      status: "in_progress",         // ← Mark current as in_progress
      activeForm: "Setting up repository and branch"
    },
    {
      content: "Generate implementation plan",
      status: "pending",             // ← Rest remain pending
      activeForm: "Generating implementation plan"
    },
    // ... more phases
  ]
});
```

### Critical Rule

**EXACTLY ONE** item must be `in_progress` at all times during workflow:

```javascript
// Count in_progress items - must equal 1
const inProgressCount = todos.filter(t => t.status === "in_progress").length;
if (inProgressCount !== 1) {
  throw new Error("Must have exactly one in_progress item");
}
```

---

## Update Timing

### When to Update

**Update IMMEDIATELY after completing a phase**:

1. ✅ Phase work completes
2. 🔄 **Update TodoWrite** (mark completed, start next)
3. ✅ Begin next phase work

**Example**:
```markdown
## Phase 2: Repository Setup

[... perform git operations ...]

<!-- After git operations succeed: -->
Use TodoWrite tool to update progress:
- Mark "Set up repository and branch" as completed
- Mark "Generate implementation plan" as in_progress

<!-- Now begin plan generation -->
```

### Don't Batch Updates

❌ **Wrong** - Batching multiple completions:
```javascript
// After completing phases 1, 2, and 3
TodoWrite({
  todos: [
    {content: "Phase 1", status: "completed"},
    {content: "Phase 2", status: "completed"},
    {content: "Phase 3", status: "completed"},
    {content: "Phase 4", status: "in_progress"},
    // ...
  ]
});
```

✅ **Right** - Update after each phase:
```javascript
// After Phase 1
TodoWrite({todos: [...mark Phase 1 completed, Phase 2 in_progress...]});

// After Phase 2
TodoWrite({todos: [...mark Phase 2 completed, Phase 3 in_progress...]});

// After Phase 3
TodoWrite({todos: [...mark Phase 3 completed, Phase 4 in_progress...]});
```

---

## Update Patterns by Workflow

### Linear Workflow (Sequential Phases)

Most common pattern - one phase after another:

```javascript
// Initial state
Phase 1: in_progress
Phase 2: pending
Phase 3: pending

// After Phase 1 completes
Phase 1: completed
Phase 2: in_progress  // ← Moved to next
Phase 3: pending

// After Phase 2 completes
Phase 1: completed
Phase 2: completed
Phase 3: in_progress  // ← Moved to next
```

### Conditional Workflow (Skip/Add Phases)

When phases might be skipped or added dynamically:

```javascript
// Scenario: Multi-specialist detected, add specialist phases

// Original todos (before specialist detection)
[
  {content: "Parse plan", status: "completed"},
  {content: "Select specialist", status: "in_progress"},
  {content: "Implement changes", status: "pending"},
  {content: "Run quality gates", status: "pending"}
]

// Updated todos (after detecting 2 specialists)
[
  {content: "Parse plan", status: "completed"},
  {content: "Select specialist", status: "completed"},
  {content: "Backend implementation", status: "in_progress"},  // ← Added
  {content: "Frontend implementation", status: "pending"},     // ← Added
  {content: "Integration verification", status: "pending"},    // ← Added
  {content: "Run quality gates", status: "pending"}
]
```

### Parallel Sub-phases

When a phase has parallel sub-tasks:

```javascript
// Option 1: Single phase for parallel work
{
  content: "Run quality gates (build, type, lint, test)",
  status: "in_progress",
  activeForm: "Running quality gates"
}

// Option 2: Expand into sub-phases (if failures need isolation)
{
  content: "Run quality gates - build",
  status: "completed",
  activeForm: "Running build"
},
{
  content: "Run quality gates - type check",
  status: "completed",
  activeForm: "Running type check"
},
{
  content: "Run quality gates - linter",
  status: "in_progress",
  activeForm: "Running linter"
},
{
  content: "Run quality gates - tests",
  status: "pending",
  activeForm: "Running tests"
}
```

---

## Progress Calculation

Track completion percentage for user feedback:

```javascript
calculate_progress() {
  const total = todos.length;
  const completed = todos.filter(t => t.status === "completed").length;
  const percentage = Math.round((completed / total) * 100);

  return {
    total,
    completed,
    remaining: total - completed,
    percentage,
    current: todos.find(t => t.status === "in_progress")?.content
  };
}

// Example output:
// "Progress: 4/8 phases complete (50%) - Currently: Running quality gates"
```

---

## Error Handling

### Phase Fails

When a phase fails, keep it `in_progress` with context:

```javascript
// Build failed - don't mark as completed
[
  {content: "Select specialist", status: "completed"},
  {content: "Implement changes", status: "completed"},
  {content: "Run quality gates", status: "in_progress"},  // ← Failed, still in_progress
  {content: "Code review", status: "pending"}             // ← Can't proceed
]

// Add a sub-phase for fix
[
  {content: "Select specialist", status: "completed"},
  {content: "Implement changes", status: "completed"},
  {content: "Run quality gates", status: "completed"},    // ← Now resolved
  {content: "Fix build errors", status: "in_progress"},   // ← Added fix phase
  {content: "Re-run quality gates", status: "pending"},   // ← Re-run after fix
  {content: "Code review", status: "pending"}
]
```

### User Intervention Required

When blocked waiting for user:

```javascript
// Keep current phase as in_progress until user responds
{
  content: "Select specialist(s) and get approval",
  status: "in_progress",  // ← Waiting for user confirmation
  activeForm: "Awaiting user approval for specialist selection"
}

// Update activeForm to indicate waiting
{
  content: "Select specialist(s) and get approval",
  status: "in_progress",
  activeForm: "Waiting for specialist approval"  // ← Clarify status
}
```

---

## Multi-Specialist Progress

Track individual specialist progress:

```javascript
// Phase: Backend Implementation
{
  content: "Backend implementation (3/5 tasks complete)",
  status: "in_progress",
  activeForm: "Implementing backend (3/5 tasks)"
}

// Update as specialist progresses
{
  content: "Backend implementation (5/5 tasks complete)",
  status: "completed",  // ← All backend tasks done
  activeForm: "Implementing backend"
}

// Move to next specialist
{
  content: "Frontend implementation (0/4 tasks complete)",
  status: "in_progress",
  activeForm: "Implementing frontend (0/4 tasks)"
}
```

---

## Phase Completion Checklist

Before marking a phase as `completed`:

- [ ] All work for the phase is truly finished
- [ ] No errors or blockers remain
- [ ] Output/artifacts are validated
- [ ] Next phase has prerequisites met

**Never mark as completed if**:
- Tests are failing
- Build has errors
- Waiting for external dependency
- User approval needed but not received

---

## Update Examples

### Example 1: Work Command Progress

```javascript
// After Phase 1: Issue fetch
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "completed",
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Set up repository and branch",
      status: "in_progress",
      activeForm: "Setting up repository and branch"
    },
    // ... rest pending
  ]
});

// After Phase 2: Repository setup
TodoWrite({
  todos: [
    {content: "Fetch and analyze issue", status: "completed", activeForm: "..."},
    {content: "Set up repository and branch", status: "completed", activeForm: "..."},
    {
      content: "Generate implementation plan",
      status: "in_progress",
      activeForm: "Generating implementation plan"
    },
    // ... rest pending
  ]
});
```

### Example 2: Implement Command Progress

```javascript
// After specialist implementation
TodoWrite({
  todos: [
    {content: "Validate and parse plan file", status: "completed", activeForm: "..."},
    {content: "Select specialist(s)", status: "completed", activeForm: "..."},
    {content: "Execute implementation", status: "completed", activeForm: "..."},
    {
      content: "Run quality gates (build, type, lint, test)",
      status: "in_progress",
      activeForm: "Running quality gates"
    },
    {content: "Conduct code review", status: "pending", activeForm: "..."},
    {content: "Generate summary", status: "pending", activeForm: "..."}
  ]
});
```

---

## Validation

After each update:

- [ ] Exactly ONE item has `status: "in_progress"`
- [ ] All previous phases are `completed`
- [ ] All future phases are `pending`
- [ ] Current phase matches actual work being done
- [ ] Progress percentage increases monotonically

---

## Notes

- Update TodoWrite IMMEDIATELY after each phase completes
- Never batch multiple completions into one update
- Always maintain exactly one `in_progress` item
- Use dynamic todo updates for conditional workflows
- Progress percentage helps users track long-running workflows
- Clear, accurate activeForm text improves user experience
- Failed phases should remain `in_progress` until resolved
