# Agency Orchestration Playbook

## Overview

This playbook provides practical guidance for using Agency orchestrators effectively. It covers when to use which orchestrator, best practices, common patterns, troubleshooting, and success metrics.

**Last Updated**: 2024-12-12
**Target Audience**: Users and AI assistants working with Agency plugin

---

## Table of Contents

1. [When to Use Orchestrators](#when-to-use-orchestrators)
2. [Orchestration Best Practices](#orchestration-best-practices)
3. [Common Patterns](#common-patterns)
4. [Multi-Specialist Workflows](#multi-specialist-workflows)
5. [Prompt Component Architecture](#prompt-component-architecture)
6. [Troubleshooting](#troubleshooting)
7. [Metrics & Success](#metrics--success)
8. [Advanced Techniques](#advanced-techniques)

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

Refer to [Agent Catalog](/docs/agent-catalog.md) and [Multi-Specialist Workflows](#multi-specialist-workflows) section for specialist selection. Evaluate:

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

See [Quality Gates](/docs/quality-gates.md) for complete specification and [Prompt Component Architecture](#prompt-component-architecture) for implementation details.

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

## Multi-Specialist Workflows

Modern features often require coordination between multiple specialists (frontend, backend, mobile, AI/ML, DevOps). Agency's multi-specialist workflow system provides structured handoff coordination, dependency management, and integrated verification.

### Overview

**Single-Specialist vs Multi-Specialist**:

| Aspect | Single-Specialist | Multi-Specialist |
|--------|------------------|------------------|
| Selection | One specialist chosen | Multiple specialists scored |
| Execution | Direct implementation | Sequential or parallel with handoffs |
| Verification | Single code review | Per-specialist + integrated review |
| Coordination | None needed | Handoff directory system |
| Complexity | Simple | Higher, but systematic |

**When Multi-Specialist Mode Activates**:
- 2+ specialists score > 2.0 in keyword analysis
- Plan explicitly mentions full-stack work
- Cross-layer integration required (UI + API + Database)
- Mobile and web components both needed
- AI/ML integration with frontend/backend

---

### How Multi-Specialist Detection Works

**Keyword Scoring Algorithm**:

Each specialist has a set of technology keywords. The system scans the plan/issue and scores each specialist:

**Frontend Developer** (+0.5 per match):
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
- TypeScript, Component, UI, Tailwind
- shadcn, Form, Animation

**Backend Architect** (+0.5 per match):
- API, REST, GraphQL, tRPC
- Database, SQL, Prisma, MongoDB
- Authentication, JWT, Middleware
- Schema, Migration, Endpoint

**Mobile App Builder** (+0.5 per match):
- React Native, Expo, iOS, Android
- SwiftUI, Flutter, Mobile app
- Touch, Gesture, Push notification

**AI Engineer** (+0.5 per match):
- Machine learning, ML, AI, LLM
- Embeddings, Vector database
- TensorFlow, PyTorch, Mastra
- RAG, Prompt engineering

**DevOps Automator** (+0.5 per match):
- Docker, Kubernetes, CI/CD
- Deployment, AWS, GCP, Azure
- Terraform, Monitoring, Pipeline

**Threshold**: Score > 2.0 → Specialist is needed

**Example**:
```markdown
Plan mentions: "Add user authentication with React login form,
Node.js API endpoints, JWT tokens, and PostgreSQL database"

Keyword Analysis:
- Frontend: React (0.5) + form (0.5) = 1.0 ❌ (below threshold)
- Backend: API (0.5) + endpoints (0.5) + JWT (0.5) +
           PostgreSQL (0.5) + database (0.5) + authentication (0.5) = 3.0 ✅
- Mobile: 0.0 ❌
- AI: 0.0 ❌
- DevOps: 0.0 ❌

Decision: Backend only (single-specialist)
```

```markdown
Plan mentions: "Build full-stack dashboard with React components,
Next.js pages, REST API, Prisma schema, PostgreSQL migrations"

Keyword Analysis:
- Frontend: React (0.5) + components (0.5) + Next.js (0.5) +
            pages (0.5) + UI (0.5) = 2.5 ✅
- Backend: REST (0.5) + API (0.5) + Prisma (0.5) + PostgreSQL (0.5) +
           schema (0.5) + migrations (0.5) = 3.0 ✅
- Mobile: 0.0 ❌
- AI: 0.0 ❌
- DevOps: 0.0 ❌

Decision: Multi-specialist (Frontend + Backend)
```

---

### Execution Strategy Selection

Once multiple specialists are detected, the system determines whether they should work sequentially or in parallel.

#### Sequential Execution

**Use when dependencies exist between specialists**:

**Backend → Frontend dependency indicators**:
- "Frontend needs backend API"
- "UI calls authentication endpoint"
- "Component fetches data from API"
- "Dashboard displays database data"
- "Frontend consumes REST/GraphQL endpoints"

**Backend → Mobile dependency indicators**:
- "Mobile app consumes API"
- "App syncs with server"
- "Mobile authenticates with backend"

**AI → Backend → Frontend chain**:
- "Backend integrates ML model"
- "API serves AI predictions"
- "UI displays ML recommendations"

**DevOps → Any dependency**:
- "Requires deployment before testing"
- "Needs infrastructure setup first"

**Execution Order**:
```
Typical chains:
1. DevOps → Backend → Frontend/Mobile
2. Backend → AI → Frontend
3. AI → Backend → Frontend (if backend integrates AI model)
```

**Example**:
```markdown
Plan: "Add user profile with React UI consuming Node.js API
endpoints that query PostgreSQL"

Strategy: Sequential
Order: Backend → Frontend
Reason: "Frontend consumes API endpoints" (clear dependency)

Execution:
1. Backend Architect → Implement API + database
2. Verify backend work
3. Frontend Developer → Implement UI consuming APIs
4. Verify frontend work
5. Integrated review
```

#### Parallel Execution

**Use when work is independent**:

**Independence indicators**:
- "Separate admin dashboard"
- "Independent API changes"
- "Standalone service"
- "Different codebases/repositories"
- "Background job processing"
- "No shared interfaces"

**Safe Default**: When unclear, use sequential execution to avoid integration conflicts.

**Example**:
```markdown
Plan: "Build admin dashboard (React) and background job
processor (Node.js worker) - separate systems"

Strategy: Parallel
Reason: "Admin dashboard and worker are independent systems"

Execution:
1. Spawn both specialists simultaneously
2. Each works autonomously
3. Both complete independently
4. Verify each specialist
5. Light integration review
```

---

### Handoff Directory Structure

Multi-specialist workflows use a structured handoff directory system for coordination:

**Directory Layout**:
```
.agency/handoff/${FEATURE_NAME}/
├── execution-state.json          # Overall progress tracking
├── integration/
│   ├── api-contract.md          # Shared API contracts
│   ├── type-definitions.ts      # Shared TypeScript types
│   └── integration-tests.md     # Cross-specialist test plan
├── backend-architect/
│   ├── plan.md                  # Backend-specific tasks
│   ├── summary.md               # Completion report
│   ├── verification.md          # Code review results
│   └── files-changed.json       # File tracking
├── frontend-developer/
│   ├── plan.md
│   ├── summary.md
│   ├── verification.md
│   └── files-changed.json
├── mobile-app-builder/
│   └── [same structure...]
└── archive/
    └── handoff-${TIMESTAMP}.tar.gz  # Archived after completion
```

**Purpose of Each Directory**:

1. **`execution-state.json`**: Tracks which specialists are pending/in_progress/completed, their scores, dependencies, and verification status

2. **`integration/`**: Shared contracts and interfaces that cross specialist boundaries (API contracts, type definitions, integration tests)

3. **`${SPECIALIST}/plan.md`**: Auto-generated from main plan, filtered for specialist's domain with handoff requirements

4. **`${SPECIALIST}/summary.md`**: Created by specialist documenting work completed, integration points, and handoff notes

5. **`${SPECIALIST}/verification.md`**: Created by reality-checker with code review findings (CRITICAL/HIGH/MEDIUM/LOW)

6. **`${SPECIALIST}/files-changed.json`**: Tracks created/modified/deleted files for dependency detection

**Example `execution-state.json`**:
```json
{
  "feature": "user-authentication",
  "plan_file": ".agency/plans/auth-feature-plan.md",
  "execution_strategy": "sequential",
  "created_at": "2024-12-11T14:30:00Z",
  "current_phase": "execution",
  "specialists": [
    {
      "name": "backend-architect",
      "status": "completed",
      "score": 3.5,
      "keywords_matched": ["API", "database", "JWT", "Prisma"],
      "verification": "passed",
      "dependencies_met": true,
      "started_at": "2024-12-11T14:35:00Z",
      "completed_at": "2024-12-11T15:20:00Z",
      "duration_minutes": 45
    },
    {
      "name": "frontend-developer",
      "status": "in_progress",
      "score": 2.5,
      "keywords_matched": ["React", "component", "form"],
      "verification": null,
      "dependencies_met": true,
      "started_at": "2024-12-11T15:25:00Z",
      "completed_at": null
    }
  ]
}
```

---

### Per-Specialist Verification Workflow

Each specialist undergoes individual verification before handoff:

**Verification Process** (per specialist):

```
1. Specialist Completes Work
   - Creates summary.md with work documentation
   - Creates files-changed.json with file tracking
   - Marks ready for verification

2. Reality-Checker Verification
   - Spawned with specialist's context
   - Reviews plan.md vs summary.md for compliance
   - Checks code quality, security, tests
   - Writes findings to verification.md
   - Severity levels: CRITICAL, HIGH, MEDIUM, LOW

3. Fix Loop (if CRITICAL/HIGH issues found)
   - Specialist fixes issues (max 3 iterations)
   - Re-verification after each fix
   - If still failing after 3 attempts → escalate to user

4. Verification Passed
   - Update execution-state.json (status: completed)
   - Unblock dependent specialists
   - Archive specialist artifacts
```

**Verification Checklist** (per specialist):
- ✅ Plan compliance (all tasks completed)
- ✅ Code quality (no bugs, proper error handling)
- ✅ Security (no vulnerabilities at boundaries)
- ✅ Tests (adequate coverage, all passing)
- ✅ Integration points documented (for next specialist)

**Example verification.md**:
```markdown
# Verification: Backend Architect - User Authentication

**Specialist**: backend-architect
**Feature**: user-authentication
**Status**: PASSED ✅

## Plan Compliance ✅
- ✅ Authentication API endpoints implemented
- ✅ Database schema created
- ✅ JWT token generation working
- ✅ All planned files created

## Code Quality ✅
- ✅ Proper error handling in API routes
- ✅ Password hashing implemented correctly
- ✅ No hardcoded secrets

## Security ✅
- ✅ SQL injection prevention (Prisma ORM)
- ✅ Password validation rules enforced
- ✅ JWT secret in environment variables

## Tests ✅
- ✅ Unit tests for auth logic (87% coverage)
- ✅ Integration tests for API endpoints
- ✅ All tests passing

## Integration Points ✅
- ✅ API contract documented in integration/api-contract.md
- ✅ TypeScript types exported for frontend
- ✅ Clear handoff notes in summary.md

## Issues Found
None - ready for frontend handoff
```

---

### Integration Validation Across Specialists

After all specialists complete individual verification, an integrated review checks cross-boundary consistency:

**Integrated Review Focus**:

1. **Cross-Specialist Integration**
   - API contracts match between backend and frontend/mobile
   - Type definitions consistent across boundaries
   - Error handling aligned
   - Authentication flows work end-to-end

2. **Code Consistency**
   - Naming conventions aligned
   - Code style uniform across specialists
   - Patterns consistent
   - No conflicting approaches

3. **Architecture Coherence**
   - Components work together cohesively
   - No architectural conflicts
   - Scalability maintained
   - Design principles followed

4. **Security Across Boundaries**
   - Authentication complete at all layers
   - Authorization checks at boundaries
   - Data validation at system edges
   - No security gaps between specialists

**Integration Review Spawn**:
```
Tool: Task
Subagent: code-reviewer
Context: Multi-specialist feature

Prompt:
- Read ALL specialist summaries
- Review ALL files changed across all specialists
- Check integration points between specialists
- Verify cross-boundary consistency
- Report integration-specific issues
```

**Example integration issues**:
```markdown
## Integration Review Findings

**API Contract Mismatch** (CRITICAL)
- Backend returns: { userId: string }
- Frontend expects: { user_id: string }
- Fix: Align naming (use camelCase throughout)

**Type Definition Inconsistency** (HIGH)
- Backend: interface User { email: string }
- Frontend: type User = { email?: string }
- Fix: Make email required in frontend types

**Error Handling Gap** (MEDIUM)
- Backend returns 401 for auth failure
- Frontend only handles 400/500
- Fix: Add 401 handler in frontend
```

---

### Multi-Specialist PR and Jira Comments

When creating PRs or Jira comments for multi-specialist features, document all specialist contributions:

**PR Title Format**:
```
feat: Add user authentication (multi-specialist)
```

**PR Description Template**:
```markdown
## Summary
Implement user authentication with full-stack integration

## Multi-Specialist Implementation

### Backend Architect (@backend-specialist)
**Work completed**:
- Authentication API endpoints (login, register, logout)
- PostgreSQL schema with users table
- JWT token generation and validation
- Password hashing with bcrypt

**Files changed**: 12 files created, 3 modified
**Tests**: 87% coverage, all passing
**Duration**: 45 minutes

### Frontend Developer (@frontend-specialist)
**Work completed**:
- Login/register React components
- Authentication context and hooks
- Protected route wrapper
- Session management

**Files changed**: 8 files created, 2 modified
**Tests**: 82% coverage, all passing
**Duration**: 35 minutes

## Integration Points
- API Contract: See `.agency/handoff/user-auth/integration/api-contract.md`
- Type Definitions: Shared via `src/types/auth.ts`
- Authentication flow tested end-to-end

## Verification
- ✅ Backend verification: PASSED (0 critical issues)
- ✅ Frontend verification: PASSED (0 critical issues)
- ✅ Integration review: PASSED (minor style fixes applied)

## Testing
- Unit tests: 217/254 passing (85% coverage)
- Integration tests: 12/12 passing
- E2E tests: 5/5 passing

## Closes
Fixes #234
```

**Jira Comment Format** (using ADF):
```json
{
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Multi-Specialist Implementation Complete" }]
    },
    {
      "type": "paragraph",
      "content": [
        { "type": "text", "text": "Feature implemented by ", "marks": [] },
        { "type": "text", "text": "2 specialists", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": " (Backend + Frontend)" }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "Backend Architect" }]
    },
    {
      "type": "bulletList",
      "content": [
        { "type": "listItem", "content": [
          { "type": "paragraph", "content": [
            { "type": "text", "text": "Authentication API: login, register, logout" }
          ]}
        ]},
        { "type": "listItem", "content": [
          { "type": "paragraph", "content": [
            { "type": "text", "text": "Database schema with users table" }
          ]}
        ]}
      ]
    }
  ]
}
```

**Commit Message Convention**:
```bash
# Each specialist creates their own commits
feat(backend): implement authentication API endpoints
feat(frontend): add login/register components

# Integration commit (optional)
feat: integrate authentication across frontend and backend
```

---

### Multi-Specialist Workflow Example

**Complete end-to-end example**:

**Scenario**: Implement full-stack user dashboard

**Step 1: Keyword Analysis**
```
Plan mentions: "React dashboard, data visualization components,
REST API endpoints, PostgreSQL analytics queries, real-time updates"

Scores:
- Frontend: React (0.5) + dashboard (0.5) + components (0.5) +
            visualization (0.5) = 2.0 ✅
- Backend: REST (0.5) + API (0.5) + endpoints (0.5) + PostgreSQL (0.5) +
           queries (0.5) = 2.5 ✅

Decision: Multi-specialist (Frontend + Backend)
```

**Step 2: Dependency Detection**
```
Dependency indicator: "Dashboard components fetch data from API"
Strategy: Sequential (Backend → Frontend)
```

**Step 3: Handoff Directory Creation**
```bash
.agency/handoff/user-dashboard/
├── execution-state.json
├── integration/
├── backend-architect/
└── frontend-developer/
```

**Step 4: Backend Execution**
```
1. Backend reads plan.md (filtered for backend tasks)
2. Implements: API endpoints, database queries, tests
3. Creates summary.md with API documentation
4. Reality-checker verifies → PASSED
5. Updates execution-state.json (backend: completed)
6. Unblocks frontend
```

**Step 5: Frontend Execution**
```
1. Frontend reads backend/summary.md for API contracts
2. Implements: Dashboard components, data fetching, visualization
3. Creates summary.md with component documentation
4. Reality-checker verifies → PASSED (1 HIGH issue found)
5. Fixes HIGH issue
6. Re-verification → PASSED
7. Updates execution-state.json (frontend: completed)
```

**Step 6: Integration Review**
```
1. Code reviewer reads both summaries
2. Checks API contracts match
3. Verifies type definitions align
4. Tests end-to-end flow
5. Result: PASSED (minor naming consistency suggestions)
```

**Step 7: PR Creation**
```
Creates PR documenting:
- Both specialist contributions
- Integration points verified
- Test coverage from both sides
- Links to handoff directory for details
```

**Timeline**:
- Backend: 40 minutes
- Backend verification: 10 minutes
- Frontend: 35 minutes
- Frontend verification + fix: 15 minutes
- Integration review: 10 minutes
- **Total**: 110 minutes

---

### Best Practices for Multi-Specialist Workflows

1. **Clear Responsibility Boundaries**
   - Each specialist knows exactly what they own
   - No overlap or gaps in assignments
   - Document in specialist's plan.md

2. **Document Integration Points**
   - API contracts in integration/api-contract.md
   - Type definitions shared explicitly
   - Examples for next specialist

3. **Verify Early and Often**
   - Catch issues before next specialist depends on work
   - Fix CRITICAL/HIGH issues immediately
   - Don't block on MEDIUM/LOW issues

4. **Test Integration, Don't Assume**
   - End-to-end tests across boundaries
   - Verify data flows correctly
   - Check error handling at edges

5. **Track State Religiously**
   - Update execution-state.json after each phase
   - Monitor dependencies
   - Clear about what's blocking what

6. **Communicate Through Artifacts**
   - summary.md is the handoff document
   - Don't rely on memory or assumptions
   - Next specialist reads, doesn't guess

7. **Ask When Unclear**
   - Better to clarify than implement wrong
   - Use AskUserQuestion for ambiguous requirements
   - Document decisions in summary.md

8. **Sequential by Default When Uncertain**
   - Parallel execution requires confidence in independence
   - Sequential is safer for unclear dependencies
   - Can always parallelize later

---

## Prompt Component Architecture

Agency uses a modular prompt component system to eliminate duplication across commands. Instead of repeating instructions in multiple command files, commands reference shared, reusable components.

### Overview

**Component System Benefits**:
- **62% line reduction**: 12,895 → 7,500 lines across all commands
- **3.5x reuse**: Each component used in 3-5 commands on average
- **Single source of truth**: Update one component, all commands benefit
- **Consistent behavior**: Same specialist selection, quality gates, review process everywhere

**Component Location**: `/prompts/`

**Component Count**: 46 components organized in 10 categories

**Total Impact**: ~5,400 lines saved through reuse

---

### Component Categories and Purposes

**1. Project Context Detection** (`context/`)
- **Purpose**: Detect project framework, tech stack, and size to adapt command behavior
- **Components**: 6 components
- **Usage**: All 11 commands that interact with code

**Components**:
- `framework-detection.md` - Detect framework (Next.js, Django, Laravel, FastAPI, Flask, etc.)
- `testing-framework-detection.md` - Detect test framework (Jest, Vitest, pytest, Playwright, etc.)
- `database-detection.md` - Detect database/ORM (Prisma, Drizzle, Supabase, SQLAlchemy, etc.)
- `build-tool-detection.md` - Detect build tool (Vite, webpack, Rollup, Next.js, etc.)
- `documentation-system-detection.md` - Detect docs system (MkDocs, Docusaurus, Storybook, etc.)
- `project-size-detection.md` - Categorize project size (small/medium/large) for scope adaptation

**Example usage**:
```markdown
Commands adapt based on detection:
- Framework: Next.js → Use `npm run dev`, `npm run build`
- Framework: Django → Use `python manage.py runserver`, `pytest`
- Project size: Large → Increase timeouts, suggest smaller scopes
- Project size: Small → Enable broader refactoring suggestions
```

---

**2. Specialist Selection** (`specialist-selection/`)
- **Purpose**: Consistently select the right specialist(s) based on plan content
- **Components**: 5 components
- **Usage**: `implement.md`, `work.md`, `test.md`, `refactor.md`, `optimize.md`

**Components**:
- `keyword-analysis.md` - Scoring algorithm for specialist detection (+0.5 per keyword match)
- `multi-specialist-routing.md` - Coordinate multiple specialists with handoff management
- `dependency-detection.md` - Determine sequential vs parallel execution
- `user-approval.md` - User confirmation prompts for specialist selection
- `skill-activation.md` - Activate relevant skills based on detected technologies

**Example keyword analysis**:
```markdown
Plan: "Add React login form calling Node.js API"

keyword-analysis.md applies:
- Frontend: React (0.5) + form (0.5) = 1.0
- Backend: Node.js (0.5) + API (0.5) = 1.0

→ No specialist scores > 2.0 → Use senior-developer (generalist)

Plan: "Build React dashboard with 8 charts, Tailwind styling,
responsive layout, Next.js pages, component library"

keyword-analysis.md applies:
- Frontend: React (0.5) + dashboard (0.5) + charts (0.5) +
           Tailwind (0.5) + responsive (0.5) + Next.js (0.5) +
           component (0.5) + layout (0.5) = 4.0 ✅

→ Frontend specialist selected
```

---

**3. Quality Gates** (`quality-gates/`)
- **Purpose**: Ensure consistent quality standards across all workflows
- **Components**: 8 components
- **Usage**: `implement.md`, `work.md`, `test.md`, `review.md`

**Components**:
- `quality-gate-sequence.md` - Sequential execution of all verification steps
- `build-verification.md` - Ensure code builds successfully
- `type-checking.md` - TypeScript/Python type validation
- `linting.md` - Code style and quality checks
- `test-execution.md` - Run tests and validate coverage
- `coverage-validation.md` - Test coverage thresholds
- `security-scan-quick.md` - Basic security vulnerability scanning
- `rollback-on-failure.md` - Revert changes if quality gates fail

**Quality gate sequence**:
```
1. Build → CRITICAL (must pass)
2. Type Check → CRITICAL (must pass)
3. Linter → HIGH (can proceed with warnings)
4. Tests → CRITICAL (must pass)
5. Coverage → RECOMMENDED (can proceed below threshold)
6. Security Scan → HIGH (review vulnerabilities)
```

---

**4. Code Review** (`code-review/`)
- **Purpose**: Consistent code review process with proper context
- **Components**: 1 component
- **Usage**: `implement.md`, `work.md`, `test.md`, `review.md`, `refactor.md`

**Components**:
- `reality-checker-spawn.md` - Spawn reality-checker agent with correct context

**Modes**:
- **Single-specialist review**: Standard code review after implementation
- **Per-specialist verification**: Multi-specialist mode, verify each specialist's work
- **Integrated review**: Multi-specialist mode, check cross-boundary consistency

---

**5. Planning** (`planning/`)
- **Purpose**: Ensure plans are complete before implementation starts
- **Components**: 1 component
- **Usage**: `implement.md`, `plan.md`, `work.md`

**Components**:
- `plan-validation.md` - Validate plan completeness (requirements, files, success criteria)

**Validation checklist**:
- ✅ Clear objective stated
- ✅ Requirements listed
- ✅ Files to create/modify specified
- ✅ Success criteria defined
- ✅ Out of scope documented
- ✅ Dependencies identified

---

**6. Issue Management** (`issue-management/`)
- **Purpose**: Unified issue fetching and parsing for GitHub and Jira
- **Components**: 4 components
- **Usage**: `work.md`, `sprint.md`, `plan.md`

**Components**:
- `github-issue-fetch.md` - Fetch GitHub issues with `gh` CLI
- `jira-issue-fetch.md` - Fetch Jira issues with `acli`
- `issue-metadata-extraction.md` - Extract structured metadata from issues
- `dependency-parsing.md` - Parse dependency references ("depends on #123")

**Workflow**:
```
1. Detect issue source (GitHub vs Jira)
2. Fetch issue with appropriate CLI
3. Extract: title, description, labels, priority
4. Parse dependencies and check status
5. Block if dependencies not resolved
```

---

**7. Progress Tracking** (`progress/`)
- **Purpose**: Consistent progress tracking across multi-phase commands
- **Components**: 3 components
- **Usage**: `work.md`, `implement.md`, `sprint.md`, `deploy.md`

**Components**:
- `todo-initialization.md` - Initialize TodoWrite for workflows
- `phase-tracking.md` - Update TodoWrite as phases complete
- `completion-reporting.md` - Final TodoWrite with summary

**TodoWrite guidelines**:
- Initialize at command start with all phases
- Exactly ONE item `in_progress` at all times
- Update immediately after each phase
- Mark all `completed` at workflow end
- Include timing statistics in final report

---

**8. Git Operations** (`git/`)
- **Purpose**: Standardized git workflows with best practices
- **Components**: 5 components
- **Usage**: `implement.md` (Phase 6), `work.md`, `deploy.md`

**Components**:
- `branch-creation.md` - Create branches with naming conventions (feat/, fix/, refactor/)
- `commit-formatting.md` - Conventional commit format with HEREDOC templates
- `pr-creation.md` - Create comprehensive PRs using `gh` CLI
- `status-validation.md` - Validate repository state before operations
- `tag-creation.md` - Semantic versioning and release tag creation

**Branch naming**:
```
feat/user-authentication
fix/login-validation-bug
refactor/api-error-handling
docs/api-documentation
```

**Commit format**:
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add user authentication endpoints

- POST /api/auth/login
- POST /api/auth/register
- GET /api/auth/me
- JWT token generation and validation

Closes #234
EOF
)"
```

---

**9. Error Handling** (`error-handling/`)
- **Purpose**: Consistent error detection, reporting, and recovery
- **Components**: 6 components
- **Usage**: All 14 commands (universal error handling)

**Components**:
- `scope-detection-failure.md` - Handle ambiguous/missing framework detection
- `tool-execution-failure.md` - Handle CLI tool failures (npm, tsc, gh, pytest, etc.)
- `user-cancellation.md` - Graceful Ctrl+C handling with cleanup
- `timeout-handling.md` - Handle long-running operations with timeouts
- `partial-failure-recovery.md` - Handle mixed success/failure scenarios
- `ask-user-retry.md` - Standardized retry/skip/abort pattern

**Error exit codes**:
```bash
# Scope failures: 10-19
EXIT_CODE_SCOPE_FAILURE=10
EXIT_CODE_SCOPE_AMBIGUOUS=12

# Tool failures: 20-29
EXIT_CODE_TOOL_NOT_FOUND=20
EXIT_CODE_TOOL_FAILED=21
EXIT_CODE_TOOL_TIMEOUT=22

# User-initiated: 130-139
EXIT_CODE_USER_CANCEL=130
EXIT_CODE_USER_ABORT=131

# Timeouts: 40-49
EXIT_CODE_TIMEOUT_BUILD=40
EXIT_CODE_TIMEOUT_TEST=41

# Partial failures: 50-59
EXIT_CODE_PARTIAL_SUCCESS=50
```

---

**10. Reporting** (`reporting/`)
- **Purpose**: Standardized reporting format for all implementations
- **Components**: 4 components
- **Usage**: `implement.md`, `work.md`, `sprint.md`

**Components**:
- `summary-template.md` - Implementation summary structure
- `artifact-listing.md` - List files created/modified/deleted
- `next-steps-template.md` - Recommended follow-up actions
- `metrics-comparison.md` - Before/after metrics comparison

---

### How Commands Reference Components

**Component Attribution Format**:

Commands use special markers to reference components:

```markdown
<!-- Component: prompts/specialist-selection/keyword-analysis.md -->

## Phase 2: Specialist Selection

Scan the plan for technology keywords to determine the best specialist:

**Frontend Specialist** if plan mentions:
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
... [keyword list from component]
```

**Benefits of attribution**:
1. **Traceability**: Know which component provides each instruction
2. **Maintenance**: Update component, all commands benefit
3. **Debugging**: Trace issues back to specific components
4. **Documentation**: Clear source of truth for each instruction

**Example command structure** (`implement.md`):

```markdown
# /agency:implement - Execute Implementation Plan

## Phase 1: Plan Loading
<!-- Component: prompts/planning/plan-validation.md -->
[Validation logic here]

## Phase 2: Context Detection
<!-- Component: prompts/context/framework-detection.md -->
<!-- Component: prompts/context/project-size-detection.md -->
[Detection logic here]

## Phase 3: Specialist Selection
<!-- Component: prompts/specialist-selection/keyword-analysis.md -->
<!-- Component: prompts/specialist-selection/multi-specialist-routing.md -->
[Selection logic here]

## Phase 4: Implementation
[Command-specific implementation logic]

## Phase 5: Quality Gates
<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->
<!-- Component: prompts/quality-gates/build-verification.md -->
<!-- Component: prompts/quality-gates/test-execution.md -->
[Gate execution here]

## Phase 6: Code Review
<!-- Component: prompts/code-review/reality-checker-spawn.md -->
[Review spawning here]

## Phase 7: Git Operations
<!-- Component: prompts/git/commit-formatting.md -->
<!-- Component: prompts/git/pr-creation.md -->
[Git workflow here]
```

---

### Component Reuse Statistics

**Most Reused Components** (usage count):

1. `error-handling/tool-execution-failure.md` - 14 commands (100%)
2. `error-handling/scope-detection-failure.md` - 14 commands (100%)
3. `progress/todo-initialization.md` - 12 commands (86%)
4. `specialist-selection/keyword-analysis.md` - 11 commands (79%)
5. `quality-gates/quality-gate-sequence.md` - 11 commands (79%)
6. `context/framework-detection.md` - 11 commands (79%)
7. `git/commit-formatting.md` - 8 commands (57%)
8. `code-review/reality-checker-spawn.md` - 7 commands (50%)
9. `issue-management/github-issue-fetch.md` - 5 commands (36%)
10. `reporting/summary-template.md` - 5 commands (36%)

**Line Reduction by Category**:

| Category | Components | Total Lines | Avg Reuse | Lines Saved |
|----------|-----------|-------------|-----------|-------------|
| Error Handling | 6 | 2,130 | 9.3x | 19,809 |
| Git Operations | 5 | 3,180 | 4.2x | 13,356 |
| Context Detection | 6 | 1,840 | 7.8x | 14,352 |
| Quality Gates | 8 | 4,200 | 6.1x | 25,620 |
| Specialist Selection | 5 | 2,850 | 5.4x | 15,390 |
| Issue Management | 4 | 1,240 | 3.8x | 4,712 |
| Progress Tracking | 3 | 1,284 | 7.2x | 9,245 |
| Code Review | 1 | 228 | 7.0x | 1,596 |
| Planning | 1 | 156 | 5.0x | 780 |
| Reporting | 4 | 892 | 3.5x | 3,122 |
| **TOTAL** | **46** | **~18,000** | **5.9x avg** | **~108,000** |

**Note**: "Lines Saved" = Component Lines × (Reuse Count - 1)

---

### Benefits of the Component System

**1. Consistency Across Commands**

All commands use identical logic for:
- Specialist selection (same keyword scoring)
- Quality gates (same sequence and thresholds)
- Error handling (same retry patterns)
- Git workflows (same commit format)
- Code review (same verification criteria)

**2. Maintainability**

Update behavior in one place:
```
Change: Add new specialist "data-engineer"

Before (without components):
- Update 11 command files
- 220+ lines changed
- Risk of inconsistency

After (with components):
- Update specialist-selection/keyword-analysis.md
- 20 lines changed
- All 11 commands automatically updated
```

**3. Testing and Validation**

Test components independently:
- Unit test keyword-analysis.md with various plans
- Verify quality-gate-sequence.md with different projects
- Validate error-handling components with failure scenarios

**4. Documentation**

Components serve as living documentation:
- Each component documents one specific workflow
- Easy to understand in isolation
- Clear dependencies between components
- Examples and usage notes included

**5. Evolution**

Easy to improve incrementally:
- Add new components without disrupting existing ones
- Deprecate old components gradually
- Version components independently
- A/B test new approaches

---

### Component Dependency Graph

Some components depend on others and must execute in order:

```
specialist-selection/keyword-analysis.md
  ↓ (provides specialist list with scores)
specialist-selection/multi-specialist-routing.md
  ↓ (determines execution strategy)
specialist-selection/user-approval.md
  ↓ (confirms with user)
[Specialist execution]
  ↓ (specialists complete work)
code-review/reality-checker-spawn.md
  ↓ (per-specialist verification)
quality-gates/quality-gate-sequence.md
```

```
context/framework-detection.md
  ↓ (detects Next.js, Django, etc.)
context/testing-framework-detection.md
  ↓ (knows Jest, pytest, etc.)
quality-gates/test-execution.md
  ↓ (runs correct test command)
quality-gates/coverage-validation.md
```

```
issue-management/github-issue-fetch.md OR jira-issue-fetch.md
  ↓ (fetches issue content)
issue-management/issue-metadata-extraction.md
  ↓ (parses title, description, labels)
issue-management/dependency-parsing.md
  ↓ (finds "depends on #123")
[Check dependency status before proceeding]
```

---

### Creating New Components

**When to create a component**:
- Pattern appears in 3+ commands
- Logic is >15 lines
- Likely to change or evolve
- Part of a critical workflow

**When NOT to create a component**:
- Command-specific logic
- One-off instructions
- Less than 10 lines
- Tightly coupled to specific command context

**Component structure template**:
```markdown
# Component Title

Brief description of what this component does.

## When to Use

[Trigger conditions]

## Purpose

[What problem this solves]

---

## Main Content

[The actual reusable instructions]

---

## Validation

[How to verify this component was executed correctly]

---

<!-- Component Version: v1.0.0 -->
<!-- Last Updated: 2024-12-11 -->
<!-- Used In: implement.md, work.md, test.md -->
```

**Naming convention**:
- Use kebab-case for filenames
- Descriptive, action-oriented names
- Group related components in subdirectories

**Good**: `specialist-selection/keyword-analysis.md`
**Bad**: `helpers/utils.md`

---

### Component Maintenance

**Updating components**:
1. Test with ALL commands that use it
2. Update component version/date in header
3. Document changes in `prompts/README.md`
4. Notify team of changes

**Impact radius**: One component change affects 3-5 commands on average.

**Versioning**:
```markdown
<!-- v1.2.0 - 2024-12-11 - Added DevOps specialist scoring -->
```

**Deprecation process**:
1. Mark as `[DEPRECATED]` in filename
2. Add deprecation notice at top
3. Provide migration path
4. Remove after all commands updated

---

### Multi-Specialist Integration with Components

Components fully support multi-specialist workflows:

**Backward Compatible**: Components auto-detect mode based on context:
- If 1 specialist selected → Single-specialist mode
- If 2+ specialists selected → Multi-specialist mode

**Multi-specialist aware components**:
- `specialist-selection/keyword-analysis.md` - Scores all specialists
- `specialist-selection/multi-specialist-routing.md` - Coordinates handoffs
- `code-review/reality-checker-spawn.md` - Adapts to per-specialist or integrated review
- `git/pr-creation.md` - Documents all specialist contributions
- `reporting/summary-template.md` - Aggregates multi-specialist work

**Example**: `code-review/reality-checker-spawn.md`
```markdown
## Detection Logic

IF execution-state.json exists:
  → Multi-specialist mode
  → Run per-specialist verification THEN integrated review
ELSE:
  → Single-specialist mode
  → Run standard code review
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
- **[Prompt Components README](/prompts/README.md)**: Detailed component documentation and usage
- **[Multi-Specialist Routing](/prompts/specialist-selection/multi-specialist-routing.md)**: Complete handoff system specification
- **[Agent Capability Matrix](/docs/agent-capability-matrix.md)**: Technology and skill mappings for all agents

---

**Last Review**: 2024-12-12
**Next Review**: 2025-03-12 (Quarterly)
**Feedback**: Create issue in agency plugin repository with `orchestration` label
