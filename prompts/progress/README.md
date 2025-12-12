# Progress Tracking Components

Reusable components for TodoWrite-based progress tracking in multi-phase commands.

## Overview

These components provide consistent progress tracking across all agency commands using the TodoWrite tool. They define:
- How to initialize todo lists for different command types
- When and how to update progress as phases complete
- How to generate completion summaries with metrics

## Components

### 1. todo-initialization.md (467 lines)

**Purpose**: Initialize TodoWrite list at command start

**Provides**:
- Command-specific todo templates (work, implement, sprint, deploy)
- TodoWrite format specification (content, status, activeForm)
- Dynamic todo list generation (variable-length workflows)
- Best practices for granularity and naming

**Templates for**:
- `/agency:work` - 9 phases (fetch → plan → implement → verify → PR)
- `/agency:implement` - 6 phases (parse → select → implement → verify)
- `/agency:sprint` - Dynamic (N issues + summary)
- `/agency:deploy` - 7 phases (checks → build → deploy → verify)

**Example**:
```javascript
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "in_progress",  // First phase starts immediately
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Set up repository and branch",
      status: "pending",
      activeForm: "Setting up repository and branch"
    },
    // ... more phases
  ]
});
```

### 2. phase-tracking.md (398 lines)

**Purpose**: Update TodoWrite as workflow phases complete

**Defines**:
- Standard phase transition pattern
- Critical rule: Exactly ONE `in_progress` at all times
- Update timing (immediately after phase completes)
- Error handling (phase failures, user intervention)
- Multi-specialist progress tracking

**Update Pattern**:
```javascript
// After completing Phase 1
TodoWrite({
  todos: [
    {content: "Phase 1", status: "completed"},    // ← Just finished
    {content: "Phase 2", status: "in_progress"},  // ← Now active
    {content: "Phase 3", status: "pending"},      // ← Still waiting
    // ...
  ]
});
```

**Progress Calculation**:
```javascript
completed = todos.filter(t => t.status === "completed").length;
total = todos.length;
percentage = (completed / total) * 100;

// "Progress: 4/8 phases complete (50%)"
```

### 3. completion-reporting.md (419 lines)

**Purpose**: Final TodoWrite update with workflow summary

**Provides**:
- Full success vs partial completion patterns
- Timing metrics (duration per phase, total time)
- Completion statistics (phases completed, percentage)
- Multi-specialist breakdown
- Resource links (PR, implementation summary, etc.)

**Final Update**:
```javascript
// All phases marked completed
TodoWrite({
  todos: [
    {content: "Phase 1", status: "completed", activeForm: "..."},
    {content: "Phase 2", status: "completed", activeForm: "..."},
    {content: "Phase 3", status: "completed", activeForm: "..."},
    // ... all completed
  ]
});
```

**Summary Format**:
```markdown
## Workflow Complete

**Status**: ✅ SUCCESS
**Duration**: 4m 32s
**Progress**: 8/8 phases (100%)

**Pull Request**: #123
**Implementation Summary**: .agency/implementations/impl-issue-456.md

**Next Steps**:
- Review and merge PR
- Close issue after merge
```

## TodoWrite Format Specification

### Required Fields

Every todo item must have three fields:

```typescript
{
  content: string;      // Imperative: "Run quality gates"
  status: "pending" | "in_progress" | "completed";
  activeForm: string;   // Present continuous: "Running quality gates"
}
```

### Status Rules

**Critical rule**: Exactly ONE item must be `in_progress` at any time

```javascript
// ✅ CORRECT
[
  {status: "completed"},
  {status: "in_progress"},  // Only one
  {status: "pending"}
]

// ❌ WRONG
[
  {status: "in_progress"},  // Two!
  {status: "in_progress"},  // Wrong!
  {status: "pending"}
]
```

### Naming Conventions

**Content** (imperative form):
- Start with action verb
- Be specific and descriptive
- Keep under 50 characters

Examples:
- ✅ "Run quality gates (build, type, lint, test)"
- ✅ "Select specialist(s) and get approval"
- ❌ "Do stuff"
- ❌ "Quality"

**ActiveForm** (present continuous):
- Match content in -ing form
- Should read: "Currently: [activeForm]"

Examples:
- content: "Run quality gates" → activeForm: "Running quality gates"
- content: "Commit changes" → activeForm: "Committing changes"

## Usage Workflow

### Typical Command Flow

```markdown
## Command Start

### Phase 0: Initialize Progress Tracking
{{include:prompts/progress/todo-initialization.md}}

## Phase 1: First Task

[... do work ...]

### Update Progress
{{include:prompts/progress/phase-tracking.md}}

## Phase 2: Next Task

[... do work ...]

### Update Progress
{{include:prompts/progress/phase-tracking.md}}

## ... More Phases ...

## Command End

### Final Progress Update
{{include:prompts/progress/completion-reporting.md}}
```

## Best Practices

### 1. Granularity

**Ideal**: 5-10 phases per workflow
- Each phase: 2-10 minutes of work
- Meaningful milestones
- Regular user updates

**Too granular**: 20+ micro-tasks
- Updates too frequent
- Clutters UI

**Too coarse**: 2-3 giant phases
- Long periods without updates
- User can't see progress

### 2. Update Timing

**Update IMMEDIATELY after phase completes**:
```markdown
1. ✅ Phase work completes
2. 🔄 Update TodoWrite (mark completed, start next)
3. ✅ Begin next phase work
```

**Don't batch updates**:
```markdown
❌ Complete phases 1, 2, 3 → then update
✅ Complete phase 1 → update → complete phase 2 → update
```

### 3. Error Handling

**Phase fails**:
- Keep as `in_progress` (don't mark completed)
- Add fix phase if needed
- Re-run after fix

**User intervention needed**:
- Keep as `in_progress`
- Update activeForm: "Waiting for user approval"

## Integration Points

**Used by commands**:
- `work.md` - Full issue workflow tracking
- `implement.md` - Implementation progress
- `sprint.md` - Per-issue and sprint-level progress
- `deploy.md` - Deployment pipeline tracking

**User experience**:
- Real-time progress visibility
- Clear current phase indication
- Completion percentage
- Time estimates (from past runs)

## Examples

### Work Command Progress

```javascript
// Initialize (Phase 0)
TodoWrite({todos: [
  {content: "Fetch and analyze issue", status: "in_progress", ...},
  {content: "Set up repository", status: "pending", ...},
  // ... 7 more phases
]});

// After Phase 1
TodoWrite({todos: [
  {content: "Fetch and analyze issue", status: "completed", ...},
  {content: "Set up repository", status: "in_progress", ...},
  // ... rest pending
]});

// ... continue through phases ...

// Final
TodoWrite({todos: [
  {content: "Fetch and analyze issue", status: "completed", ...},
  {content: "Set up repository", status: "completed", ...},
  // ... all completed
]});

// Summary
console.log(`
Workflow Complete
Status: ✅ SUCCESS
Duration: 4m 32s
Progress: 9/9 phases (100%)
`);
```

## Notes

- Initialize todos BEFORE any work begins
- Update IMMEDIATELY after each phase
- Never batch multiple completions
- Always exactly ONE `in_progress`
- Include timing metrics in final summary
- Validate todo structure before calling TodoWrite
- User sees these updates in real-time - clarity matters
