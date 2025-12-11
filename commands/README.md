# Agency Commands

Composable workflow commands for automating the complete software development lifecycle.

## Command Namespace

All agency commands use the `agency:` prefix to avoid conflicts:
- `/agency:work` instead of `/work`
- `/agency:plan` instead of `/plan`

## Available Commands

### Core Workflow Commands

#### `/agency:work`
Work on any issue (auto-detects GitHub/Jira)

**Usage**:
```bash
/agency:work 123              # Work on issue #123
/agency:work next             # Work on next available issue
/agency:work https://...      # Work on issue from URL
```

**Flow**: Fetch → Plan → Review Plan → Implement → Test → Review → PR

**Agents Used**: Orchestrator → Plan → Specialist Reviewer → Specialist Coder → Reality Checker

---

#### `/agency:plan`
Create implementation plan only (no execution)

**Usage**:
```bash
/agency:plan 123              # Plan for issue #123
/agency:plan "add dark mode"  # Plan from description
```

**Flow**: Analyze → Research → Plan → Review → Present

**Agents Used**: Orchestrator → Explore → Plan → Specialist Reviewer

---

#### `/agency:implement`
Implement from existing plan

**Usage**:
```bash
/agency:implement <plan-file>
```

**Flow**: Load Plan → Implement → Test → Review → Commit

**Agents Used**: Orchestrator → Specialist Coder → Reality Checker

---

### GitHub Workflow Commands

#### `/agency:gh-sprint`
Implement entire GitHub sprint

**Usage**:
```bash
/agency:gh-sprint                    # Current sprint
/agency:gh-sprint milestone-name     # Specific milestone
```

**Flow**: Fetch Issues → Prioritize → Find Parallel → Execute Batches → Monitor

**Agents Used**: Orchestrator → Sprint Prioritizer → Multiple specialists in parallel

---

#### `/agency:gh-triage`
Triage GitHub issues

**Usage**:
```bash
/agency:gh-triage                  # Triage open issues
/agency:gh-triage label:bug        # Triage specific label
```

**Flow**: Fetch Issues → Analyze → Categorize → Prioritize → Update Labels

**Agents Used**: Orchestrator → Senior Project Manager

---

#### `/agency:gh-parallel`
Find parallelizable GitHub issues

**Usage**:
```bash
/agency:gh-parallel              # Find all parallelizable work
/agency:gh-parallel sprint       # Only in current sprint
```

**Flow**: Fetch Issues → Analyze Dependencies → Group Independent → Report

**Agents Used**: Orchestrator → Senior Project Manager

---

#### `/agency:gh-worktree`
Create git worktree for issue

**Usage**:
```bash
/agency:gh-worktree 123          # Create worktree for issue #123
```

**Flow**: Fetch Issue → Create Branch → Create Worktree → Setup Environment

---

### Jira Workflow Commands

#### `/agency:jira-sprint`
Implement entire Jira sprint

**Usage**:
```bash
/agency:jira-sprint                # Current sprint
/agency:jira-sprint SPRINT-123     # Specific sprint
```

**Flow**: Fetch Issues → Prioritize → Find Parallel → Execute Batches → Monitor

---

#### `/agency:jira-triage`
Triage Jira issues

**Usage**:
```bash
/agency:jira-triage               # Triage backlog
/agency:jira-triage project-key   # Specific project
```

**Flow**: Fetch Issues → Analyze → Categorize → Prioritize → Update Jira

---

### Quality & Review Commands

#### `/agency:review`
Comprehensive code review

**Usage**:
```bash
/agency:review                    # Review current changes
/agency:review PR-123             # Review specific PR
```

**Flow**: Security Review || Quality Review || Performance Review || Test Review → Synthesis

**Agents Used**: Legal Compliance Checker + Reality Checker + Performance Benchmarker + Test Results Analyzer (parallel)

---

#### `/agency:test`
Generate comprehensive tests

**Usage**:
```bash
/agency:test                      # Test current changes
/agency:test <file-path>          # Test specific file
```

**Flow**: Analyze Code → Generate Unit Tests → Generate Integration Tests → Generate E2E Tests → Review Coverage

**Agents Used**: Orchestrator → Testing Specialist

