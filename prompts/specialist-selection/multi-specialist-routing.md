# Specialist Selection: Multi-Specialist Routing

Coordinate multiple specialists working on a single feature with proper handoff management.

## When to Use Multi-Specialist Routing

**Multiple specialists needed when**:
- Keyword analysis shows 2+ specialists scoring > 2.0
- Plan explicitly mentions full-stack work (frontend + backend)
- Cross-layer integration required (UI + API + Database)
- Mobile and web components both needed
- AI/ML integration with frontend/backend

**Threshold**: If 2+ specialists score > 2.0, enable multi-specialist mode.

---

## Execution Strategy Selection

### Sequential Execution

**Use when dependencies exist**:

**Backend → Frontend dependency indicators**:
- "Frontend needs backend API"
- "UI calls authentication endpoint"
- "Component fetches data from API"
- "Form submits to server"
- "Dashboard displays database data"
- "Frontend consumes REST/GraphQL endpoints"

**Backend → Mobile dependency indicators**:
- "Mobile app consumes API"
- "Native app calls GraphQL"
- "App syncs with server"
- "Mobile authenticates with backend"

**AI → Backend → Frontend chain**:
- "Backend integrates ML model"
- "API serves AI predictions"
- "UI displays ML recommendations"

**DevOps → Any dependency indicators**:
- "Requires deployment before testing"
- "Needs infrastructure setup first"
- "Environment configuration required"

**Decision Template**:
```
Strategy: Sequential
Order: [SPECIALIST_1] → [SPECIALIST_2] → [SPECIALIST_3]
Reason: [Specific dependency from plan, e.g., "Frontend needs backend API endpoints"]
```

### Parallel Execution

**Use when work is independent**:

**Independence indicators**:
- "Separate admin dashboard"
- "Independent API changes"
- "Standalone service"
- "Isolated feature"
- "No shared interfaces"
- "Different codebases"
- "Separate repositories"
- "Background job processing"
- "Async worker tasks"
- "Scheduled tasks"

**Decision Template**:
```
Strategy: Parallel
Reason: [Independence justification, e.g., "Admin dashboard and API are separate systems"]
Warning: Ensure no hidden dependencies exist
```

### Safe Default

**When unclear**:
```
Strategy: Sequential (safe default)
Reason: Dependencies unclear - executing sequentially to avoid integration issues
Order: [Default order based on typical dependency chains]
```

**Default dependency chains**:
1. `devops-automator` → `backend-architect` → `frontend-developer`/`mobile-app-builder`
2. `backend-architect` → `ai-engineer` (if AI needs data from backend)
3. `ai-engineer` → `backend-architect` → `frontend-developer` (if backend integrates AI)

---

## Handoff Directory Structure

Create the handoff workspace for coordination:

```bash
FEATURE_NAME=[extract from plan filename or issue ID]
BASE_DIR=".agency/handoff/${FEATURE_NAME}"

# Create directory structure
mkdir -p ${BASE_DIR}/integration
mkdir -p ${BASE_DIR}/archive

# For each specialist
for SPECIALIST in ${SPECIALISTS[@]}; do
  mkdir -p ${BASE_DIR}/${SPECIALIST}
done
```

**Directory Structure**:
```
.agency/handoff/${FEATURE_NAME}/
├── execution-state.json          # Track overall progress
├── integration/
│   ├── api-contract.md          # Shared API contracts
│   ├── type-definitions.ts      # Shared TypeScript types
│   └── integration-tests.md     # Cross-specialist test plan
├── backend-architect/
│   ├── plan.md                  # Specialist-specific tasks
│   ├── summary.md               # Completion report (created by specialist)
│   ├── verification.md          # Verification results (created by reality-checker)
│   └── files-changed.json       # File tracking
├── frontend-developer/
│   ├── plan.md
│   ├── summary.md
│   ├── verification.md
│   └── files-changed.json
├── mobile-app-builder/
│   └── [same structure...]
├── ai-engineer/
│   └── [same structure...]
└── devops-automator/
    └── [same structure...]
```

---

## Execution State Tracking

**File**: `.agency/handoff/${FEATURE_NAME}/execution-state.json`

### Initial State (Before Execution)

