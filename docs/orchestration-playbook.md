# Agency Orchestration Playbook

## Overview

This playbook provides practical guidance for using Agency orchestrators effectively. It covers when to use which orchestrator, best practices, common patterns, troubleshooting, and success metrics.

**Last Updated**: 2024-12-11
**Target Audience**: Users and AI assistants working with Agency plugin

---

## Table of Contents

1. [When to Use Orchestrators](#when-to-use-orchestrators)
2. [Orchestration Best Practices](#orchestration-best-practices)
3. [Common Patterns](#common-patterns)
4. [Troubleshooting](#troubleshooting)
5. [Metrics & Success](#metrics--success)
6. [Advanced Techniques](#advanced-techniques)

---

## When to Use Orchestrators

### Use `orchestrator-agent` When:

✅ **Multi-step workflows** requiring agent coordination
- Example: "Implement feature X with design, backend, and testing"
- Orchestrator coordinates multiple specialists across phases

✅ **Complex tasks** spanning multiple domains
- Example: "Add user authentication with UI, API, and database changes"
- Requires frontend, backend, and QA agents working together

✅ **Planning + implementation + review** workflows
- Example: GitHub issue needs full lifecycle (plan → code → test → PR)
- Orchestrator manages entire workflow with quality gates

✅ **Parallel execution opportunities** exist
- Example: "Build dashboard with 4 independent charts"
- Can spawn multiple agents simultaneously for faster completion

✅ **Flexible, ad-hoc workflows**
- Example: User requests vary, need adaptive orchestration
- General-purpose coordinator for any workflow pattern

**Command**: `/agency:work [issue]` or `/agency:plan [issue]`

**Typical Duration**: 15-60 minutes depending on complexity

---

### Use `agents-orchestrator` When:

✅ **Full autonomous pipeline** needed
- Example: Project has spec file, needs PM → Architect → Dev-QA → Integration
- Complete workflow from specification to production-ready code

✅ **Continuous Dev-QA loops** required
- Example: Each task must pass QA validation before advancing
- Built-in retry logic with quality enforcement

✅ **Project has specification file** and needs task breakdown
- Example: `project-specs/my-project-setup.md` exists
- Orchestrator reads spec, creates tasks, builds foundation, implements

✅ **Quality enforcement** with retry logic needed
- Example: Must ensure production readiness with evidence
- Defaults to rigorous quality gates, no shortcuts

✅ **Structured, repeatable pipelines**
- Example: Standard development workflow for all features
- Consistent process: senior PM → ux-architect → [dev ↔ QA] → integration

**Command**: `/agency:work` (with spec file context) or explicit spawn

**Typical Duration**: 30-120 minutes for complete pipeline

---

### Don't Use Orchestrators When:

❌ **Simple, single-agent tasks**
- Example: "Fix typo in README"
- Direct agent invocation is faster: just use frontend-developer

❌ **Research/exploration only**
- Example: "How does authentication work in this codebase?"
- Use explore agent directly, no orchestration needed

❌ **Single file, trivial changes**
- Example: "Update version number in package.json"
- No coordination required, simple edit

❌ **Pure conversational requests**
- Example: "Explain the difference between React and Vue"
- No code work needed, no orchestration required

---

## Orchestration Best Practices

### 1. Clear Scope Definition

**Before Orchestration**:
```markdown
✅ Good Scope:
"Add user login with Google OAuth. Include:
- Backend OAuth flow with Supabase
- Frontend login button and callback page
- Tests for authentication flow"

❌ Vague Scope:
"Make the app better"
```

**Best Practices**:
- Define task boundaries clearly
- List required deliverables explicitly
- Identify dependencies upfront
- Estimate complexity (simple/medium/high)
- Note any constraints or requirements

**Template**:
```markdown
## Task Scope

**Goal**: [One-sentence objective]

**Requirements**:
1. [Specific requirement 1]
2. [Specific requirement 2]
3. [Specific requirement 3]

**Out of Scope**:
- [Thing that's NOT included]
- [Thing to defer to later]

**Success Criteria**:
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
```

---

### 2. Intelligent Agent Selection

**Use Multi-Dimensional Matching**:

Refer to [Agent Catalog](/docs/agent-catalog.md) and evaluate:

1. **Domain** (30%): Does agent specialize in this area?
2. **Technology** (25%): Does agent know required tech stack?
3. **Complexity** (20%): Can agent handle this difficulty level?
4. **Phase** (15%): Is this the right project phase for this agent?
5. **Tools** (10%): Does agent have access to required tools?

**Selection Example**:
```markdown
Task: "Optimize API response time"

Domain: Backend/Performance (30 pts)
Technology: Node.js, database queries (25 pts)
Complexity: High - requires profiling (20 pts)
Phase: Optimization (15 pts)
Tools: Performance profiling tools (10 pts)

→ Selected: performance-benchmarker (analysis)
            + backend-architect (implementation)
→ Score: 95/100
```

**Quick Selection Guide**:
- **React/Vue UI**: frontend-developer (+ ui-designer for design)
- **Node.js API**: backend-architect (+ api-tester for testing)
- **Database**: backend-architect (+ performance-benchmarker for optimization)
- **Mobile**: mobile-app-builder
- **AI/ML**: ai-engineer
- **QA**: evidence-collector + reality-checker
- **Sprint Planning**: sprint-prioritizer
- **Architecture**: backend-architect + ux-architect

---

### 3. Effective Parallel Execution

**When to Parallelize**:
✅ Tasks modify different files
✅ No shared state mutations
✅ No explicit dependencies
✅ Same agent type can handle all tasks

**When to Stay Sequential**:
❌ Tasks share files or state
❌ One task depends on another
❌ Integration step required between tasks

**Dependency Detection Algorithm**:
```python
def can_run_parallel(task_a, task_b):
    # Check 1: File overlap
    if set(task_a.files) & set(task_b.files):
        return False  # Conflict

    # Check 2: Explicit dependencies
    if task_b.depends_on(task_a):
        return False  # Must be sequential

    # Check 3: Shared state
    if task_a.mutates_state() and task_b.reads_state():
        return False  # Race condition

    return True  # Safe to parallelize
```

**Context Isolation Pattern**:
```markdown
Each parallel agent gets:
✅ **Your Files** (you own, can modify)
✅ **Reference Files** (read-only)
✅ **API Contracts** (fixed, don't change)
❌ **Shared State** (prohibited)
❌ **Global Changes** (prohibited)
```

**Example - Good Parallelization**:
```markdown
E-commerce Product Page (4 components):

Parallel Tracks:
├─ Track A: frontend-developer → Gallery (src/components/gallery/)
├─ Track B: frontend-developer → Details (src/components/details/)
├─ Track C: frontend-developer → Reviews (src/components/reviews/)
└─ Track D: frontend-developer → Related (src/components/related/)

Each track gets isolated file ownership.
No shared state between components.

Integration (sequential after parallel):
└─ frontend-developer → Assemble ProductPage

Time: 15 min parallel + 10 min integration = 25 min
Sequential: 60 min → 73% time savings ✅
```

**Example - Bad Parallelization**:
```markdown
❌ DON'T DO THIS:

Parallel Tracks:
├─ Track A: backend-architect → Add user table
└─ Track B: backend-architect → Add posts table (references users)

Problem: Track B depends on Track A (foreign key)
Result: Track B fails, wastes time

✅ DO THIS INSTEAD:

Sequential:
1. backend-architect → Add user table
2. backend-architect → Add posts table (after users exists)
```

---

### 4. Quality Gate Enforcement

See [Quality Gates](/docs/quality-gates.md) for complete specification.

**Mandatory Gates** (always enforced):
1. **Planning**: User approval before implementation
2. **Build**: Code compiles successfully
3. **Test**: Tests pass or documented failures
4. **Review**: Code review completed

**Optional Gates** (context-dependent):
5. **Type Checking**: TypeScript/Python projects
6. **Linting**: Can proceed with warnings
7. **Performance**: Performance-critical features
8. **Accessibility**: UI features

**Best Practices**:
- ✅ Apply mandatory gates to all workflows
- ✅ Enable optional gates based on project context
- ✅ Implement retry logic (max 3 attempts)
- ✅ Escalate persistent failures to user with options
- ✅ Document gate bypasses with risk assessment

**Example - Gate Enforcement**:
```markdown
Phase 4: Implementation
  Task 1 → Build Gate → ✅ PASS
  Task 2 → Build Gate → ❌ FAIL (retry 1/3)
  Task 2 → Build Gate → ❌ FAIL (retry 2/3)
  Task 2 → Build Gate → ✅ PASS

Phase 5: Testing
  Test Gate → 90% pass rate → ✅ PASS

Phase 6: Review
  Review Gate → No critical issues → ✅ PASS

Result: All mandatory gates passed → Deploy ✅
```

---

### 5. Context Management

**Orchestrator Context Budget**:
| Request Type | Target Context Size |
|--------------|---------------------|
| Investigation | <2K tokens |
| Quick Fix | <1K tokens |
| Feature Plan | <4K tokens |
| Full Implementation | <6K tokens |

**What to RETAIN**:
✅ Task status (pending/in-progress/complete)
✅ Output artifact locations (file paths)
✅ Key decisions made
✅ Blockers requiring user input
✅ Success criteria checklist

**What to DISCARD**:
❌ Full file contents explored by agents
❌ Implementation details (live in agent outputs)
❌ Intermediate reasoning from agents
❌ Verbose logs or debug output

**Best Practices**:
- Use explore agent for research (keeps main context clean)
- Pass only necessary context to agents
- Retain summaries, not full outputs
- Document decisions and blockers concisely

---

## Common Patterns

### Pattern A: Independent Feature Tracks

**Use Case**: E-commerce product page with 4 components

**Structure**:
```
Components (parallel):
├─ Track A: frontend-developer → Image Gallery
├─ Track B: frontend-developer → Product Details
├─ Track C: frontend-developer → Reviews Section
└─ Track D: frontend-developer → Related Products

Integration (sequential):
└─ frontend-developer → Assemble ProductPage

QA (sequential):
└─ evidence-collector → Test complete page

Time: 15 min parallel + 10 min integration + 10 min QA = 35 min
Sequential: 60 min components + 10 min integration + 10 min QA = 80 min
Savings: 56% faster ✅
```

**When to Use**:
- Multiple independent UI components
- Each component has separate files
- No shared state between components
- Integration step is lightweight

**Orchestrator Command**:
```bash
/agency:work "Build product page with gallery, details, reviews, and related products"
```

---

### Pattern B: Parallel Review Dimensions

**Use Case**: Comprehensive code review

**Structure**:
```
Review Dimensions (parallel):
├─ Track A: reality-checker → Quality & bugs
├─ Track B: performance-benchmarker → Performance
├─ Track C: api-tester → API contracts
├─ Track D: legal-compliance-checker → Security & compliance
└─ Track E: senior-developer → Architecture & patterns

Synthesis (sequential):
└─ orchestrator → Aggregate findings, prioritize issues

Time: 20 min parallel + 10 min synthesis = 30 min
Sequential: 100 min reviews + 10 min synthesis = 110 min
Savings: 73% faster ✅
```

**When to Use**:
- Pre-release comprehensive review
- Multiple review dimensions needed
- Each reviewer checks different aspects
- Final synthesis aggregates findings

**Orchestrator Command**:
```bash
/agency:review "Comprehensive pre-release review of authentication feature"
```

---

### Pattern C: Staged Parallel Execution

**Use Case**: Full-stack feature with dependencies

**Structure**:
```
Stage 1 (parallel):
├─ Track A: backend-architect → Database schema
└─ Track B: ui-designer → UI mockups

Stage 2 (parallel, depends on Stage 1):
├─ Track A: backend-architect → API endpoints (needs schema)
└─ Track B: frontend-developer → UI components (needs mockups)

Stage 3 (sequential, depends on Stage 2):
└─ frontend-developer → Integration (needs both API + UI)

Stage 4 (sequential):
└─ reality-checker → E2E testing

Time: 20 min (Stage 1) + 30 min (Stage 2) + 20 min (Stage 3) + 15 min (Stage 4) = 85 min
Fully Sequential: 20 + 30 + 30 + 20 + 15 = 115 min
Savings: 26% faster ✅
```

**When to Use**:
- Full-stack features
- Design and backend can start together
- Implementation depends on both design and backend
- Integration requires all pieces

**Orchestrator Command**:
```bash
/agency:work "Implement user profile page with database, API, and UI"
```

---

### Pattern D: Design → Implementation → QA

**Use Case**: UI feature requiring design, implementation, and validation

**Structure**:
```
Phase 1: Design
└─ ui-designer → Design specs, mockups, component library

Phase 2: Implementation
└─ frontend-developer → Implement components per design

Phase 3: QA
└─ evidence-collector → Screenshot testing, accessibility check

Time: 15 min design + 30 min implementation + 15 min QA = 60 min
```

**When to Use**:
- User-facing UI features
- Design consistency important
- Need visual validation
- Accessibility requirements

**Orchestrator Command**:
```bash
/agency:work "Design and implement new dashboard with data visualizations"
```

---

### Pattern E: PM → Architect → Dev-QA Loops

**Use Case**: Project with specification file needing complete workflow

**Structure**:
```
Phase 1: Task Breakdown
└─ senior (PM) → Read spec, create task list

Phase 2: Foundation
└─ ux-architect → Build technical foundation, CSS system

Phase 3: Dev-QA Loops (task-by-task)
For each task:
  ├─ developer → Implement task
  ├─ evidence-collector → QA validation
  └─ If FAIL: Loop with feedback (max 3 retries)

Phase 4: Integration
└─ reality-checker → Final validation, production readiness

Time: 10 min PM + 20 min architect + (15 min × 8 tasks) + 15 min integration = 165 min
```

**When to Use**:
- Complete project pipeline
- Specification file exists
- Quality enforcement needed
- Autonomous workflow desired

**Orchestrator Command**:
```bash
# Spawn agents-orchestrator directly
"Please spawn an agents-orchestrator to execute complete development pipeline for project-specs/my-project-setup.md"
```

---

## Troubleshooting

### Issue: Agent Selection Wrong

**Symptoms**:
- Agent doesn't know required technology
- Agent lacks necessary tools
- Task complexity doesn't match agent capability

**Diagnosis**:
1. Check [Agent Catalog](/docs/agent-catalog.md) for agent capabilities
2. Verify agent has required skills (check skills section in agent file)
3. Check agent tools list matches task requirements
4. Assess task complexity vs agent rating

**Solutions**:
- **Quick Fix**: Manually select better agent using catalog
- **Root Cause**: Improve task description with more context
- **Prevention**: Use selection dimensions (domain, tech, complexity, phase, tools)

**Example**:
```markdown
Problem: orchestrator selected rapid-prototyper for production feature

Root Cause: Task described as "quick implementation" → triggered prototyper

Fix: Clarify scope: "Production-ready user authentication with OAuth, tests, and security review"

Result: orchestrator now selects backend-architect + senior-developer ✅
```

---

### Issue: Parallel Execution Conflicts

**Symptoms**:
- Tasks fail with "file already modified" errors
- Race conditions in shared state
- Merge conflicts during integration

**Diagnosis**:
1. Check if tasks modify overlapping files
2. Review shared state dependencies
3. Verify no implicit dependencies exist

**Solutions**:
- **Immediate**: Fall back to sequential execution
- **Fix**: Better file isolation (separate directories)
- **Prevention**: Run dependency detection before parallelizing

**Example**:
```markdown
Problem: Two tasks tried to modify same config file

Diagnosis:
Task A: Update API endpoints in config.ts
Task B: Add authentication in config.ts
→ Both modifying config.ts simultaneously

Fix: Make sequential or split config:
- config/api.ts (Task A)
- config/auth.ts (Task B)

Result: No conflicts, can parallelize ✅
```

---

### Issue: Quality Gate Failures

**Symptoms**:
- Tests failing repeatedly
- Build errors not resolving
- Retry limit reached (3 attempts)

**Diagnosis**:
1. Review gate failure messages
2. Check retry count (<3?)
3. Examine error patterns across retries

**Solutions**:
- **Retry 1-2**: Provide more context to agent
- **Retry 3**: Try different approach or specialist agent
- **Escalate**: Present options to user (skip, modify, abort, debug)

**Example**:
```markdown
Problem: Test gate failing on TypeScript type errors

Attempt 1: Agent fixes obvious type mismatches → Still failing
Attempt 2: Agent updates interfaces → Still failing
Attempt 3: Agent simplifies types → Still failing

Escalation:
Option 1: Skip type checking (⚠️ Risk: Runtime errors)
Option 2: Switch to JavaScript (Trade-off: Lose type safety)
Option 3: Call senior-developer for deep dive (Recommended ✅)

User selected: Option 3
Result: senior-developer found root cause (circular dependency), fixed ✅
```

---

### Issue: Context Budget Exceeded

**Symptoms**:
- Orchestrator context growing too large (>6K tokens)
- Responses become slower
- Agent selection quality degrades

**Diagnosis**:
1. Check what's being retained in context
2. Identify verbose agent outputs
3. Review if full file contents are being kept

**Solutions**:
- **Immediate**: Summarize agent outputs before retaining
- **Systemic**: Use explore agent for research (separate context)
- **Prevention**: Discard implementation details, keep only artifacts

**Example**:
```markdown
Problem: Context at 8K tokens after 3 tasks

Diagnosis:
- Retained full file contents from each task (4K tokens)
- Kept verbose agent reasoning (2K tokens)
- Stored intermediate outputs (2K tokens)

Fix:
- Discard file contents, keep only paths
- Remove intermediate reasoning
- Retain only: task status, decisions, blockers

Result: Context reduced to 2K tokens ✅
```

---

### Issue: Orchestrator Not Selected

**Symptoms**:
- User expects orchestration but direct agent used instead
- Multi-step workflow not coordinated

**Diagnosis**:
1. Check if request keywords suggest orchestration
2. Verify task complexity warrants orchestration
3. Assess if multiple agents truly needed

**Solutions**:
- **Fix**: Explicitly invoke orchestrator using `/agency:work`
- **Education**: Update request with orchestration keywords
- **Validation**: Confirm orchestration is actually needed (vs single agent)

**Example**:
```markdown
Request: "Fix bug in login"
Result: Single agent used (frontend-developer) ✅

Request: "Add login with Google, tests, and security review"
Result: Orchestrator coordinates multiple agents ✅
```

---

## Metrics & Success

### Target KPIs

Track these metrics to measure orchestration effectiveness:

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Time Savings from Parallel Execution** | >40% | (Sequential time - Parallel time) / Sequential time |
| **First-Attempt Quality Gate Pass Rate** | ≥85% | % of tasks passing gates on first try |
| **Average Retries per Task** | <2.0 | Total retries / Total tasks |
| **Agent Selection Accuracy** | ≥95% | % of selected agents completing task successfully |
| **Context Efficiency** | <6K tokens | Orchestrator context size for full implementations |
| **User Satisfaction** | ≥4.5/5 | Post-workflow survey rating |

### Measurement Example

```markdown
# Orchestration Metrics - Sprint 42

## Performance
- **Workflows Completed**: 12
- **Average Duration**: 35 minutes
- **Parallel Execution Used**: 8 workflows (67%)
- **Time Savings**: 45% average (target: >40%) ✅

## Quality
- **First-Attempt Pass Rate**: 87.5% (target: ≥85%) ✅
- **Average Retries**: 1.2 per task (target: <2.0) ✅
- **Agent Selection Accuracy**: 96% (target: ≥95%) ✅

## Efficiency
- **Average Context Size**: 4.8K tokens (target: <6K) ✅
- **Escalation Rate**: 3.2% (target: <5%) ✅

## Satisfaction
- **User Rating**: 4.7/5 (target: ≥4.5/5) ✅
- **Positive Feedback**: 11/12 workflows
- **Would Use Again**: 100%

## Top Patterns Used
1. Design → Implementation → QA (5 workflows)
2. Parallel Review Dimensions (3 workflows)
3. Independent Feature Tracks (2 workflows)
4. PM → Architect → Dev-QA (2 workflows)
```

### Success Indicators

✅ **High Quality**:
- First-attempt pass rates >85%
- Low retry counts (<2.0 avg)
- Few escalations (<5%)

✅ **High Efficiency**:
- Time savings >40% with parallel execution
- Context stays <6K tokens
- Workflows complete in expected time

✅ **High Satisfaction**:
- Users rate ≥4.5/5
- Would use orchestration again
- Recommend to others

⚠️ **Warning Signs**:
- Pass rates dropping below 80%
- Retry counts increasing (>2.5 avg)
- Frequent escalations (>10%)
- Context bloat (>8K tokens)
- Users requesting simpler approaches

---

## Advanced Techniques

### Technique 1: Adaptive Parallel Batching

**Concept**: Dynamically adjust batch size based on task success rates

**Implementation**:
```python
def calculate_batch_size(tasks, quality_metrics):
    # Start with standard batch size
    batch_size = 4

    # Adjust based on first-attempt pass rate
    if quality_metrics.first_attempt_pass_rate > 0.90:
        batch_size = 6  # High quality, increase parallelism
    elif quality_metrics.first_attempt_pass_rate < 0.75:
        batch_size = 2  # Low quality, reduce parallelism

    # Adjust based on retry rate
    if quality_metrics.avg_retries > 2.5:
        batch_size = max(1, batch_size - 1)  # High retries, be conservative

    return min(batch_size, len(tasks))
```

**Benefits**:
- Maximize speed when quality is high
- Reduce conflicts when quality is lower
- Self-regulating based on actual performance

---

### Technique 2: Predictive Agent Selection

**Concept**: Learn from past agent selections to improve future accuracy

**Implementation**:
```python
def select_agent_with_history(task, agent_history):
    # Calculate scores for all agents
    scores = {}
    for agent in available_agents:
        base_score = score_agent_match(agent, task)

        # Boost score if agent succeeded on similar tasks
        similar_tasks = find_similar_tasks(task, agent_history)
        success_rate = calculate_success_rate(agent, similar_tasks)

        # Apply learning factor
        learned_score = base_score * (1 + (success_rate - 0.5))
        scores[agent] = learned_score

    return max(scores, key=scores.get)
```

**Benefits**:
- Improves accuracy over time
- Learns project-specific patterns
- Adapts to team strengths

---

### Technique 3: Context Compression

**Concept**: Automatically summarize and compress context to stay within budget

**Implementation**:
```python
def compress_context(context, target_size=4000):
    current_size = estimate_tokens(context)

    if current_size <= target_size:
        return context  # No compression needed

    # Priority 1: Keep critical info (status, decisions, blockers)
    critical = extract_critical_info(context)

    # Priority 2: Summarize agent outputs
    summaries = summarize_agent_outputs(context)

    # Priority 3: Discard verbose details
    compressed = {
        "critical": critical,
        "summaries": summaries,
        "artifacts": context["artifacts"]  # Keep file paths
    }

    return compressed
```

**Benefits**:
- Maintains performance even for complex workflows
- Keeps focus on important information
- Prevents context bloat

---

### Technique 4: Smart Retry Strategy

**Concept**: Vary retry approach based on error patterns

**Implementation**:
```python
def smart_retry(task, error, attempt):
    if attempt == 1:
        # First retry: Fix obvious issues
        return "Fix the immediate error: " + error.message

    elif attempt == 2:
        # Second retry: Change approach
        if "type error" in error.message:
            return "Simplify types or add type assertions"
        elif "test failure" in error.message:
            return "Add guards or edge case handling"

    elif attempt == 3:
        # Third retry: Call specialist
        specialist = select_specialist_for_error(error)
        return f"Spawn {specialist} to investigate and fix"

    else:
        # Escalate after 3 attempts
        return escalate_to_user(error, task)
```

**Benefits**:
- Faster recovery from errors
- Appropriate escalation of complex issues
- Better success rates

---

## Quick Reference

### Command Cheatsheet

| Command | Orchestrator | Use Case |
|---------|--------------|----------|
| `/agency:plan [issue]` | orchestrator-agent | Create execution plan, no implementation |
| `/agency:work [issue]` | orchestrator-agent | Full workflow with orchestration |
| `/agency:implement [plan]` | orchestrator-agent | Execute approved plan |
| Spawn agents-orchestrator | agents-orchestrator | Complete PM → Architect → Dev-QA pipeline |

### Pattern Selection Matrix

| Scenario | Pattern | Time Savings |
|----------|---------|--------------|
| Multiple independent components | Pattern A: Independent Tracks | 50-60% |
| Comprehensive review needed | Pattern B: Parallel Review | 70-75% |
| Full-stack with dependencies | Pattern C: Staged Parallel | 25-30% |
| UI feature with design | Pattern D: Design → Impl → QA | N/A (sequential) |
| Project with spec file | Pattern E: PM → Arch → Dev-QA | N/A (complete pipeline) |

### Troubleshooting Flowchart

```
Issue? →
  Agent selection wrong?
    → Check catalog, verify skills/tools
  Parallel conflicts?
    → Check file overlap, fall back to sequential
  Quality gate failures?
    → Provide context, try specialist, escalate
  Context budget exceeded?
    → Summarize outputs, discard details
  Orchestrator not selected?
    → Use explicit command, add keywords
```

---

## Related Documentation

- **[Agent Catalog](/docs/agent-catalog.md)**: Complete agent reference with selection guide
- **[Quality Gates](/docs/quality-gates.md)**: Quality standards and enforcement

---

**Last Review**: 2024-12-11
**Next Review**: 2025-03-11 (Quarterly)
**Feedback**: Create issue in agency plugin repository with `orchestration` label