---

#### `/agency:security`
Security audit workflow

**Usage**:
```bash
/agency:security                  # Audit current changes
/agency:security --full           # Full codebase audit
```

**Flow**: Vulnerability Scan → Code Review → Dependency Check → Report

**Agents Used**: Legal Compliance Checker

---

### Optimization Commands

#### `/agency:optimize`
Performance optimization workflow

**Usage**:
```bash
/agency:optimize                  # Optimize current code
/agency:optimize --profile        # Profile first, then optimize
```

**Flow**: Profile → Identify Bottlenecks → Optimize → Benchmark → Verify

**Agents Used**: Performance Benchmarker → Backend/Frontend specialist

---

#### `/agency:refactor`
Refactoring workflow

**Usage**:
```bash
/agency:refactor <file-or-pattern>
```

**Flow**: Analyze → Plan Refactoring → Execute → Test → Review

**Agents Used**: Senior Developer → Reality Checker

---

### Documentation Commands

#### `/agency:document`
Generate documentation

**Usage**:
```bash
/agency:document                  # Document current changes
/agency:document <file-path>      # Document specific file
/agency:document --api            # Generate API docs
```

**Flow**: Analyze Code → Generate Docs → Review → Format

---

#### `/agency:adr`
Create Architecture Decision Record

**Usage**:
```bash
/agency:adr "use PostgreSQL for persistence"
```

**Flow**: Context → Decision → Consequences → Document

---

## Command Implementation Status

### Phase 1 (Initial Release)
- [ ] `/agency:work` - Core workflow command
- [ ] `/agency:plan` - Planning only
- [ ] `/agency:review` - Code review

### Phase 2
- [ ] `/agency:gh-sprint` - Sprint automation
- [ ] `/agency:gh-triage` - Issue triage
- [ ] `/agency:gh-parallel` - Parallel work finder
- [ ] `/agency:test` - Test generation

### Phase 3
- [ ] `/agency:implement` - From existing plan
- [ ] `/agency:optimize` - Performance optimization
- [ ] `/agency:refactor` - Refactoring workflow
- [ ] `/agency:document` - Documentation generation

### Phase 4
- [ ] `/agency:gh-worktree` - Worktree creation
- [ ] `/agency:jira-sprint` - Jira sprint automation
- [ ] `/agency:jira-triage` - Jira triage
- [ ] `/agency:security` - Security audit
- [ ] `/agency:adr` - ADR creation

## Command Design Principles

### 1. Composability
Commands should work together:
```bash
/agency:plan 123
# Review plan, make changes
/agency:implement plan.md
```

### 2. Intelligent Defaults
Commands should work without configuration:
```bash
/agency:work next    # Auto-detects next issue
```

### 3. Progressive Enhancement
Commands support flags for advanced usage:
```bash
/agency:work 123 --auto-approve --model opus --no-tests
```

### 4. Consistent Patterns
All commands follow similar structure:
- Fetch/Analyze phase
- Planning/Strategy phase
- Execution phase
- Verification phase
- Delivery phase

### 5. Checkpoint Strategy
Commands pause for user approval at key points:
- After planning (before implementation)
- Before destructive operations
- When ambiguity detected

## Outstanding Design Questions

See `enhancements/outstanding-questions/` for detailed design questions about:
- `q1-command-priority-selection.md` - Which commands to implement first
- `q2-interactive-vs-automated-commands.md` - Interactive vs automated behavior
- `q3-command-argument-patterns.md` - Argument format support

## Creating New Commands

To create a new command:

1. Create `commands/agency-{name}.md`
2. Add frontmatter:
```markdown
---
description: Brief description of what this command does
argument-hint: Hint text shown to user
allowed-tools: [Read, Write, Edit, Bash, Task]
---
```

3. Write instructions FOR Claude (not TO user)
4. Reference relevant skills and agents
5. Define phases and checkpoints
6. Include error handling

See existing commands for examples.

## Related Documentation

- `skills/agency-workflow-patterns/` - Orchestration patterns
- `skills/github-workflow-best-practices/` - GitHub workflows
- `agents/orchestrator.md` - Orchestrator agent
- `enhancements/outstanding-questions/` - Design decisions