```json
{
  "feature": "${FEATURE_NAME}",
  "plan_file": "[path to original plan]",
  "execution_strategy": "sequential|parallel",
  "created_at": "2024-12-11T14:30:00Z",
  "current_phase": "execution",
  "specialists": [
    {
      "name": "backend-architect",
      "status": "pending",
      "score": 3.5,
      "keywords_matched": ["API", "database", "authentication", "JWT", "Prisma", "endpoint", "schema"],
      "verification": null,
      "dependencies_met": true,
      "started_at": null,
      "completed_at": null
    },
    {
      "name": "frontend-developer",
      "status": "pending",
      "score": 2.5,
      "keywords_matched": ["React", "component", "form", "Tailwind", "UI"],
      "verification": null,
      "dependencies_met": false,
      "waiting_for": ["backend-architect"],
      "started_at": null,
      "completed_at": null
    }
  ]
}
```

### During Execution

Update status as specialists progress:

**Specialist started**:
```json
{
  "name": "backend-architect",
  "status": "in_progress",
  "dependencies_met": true,
  "started_at": "2024-12-11T14:35:00Z",
  "completed_at": null
}
```

**Specialist completed**:
```json
{
  "name": "backend-architect",
  "status": "completed",
  "verification": "passed",
  "started_at": "2024-12-11T14:35:00Z",
  "completed_at": "2024-12-11T15:20:00Z",
  "duration_minutes": 45,
  "files_created": 8,
  "files_modified": 3
}
```

**Specialist failed verification**:
```json
{
  "name": "backend-architect",
  "status": "verification_failed",
  "verification": "failed",
  "critical_issues": 2,
  "fix_iteration": 1,
  "started_at": "2024-12-11T14:35:00Z",
  "completed_at": null
}
```

**Next specialist unblocked**:
```json
{
  "name": "frontend-developer",
  "status": "pending",
  "dependencies_met": true,
  "waiting_for": [],
  "ready_to_start": true
}
```

---

## Per-Specialist Plan Generation

For each specialist, create a focused plan from the main plan.

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/plan.md`

**Template**:
```markdown
# ${SPECIALIST} Plan: ${FEATURE_NAME}

**Generated**: [timestamp]
**Main Plan**: [path to original plan]

---

## Multi-Specialist Context

**Feature**: ${FEATURE_NAME}
**Your Specialty**: ${SPECIALIST}
**Other Specialists Involved**:
- [LIST other specialists and their roles]

**Execution Strategy**: [Sequential/Parallel]

[IF Sequential]:
**Your Position**: [X of Y] in execution order
**Previous Specialist**: [SPECIALIST or "None - you are first"]
**Next Specialist**: [SPECIALIST or "None - you are last"]

[IF Parallel]:
**Coordination**: Working in parallel with [LIST]
**Integration Points**: See integration/ directory for shared contracts

---

## Your Responsibilities

[Extract from main plan based on specialist keywords]

**Tasks assigned to you**:
- [Task 1 - matched by keywords: React, component, etc.]
- [Task 2 - matched by keywords: ...]
- [Task 3 - matched by keywords: ...]

**Files you should create/modify**:
- [List filtered by specialist domain]

**Success criteria specific to your work**:
- [Criteria filtered by specialist domain]

---

## Dependencies

### What You Need From Others

[IF not first specialist in sequential execution]:

**From ${PREVIOUS_SPECIALIST}**:
- API endpoint definitions
- Database schema
- Authentication contracts
- Type definitions
- [Other handoff items]

**Read**: `.agency/handoff/${FEATURE_NAME}/${PREVIOUS_SPECIALIST}/summary.md`

[IF first specialist or parallel]:
No dependencies on other specialists. You can begin immediately.

### What Others Need From You

[IF not last specialist in sequential execution]:

**${NEXT_SPECIALIST} needs from you**:
- [API documentation]
- [Type definitions]
- [Interface contracts]
- [Test data]

**You must provide** in your summary.md:
- Clear API contracts
- Type definitions for shared interfaces
- Integration examples
- Testing instructions

---

## Integration Points

**Shared Contracts**:
- See `.agency/handoff/${FEATURE_NAME}/integration/api-contract.md`
- See `.agency/handoff/${FEATURE_NAME}/integration/type-definitions.ts`

**API Endpoints You'll Work With**:
[IF consuming APIs created by backend]:
- POST /api/auth/login
- GET /api/users/me
- [List relevant endpoints]

