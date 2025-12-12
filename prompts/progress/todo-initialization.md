# Progress Tracking: Todo Initialization

Initialize TodoWrite list for tracking command workflow phases.

## When to Use

**Trigger conditions**:
- At the start of any multi-phase command workflow
- When a command has 3+ distinct phases/steps
- For complex tasks that benefit from progress visibility

**Commands that use this**:
- `work.md` - Full issue workflow (7-9 phases)
- `implement.md` - Implementation workflow (6 phases)
- `sprint.md` - Sprint workflow (per-issue phases)
- `deploy.md` - Deployment workflow (5+ phases)

**Purpose**: Create structured todo list to track progress and provide user visibility.

---

## TodoWrite Format

Each todo item requires three fields:

```javascript
{
  "content": "Imperative form - what needs to be done",
  "status": "pending|in_progress|completed",
  "activeForm": "Present continuous - what is being done"
}
```

**Examples**:
- `content: "Fetch issue details"` → `activeForm: "Fetching issue details"`
- `content: "Run quality gates"` → `activeForm: "Running quality gates"`
- `content: "Create pull request"` → `activeForm: "Creating pull request"`

---

## Command-Specific Templates

### Work Command Template

For the `/agency:work` command workflow:

```javascript
[
  {
    "content": "Fetch and analyze issue",
    "status": "pending",
    "activeForm": "Fetching and analyzing issue"
  },
  {
    "content": "Set up repository and branch",
    "status": "pending",
    "activeForm": "Setting up repository and branch"
  },
  {
    "content": "Generate implementation plan",
    "status": "pending",
    "activeForm": "Generating implementation plan"
  },
  {
    "content": "Select specialist(s) and get approval",
    "status": "pending",
    "activeForm": "Selecting specialist(s) and getting approval"
  },
  {
    "content": "Implement changes via specialist",
    "status": "pending",
    "activeForm": "Implementing changes via specialist"
  },
  {
    "content": "Run quality gates (build, type, lint, test)",
    "status": "pending",
    "activeForm": "Running quality gates"
  },
  {
    "content": "Conduct code review",
    "status": "pending",
    "activeForm": "Conducting code review"
  },
  {
    "content": "Commit changes with message",
    "status": "pending",
    "activeForm": "Committing changes"
  },
  {
    "content": "Create pull request",
    "status": "pending",
    "activeForm": "Creating pull request"
  }
]
```

### Implement Command Template

For the `/agency:implement` command workflow:

```javascript
[
  {
    "content": "Validate and parse plan file",
    "status": "pending",
    "activeForm": "Validating and parsing plan file"
  },
  {
    "content": "Select specialist(s) and get approval",
    "status": "pending",
    "activeForm": "Selecting specialist(s) and getting approval"
  },
  {
    "content": "Execute implementation via specialist",
    "status": "pending",
    "activeForm": "Executing implementation via specialist"
  },
  {
    "content": "Run quality gates (build, type, lint, test)",
    "status": "pending",
    "activeForm": "Running quality gates"
  },
  {
    "content": "Conduct code review",
    "status": "pending",
    "activeForm": "Conducting code review"
  },
  {
    "content": "Generate implementation summary",
    "status": "pending",
    "activeForm": "Generating implementation summary"
  }
]
```

### Sprint Command Template

For the `/agency:sprint` command (per issue):

```javascript
[
  {
    "content": "Fetch sprint issues",
    "status": "pending",
    "activeForm": "Fetching sprint issues"
  },
  {
    "content": "Work on issue 1 of N",
    "status": "pending",
    "activeForm": "Working on issue 1 of N"
  },
  {
    "content": "Work on issue 2 of N",
    "status": "pending",
    "activeForm": "Working on issue 2 of N"
  },
  // ... additional issues
  {
    "content": "Generate sprint summary",
    "status": "pending",
    "activeForm": "Generating sprint summary"
  }
]
```

### Deploy Command Template

For the `/agency:deploy` command workflow:

```javascript
[
  {
    "content": "Run pre-deployment checks",
    "status": "pending",
    "activeForm": "Running pre-deployment checks"
  },
  {
    "content": "Build production artifacts",
    "status": "pending",
    "activeForm": "Building production artifacts"
  },
  {
    "content": "Run security scans",
    "status": "pending",
    "activeForm": "Running security scans"
  },
  {
    "content": "Deploy to staging environment",
    "status": "pending",
    "activeForm": "Deploying to staging environment"
  },
  {
    "content": "Run smoke tests",
    "status": "pending",
    "activeForm": "Running smoke tests"
  },
  {
    "content": "Deploy to production",
    "status": "pending",
    "activeForm": "Deploying to production"
  },
  {
    "content": "Verify deployment health",
    "status": "pending",
    "activeForm": "Verifying deployment health"
  }
]
```

---

## Initialization Timing

### When to Initialize

**Initialize at the START** of the command, before any work begins:

```markdown
## Phase 1: Initialize Progress Tracking

Use TodoWrite tool to create todo list:

[Call TodoWrite with appropriate template]
```

### Set First Item to in_progress

Immediately after initialization, mark the first item as `in_progress`:

```javascript
[
  {
    "content": "Fetch and analyze issue",
    "status": "in_progress",  // ← Start first phase
    "activeForm": "Fetching and analyzing issue"
  },
  {
    "content": "Set up repository and branch",
    "status": "pending",
    "activeForm": "Setting up repository and branch"
  },
  // ... rest remain pending
]
```

---

## Dynamic Todo Lists

For variable-length workflows:

### Sprint with N Issues

```javascript
// Calculate issue count first
const issueCount = 5; // from sprint query

// Build dynamic todo list
const todos = [
  {
    content: "Fetch sprint issues",
    status: "in_progress",
    activeForm: "Fetching sprint issues"
  }
];

// Add one todo per issue
for (let i = 1; i <= issueCount; i++) {
  todos.push({
    content: `Work on issue ${i} of ${issueCount}`,
    status: "pending",
    activeForm: `Working on issue ${i} of ${issueCount}`
  });
}

// Add summary phase
todos.push({
  content: "Generate sprint summary",
  status: "pending",
  activeForm: "Generating sprint summary"
});
```

### Multi-Specialist Workflow

When multiple specialists are detected:

```javascript
[
  {
    "content": "Validate and parse plan file",
    "status": "in_progress",
    "activeForm": "Validating and parsing plan file"
  },
  {
    "content": "Select specialists (backend, frontend)",
    "status": "pending",
    "activeForm": "Selecting specialists"
  },
  {
    "content": "Backend implementation via backend-architect",
    "status": "pending",
    "activeForm": "Implementing backend via backend-architect"
  },
  {
    "content": "Frontend implementation via frontend-developer",
    "status": "pending",
    "activeForm": "Implementing frontend via frontend-developer"
  },
  {
    "content": "Integration verification",
    "status": "pending",
    "activeForm": "Verifying integration"
  },
  {
    "content": "Run quality gates",
    "status": "pending",
    "activeForm": "Running quality gates"
  },
  {
    "content": "Conduct code review",
    "status": "pending",
    "activeForm": "Conducting code review"
  },
  {
    "content": "Generate implementation summary",
    "status": "pending",
    "activeForm": "Generating implementation summary"
  }
]
```

---

## Best Practices

### 1. Granularity

**Good granularity** (5-10 items):
- Each phase is substantial (2-10 minutes)
- Phases are meaningful milestones
- User gets regular progress updates

**Too granular** (20+ items):
- Micro-tasks like "Read file", "Parse JSON"
- Updates are too frequent
- Clutters progress view

**Too coarse** (2-3 items):
- Phases are too large (30+ minutes)
- Long periods without progress updates
- User can't see what's happening

### 2. Naming Conventions

**Content** (imperative form):
- Start with action verb
- Be specific about what's happening
- Keep under 50 characters if possible

**Good**: "Run quality gates (build, type, lint, test)"
**Bad**: "Quality stuff"

**ActiveForm** (present continuous):
- Match the content exactly, but in -ing form
- Should read naturally: "Currently: [activeForm]"

**Good**: "Running quality gates"
**Bad**: "Quality gates are being run right now"

### 3. Status Management

**Critical rule**: Exactly ONE item should be `in_progress` at any time

**Never**:
```javascript
[
  {"status": "in_progress"}, // ← Two in_progress
  {"status": "in_progress"}, // ← WRONG!
  {"status": "pending"}
]
```

**Always**:
```javascript
[
  {"status": "completed"},   // ← Done
  {"status": "in_progress"}, // ← One active
  {"status": "pending"}      // ← Waiting
]
```

---

## Validation

After initialization:

- [ ] TodoWrite called with valid JSON array
- [ ] All items have required fields: content, status, activeForm
- [ ] Exactly ONE item is `in_progress` (the first one)
- [ ] All other items are `pending`
- [ ] Item count matches expected workflow phases (5-10 items)
- [ ] ActiveForm matches content (verb conjugation)

---

## Example Usage

```javascript
// Work command initialization
TodoWrite({
  todos: [
    {
      content: "Fetch and analyze issue",
      status: "in_progress",
      activeForm: "Fetching and analyzing issue"
    },
    {
      content: "Set up repository and branch",
      status: "pending",
      activeForm: "Setting up repository and branch"
    },
    {
      content: "Generate implementation plan",
      status: "pending",
      activeForm: "Generating implementation plan"
    },
    {
      content: "Select specialist(s) and get approval",
      status: "pending",
      activeForm: "Selecting specialist(s) and getting approval"
    },
    {
      content: "Implement changes via specialist",
      status: "pending",
      activeForm: "Implementing changes via specialist"
    },
    {
      content: "Run quality gates",
      status: "pending",
      activeForm: "Running quality gates"
    },
    {
      content: "Conduct code review",
      status: "pending",
      activeForm: "Conducting code review"
    },
    {
      content: "Commit and create pull request",
      status: "pending",
      activeForm: "Committing and creating pull request"
    }
  ]
});
```

---

## Notes

- Initialize todos BEFORE starting any actual work
- Keep first item as `in_progress` immediately after initialization
- Adjust templates based on command requirements
- For custom workflows, create task list dynamically
- Always validate JSON structure before calling TodoWrite
- Consider user experience - they see these todos in real-time