**API Endpoints You'll Create**:
[IF you are backend]:
- POST /api/auth/login
- GET /api/users/me
- [List what you'll build]

**Data Types**:
[Shared TypeScript interfaces, GraphQL schemas, etc.]

---

## Implementation Guidelines

1. **Follow the main plan** - implement only what's assigned to you
2. **Check dependencies** - ensure previous specialists completed their work
3. **Document integration points** - future specialists need clear contracts
4. **Test your changes** - run tests after each significant change
5. **Create summary.md** - document your work for next specialist and reviewers

---

## Verification Requirements

After completing your work, you will be verified by the reality-checker agent.

**Verification will check**:
- All your assigned tasks completed
- Files created/modified as planned
- Tests pass for your changes
- Code quality standards met
- Integration points documented
- No critical issues introduced

**Verification severity levels**:
- CRITICAL: Must fix before handoff to next specialist
- HIGH: Should fix before handoff
- MEDIUM/LOW: Document for future consideration

---

## Handoff Requirements

When you complete your work, you MUST create:

### 1. Summary Document

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/summary.md`

**Required sections**:
- Work Completed (what you built)
- Files Created/Modified (with descriptions)
- Integration Points (for next specialist)
- API Contracts (if applicable)
- Type Definitions (if applicable)
- Testing Evidence (test results, coverage)
- Known Issues/Limitations
- Handoff Notes (what next specialist should know)

### 2. Files Changed Tracking

**File**: `.agency/handoff/${FEATURE_NAME}/${SPECIALIST}/files-changed.json`

```json
{
  "created": [
    "src/api/auth/login.ts",
    "src/api/auth/register.ts",
    "prisma/migrations/001_users.sql"
  ],
  "modified": [
    "src/api/routes.ts",
    "prisma/schema.prisma"
  ],
  "deleted": []
}
```

### 3. Integration Documentation

[IF you create contracts others depend on]:

Update `.agency/handoff/${FEATURE_NAME}/integration/api-contract.md`:
- Document all API endpoints
- Include request/response examples
- Specify authentication requirements
- List error codes and handling

---

## Success Criteria

Your work is complete when:

- ✅ All assigned tasks implemented
- ✅ Tests pass for your changes
- ✅ Code quality verification passed
- ✅ Integration points documented
- ✅ summary.md created
- ✅ files-changed.json created
- ✅ [IF sequential] Handoff to next specialist ready

---

## Communication

**If you need clarification**:
- Use AskUserQuestion for ambiguous requirements
- Check integration/ directory for shared contracts
- Read previous specialist's summary.md for context

**If you discover issues**:
- Document in your summary.md
- If critical, ask user for guidance
- Update execution-state.json if blocking next specialist

---

## Example Handoff Flow

### Backend Architect (First Specialist)

1. Read this plan
2. Implement API endpoints, database schema
3. Run tests, verify builds
4. Create summary.md with:
   - API endpoint documentation
   - Database schema details
   - Authentication flow
5. Create files-changed.json
6. Reality-checker verifies
7. Mark as complete in execution-state.json
8. Frontend Developer unblocked

### Frontend Developer (Second Specialist)

1. Read this plan
2. Read backend-architect/summary.md for API contracts
3. Implement UI components consuming APIs
4. Run tests, verify integration
5. Create summary.md with:
   - Components created
   - API integration details
   - User flows implemented
6. Create files-changed.json
7. Reality-checker verifies
8. Mark as complete in execution-state.json
9. Feature implementation complete

---

## Notes

- This plan is auto-generated from the main plan
- Focus only on your specialty area
- Don't implement features outside your domain
- Ask for clarification if task assignment is unclear
- Coordinate with other specialists through handoff directory
```

---

## Handoff Coordination Algorithm

### Sequential Execution Flow

```
FOR EACH specialist IN execution_order:

  1. Check Dependencies
     - Verify dependencies_met = true
     - If false, wait for previous specialist to complete

  2. Update Execution State
     - Set status = "in_progress"
     - Set started_at = current_timestamp
     - Write to execution-state.json

  3. Spawn Specialist
     - Load specialist-specific plan from handoff directory
     - Provide context from previous specialist summaries
     - Specialist works autonomously

  4. Specialist Completes
     - Specialist creates summary.md
     - Specialist creates files-changed.json
     - Specialist marks work complete

  5. Verification
     - Spawn reality-checker with specialist's work
     - Check against plan and integration requirements
     - If CRITICAL issues found → Fix loop (max 3 iterations)
     - If PASS → Mark verified

  6. Update Execution State
     - Set status = "completed"
     - Set verification = "passed|failed"
     - Set completed_at = current_timestamp
     - Calculate duration_minutes
     - Write to execution-state.json

  7. Unblock Next Specialist
     - Set next specialist's dependencies_met = true
     - Remove from waiting_for list
     - Continue to next iteration

END FOR

Proceed to Integration Review
```

### Parallel Execution Flow

```
1. Check All Specialists Ready
   - All should have dependencies_met = true for parallel
   - If any dependencies exist, warn user and suggest sequential

2. Update Execution State for All
   - Set all specialists status = "in_progress"
   - Set all started_at = current_timestamp
   - Write to execution-state.json

3. Spawn All Specialists Simultaneously
   - Single message with multiple Task tool calls
   - Each specialist gets their plan from handoff directory
   - All work autonomously in parallel

4. Wait for All Completions
   - Track completion via summary.md creation
   - Monitor execution-state.json updates

5. Verify All Specialists
   - Can verify in parallel or sequentially
   - Each gets reality-checker review
   - Track verification results

6. Handle Failures
   - If any specialist fails verification
   - Fix loop for that specialist only
   - Others continue independently

7. Update Execution State
   - Mark all as completed
   - Record verification results
   - Calculate durations
   - Write final state

Proceed to Integration Review
```

---

## Integration Review Coordination

After all specialists complete, perform integrated review:

**Focus Areas**:
1. **Cross-Specialist Integration**
   - API contracts match between backend and frontend/mobile
   - Type definitions consistent across boundaries
   - Error handling aligned
   - Authentication flows work end-to-end

2. **Code Consistency**
   - Naming conventions aligned
   - Code style uniform
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
   - No security gaps

**Integration Review Spawn**:
```
Spawn code-reviewer with:
- Context: Multi-specialist feature
- Read ALL specialist summaries
- Review ALL files changed
- Check integration points
- Verify cross-boundary consistency
- Report integration-specific issues
```

---

## Handoff Directory Archival

After successful completion:

```bash
# Archive the handoff directory
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_FILE=".agency/handoff/${FEATURE_NAME}/archive/handoff-${TIMESTAMP}.tar.gz"

tar -czf ${ARCHIVE_FILE} \
  .agency/handoff/${FEATURE_NAME}/**/plan.md \
  .agency/handoff/${FEATURE_NAME}/**/summary.md \
  .agency/handoff/${FEATURE_NAME}/**/verification.md \
  .agency/handoff/${FEATURE_NAME}/**/files-changed.json \
  .agency/handoff/${FEATURE_NAME}/execution-state.json \
  .agency/handoff/${FEATURE_NAME}/integration/*

# Keep handoff directory for reference
# Don't delete until feature is deployed and stable
```

---

## Error Handling

### Specialist Blocked

```
Error: ${SPECIALIST} cannot proceed

Reason: Dependencies not met
Waiting for: ${PREVIOUS_SPECIALIST}
Status of blocker: [in_progress|verification_failed]

Action: Wait for blocker to complete
```

### Verification Failed After 3 Iterations

```
Error: ${SPECIALIST} has CRITICAL issues after 3 fix attempts

Issues:
- [List critical issues]

Options:
1. Continue with issues (not recommended)
2. Manual intervention needed
3. Skip specialist (feature will be incomplete)

User decision required.
```

### Integration Issues Found

```
Error: Integration review found CRITICAL issues

Issues:
- API contract mismatch between backend and frontend
- Type definitions inconsistent
- [Other integration issues]

Affected specialists:
- ${SPECIALIST_1}
- ${SPECIALIST_2}

Action: Re-spawn affected specialists to fix integration issues
Max 2 integration fix iterations
```

---

## Quality Gates

All specialists must pass:
- ✅ Build verification
- ✅ Type check
- ✅ Linter
- ✅ Tests for their changes
- ✅ Code review (no CRITICAL issues)
- ✅ Integration point documentation

Integration review must pass:
- ✅ Cross-boundary consistency
- ✅ API contracts match
- ✅ Type definitions aligned
- ✅ Security complete end-to-end
- ✅ No integration gaps

---

## Best Practices

1. **Clear Responsibility Boundaries**: Each specialist knows exactly what they own
2. **Document Integration Points**: Next specialist needs clear contracts
3. **Verify Early**: Catch issues before next specialist depends on your work
4. **Test Integration**: Don't assume, verify that pieces work together
5. **Track State**: execution-state.json keeps everyone synchronized
6. **Communicate**: Use summary.md to hand off knowledge
7. **Ask When Unclear**: Better to clarify than implement wrong
