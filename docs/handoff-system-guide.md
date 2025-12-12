# Multi-Specialist Handoff System Guide

**Version**: 1.0
**Last Updated**: 2024-12-12
**Status**: Production

---

## Table of Contents

1. [Introduction](#introduction)
2. [Handoff Directory Structure](#handoff-directory-structure)
3. [Multi-Specialist Detection](#multi-specialist-detection)
4. [Specialist Coordination](#specialist-coordination)
5. [Per-Specialist Verification](#per-specialist-verification)
6. [Integration Points](#integration-points)
7. [PR/Issue Comments](#prissue-comments)
8. [Supported Specialists](#supported-specialists)
9. [Examples](#examples)
10. [Best Practices](#best-practices)

---

## Introduction

### What is the Handoff System?

The multi-specialist handoff system enables complex features to be implemented by multiple specialized agents working in coordination. Each specialist focuses on their domain of expertise (frontend, backend, AI, mobile, etc.) while maintaining clear integration contracts and quality standards.

### Why Multi-Specialist Coordination is Needed

Modern applications require expertise across multiple domains:

- **Full-stack features**: Backend APIs + Frontend UI
- **AI-powered features**: ML models + Backend integration + Frontend UX
- **Mobile applications**: Native apps + Backend services
- **Infrastructure changes**: DevOps setup + Backend deployment + Frontend optimization

Single specialists cannot maintain deep expertise across all these domains. The handoff system allows each specialist to focus on what they do best while ensuring seamless integration.

### When to Use Multi-Specialist vs Single-Specialist

**Use Multi-Specialist When**:
- Keyword analysis shows 2+ specialists scoring > 2.0
- Plan explicitly requires full-stack implementation (e.g., "Build user authentication with login UI and backend API")
- Cross-layer integration needed (e.g., "AI-powered search with backend indexing and frontend interface")
- Multiple technology stacks involved (e.g., React frontend + Express backend + PostgreSQL database)

**Use Single-Specialist When**:
- Only one specialist scores > 2.0 in keyword analysis
- Work is confined to a single domain (e.g., "Add CSS animations to existing components")
- No integration between layers required
- Changes are isolated to one technology stack

### Overview of the Handoff Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. DETECTION PHASE                                              │
│    - Keyword scoring identifies needed specialists              │
│    - Dependency detection determines execution order            │
│    - User confirms multi-specialist plan                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. SETUP PHASE                                                  │
│    - Create .agency/handoff/{feature}/ directory structure      │
│    - Generate per-specialist plans from main plan               │
│    - Initialize execution-state.json tracking                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. EXECUTION PHASE (Sequential OR Parallel)                     │
│    - Spawn specialists in determined order                      │
│    - Each specialist implements their assigned tasks            │
│    - Specialists create summary.md and files-changed.json       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. VERIFICATION PHASE                                           │
│    - Reality-checker verifies each specialist's work            │
│    - Per-specialist verification.md created                     │
│    - Fix loops for CRITICAL issues (max 3 iterations)           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. INTEGRATION PHASE                                            │
│    - Cross-specialist integration review                        │
│    - API contract validation                                    │
│    - Type consistency checks                                    │
│    - End-to-end integration testing                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. COMPLETION PHASE                                             │
│    - Aggregated reality-check-report.md                         │
│    - Multi-specialist PR/issue comments                         │
│    - Archive handoff directory for reference                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Handoff Directory Structure

### Directory Layout

When multi-specialist mode is activated, a structured handoff directory is created:

```
.agency/handoff/{feature-name}/
├── execution-state.json          # Tracks overall progress and specialist status
├── reality-check-report.md       # Aggregated verification report (created at end)
├── integration/                  # Shared integration contracts
│   ├── api-contract.md          # API endpoints, request/response formats
│   ├── type-definitions.ts      # Shared TypeScript interfaces
│   └── integration-tests.md     # Cross-specialist test scenarios
├── backend-architect/            # Per-specialist subdirectory
│   ├── plan.md                  # Backend-specific tasks from main plan
│   ├── summary.md               # Completion report (created by backend-architect)
│   ├── verification.md          # Verification results (created by reality-checker)
│   └── files-changed.json       # Tracks created/modified/deleted files
├── frontend-developer/           # Per-specialist subdirectory
│   ├── plan.md                  # Frontend-specific tasks from main plan
│   ├── summary.md               # Completion report (created by frontend-developer)
│   ├── verification.md          # Verification results (created by reality-checker)
│   └── files-changed.json       # Tracks created/modified/deleted files
├── ai-engineer/                  # Per-specialist subdirectory (if AI work needed)
│   ├── plan.md
│   ├── summary.md
│   ├── verification.md
│   └── files-changed.json
└── archive/                      # Historical records after completion
    └── handoff-20241212-143000.tar.gz
```

### Per-Specialist Subdirectories

Each specialist gets their own isolated workspace within the handoff directory:

#### plan.md (Specialist Assignment)

**Created by**: Orchestrator during setup phase
**Purpose**: Define what this specialist should implement
**Contents**:
- Multi-specialist context (who else is working, execution order)
- Specialist-specific responsibilities (extracted from main plan by keywords)
- Dependencies (what they need from others, what others need from them)
- Integration points (APIs to consume/create, types to use/export)
- Success criteria specific to this specialist
- Handoff requirements (what to document in summary.md)

**Example structure**:
```markdown
# Backend Architect Plan: User Authentication

## Multi-Specialist Context
- Feature: user-authentication
- Your Specialty: Backend (APIs, database, services)
- Other Specialists: frontend-developer
- Execution: Sequential (Position 1 of 2)

## Your Responsibilities
- Implement authentication API endpoints (login, register, logout)
- Design and create users database schema
- Set up JWT token generation and verification
- Implement password hashing with bcrypt

## Dependencies
- You need: None (you are first)
- Others need from you: API contracts, authentication flow, user type definitions

## Integration Points
- API Endpoints to Create: POST /api/auth/login, POST /api/auth/register
- Types to Export: User interface, AuthResponse interface
- Documentation: Full API specs in integration/api-contract.md
```

#### summary.md (Completion Report)

**Created by**: Specialist after completing their work
**Purpose**: Document what was implemented and provide handoff to next specialist
**Contents**:
- Work completed (features implemented, files created/modified)
- Implementation details (technical decisions, approaches used)
- Integration points (API contracts, type definitions for other specialists)
- Verification criteria (how reality-checker should verify the work)
- Testing evidence (test results, coverage reports)
- Known issues or limitations
- Handoff notes (what the next specialist needs to know)

#### verification.md (Quality Report)

**Created by**: Reality-checker after verifying specialist's work
**Purpose**: Evidence-based validation of implementation
**Contents**:
- Assignment vs. delivery comparison
- Code verification (claimed features vs. actual code)
- Integration point validation
- Quality assessment (code quality, testing, documentation)
- Issues found (CRITICAL, HIGH, MEDIUM, LOW)
- Required fixes (specific actions needed)

#### files-changed.json (Change Tracking)

**Created by**: Specialist after completing their work
**Purpose**: Track all file modifications for verification and rollback
**Format**:
```json
{
  "created": [
    "src/api/auth/login.ts",
    "src/api/auth/register.ts",
    "prisma/migrations/001_users.sql"
  ],
  "modified": [
    "src/api/routes.ts",
    "prisma/schema.prisma",
    "package.json"
  ],
  "deleted": [
    "src/legacy/old-auth.ts"
  ]
}
```

### Integration Directory

The `integration/` directory contains contracts shared between specialists:

#### api-contract.md

**Purpose**: Document all API endpoints with request/response formats
**Created by**: Backend specialist
**Used by**: Frontend, mobile, AI specialists consuming APIs

**Example**:
```markdown
# API Contract: User Authentication

## POST /api/auth/login

**Request**:
```json
{
  "email": "string",      // Valid email format
  "password": "string"    // Min 8 characters
}
```

**Response (Success - 200)**:
```json
{
  "success": true,
  "data": {
    "token": "string",        // JWT access token (1 hour expiration)
    "refreshToken": "string", // Refresh token (7 days)
    "user": {
      "id": "string",
      "email": "string",
      "name": "string"
    }
  }
}
```

**Response (Error - 401)**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```
```

#### type-definitions.ts

**Purpose**: Shared TypeScript types used across specialists
**Created by**: Any specialist (usually backend first)
**Used by**: All specialists to ensure type consistency

**Example**:
```typescript
// Shared across backend, frontend, mobile
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  createdAt: string;  // ISO 8601 timestamp
  updatedAt: string;
}

export interface AuthResponse {
  token: string;
  refreshToken: string;
  user: User;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}
```

### Execution State Tracking

**File**: `execution-state.json`
**Purpose**: Real-time tracking of specialist progress and coordination
**Updated by**: Orchestrator throughout execution

**Example**:
```json
{
  "feature": "user-authentication",
  "plan_file": ".agency/plans/user-auth-plan.md",
  "execution_strategy": "sequential",
  "created_at": "2024-12-12T14:30:00Z",
  "current_phase": "execution",
  "specialists": [
    {
      "name": "backend-architect",
      "status": "completed",
      "score": 3.5,
      "keywords_matched": ["API", "database", "JWT", "Prisma"],
      "verification": "passed",
      "dependencies_met": true,
      "started_at": "2024-12-12T14:35:00Z",
      "completed_at": "2024-12-12T15:20:00Z",
      "duration_minutes": 45,
      "files_created": 8,
      "files_modified": 3
    },
    {
      "name": "frontend-developer",
      "status": "in_progress",
      "score": 2.5,
      "keywords_matched": ["React", "component", "form", "UI"],
      "verification": null,
      "dependencies_met": true,
      "waiting_for": [],
      "started_at": "2024-12-12T15:25:00Z",
      "completed_at": null
    }
  ]
}
```

---

## Multi-Specialist Detection

### Keyword Scoring Algorithm

The orchestrator analyzes the implementation plan to determine which specialists are needed based on keyword matches.

#### Scoring System

```
For each specialist:
  keyword_matches = count keywords from specialist domain found in plan
  score = keyword_matches × 0.5

  IF score > 2.0:
    specialist is NEEDED
  ELSE:
    specialist is NOT NEEDED
```

#### Specialist Keywords

**Backend Architect**:
- Keywords: API, endpoint, REST, GraphQL, database, schema, migration, Prisma, SQL, authentication, JWT, session, cookie, Redis, cache, server, Express, Fastify, Node.js, middleware

**Frontend Developer**:
- Keywords: React, component, UI, form, button, Tailwind, CSS, responsive, mobile-first, accessibility, ARIA, Next.js, routing, state, Redux, Zustand, hook, JSX, TypeScript

**AI Engineer**:
- Keywords: AI, ML, model, training, inference, embedding, vector, RAG, LLM, GPT, OpenAI, Anthropic, Claude, prompt, fine-tune, dataset, prediction, classification, NLP, sentiment, recommendation

**Mobile App Builder**:
- Keywords: mobile, iOS, Android, React Native, Swift, Kotlin, native, app store, push notification, offline, sync, gesture, touch, camera, location, MapKit

**DevOps Automator**:
- Keywords: deployment, CI/CD, Docker, Kubernetes, infrastructure, AWS, GCP, Azure, Terraform, monitoring, logging, scaling, load balancer, CDN, environment

**Senior Developer**:
- Keywords: architecture, design pattern, refactor, technical debt, code review, best practice, scalability, performance, security, testing

**Rapid Prototyper**:
- Keywords: prototype, MVP, quick, demo, proof of concept, experimental, mockup, wireframe

#### Example Analysis Output

```markdown
**Keyword Analysis Results**:

Backend Architect:
- Keywords found: API, database, authentication, JWT, Prisma, endpoint [6 matches]
- Score: 3.0
- Status: ✅ NEEDED

Frontend Developer:
- Keywords found: React, component, form, UI, Tailwind [5 matches]
- Score: 2.5
- Status: ✅ NEEDED

AI Engineer:
- Keywords found: [0 matches]
- Score: 0.0
- Status: ❌ NOT NEEDED

Mobile App Builder:
- Keywords found: [0 matches]
- Score: 0.0
- Status: ❌ NOT NEEDED

DevOps Automator:
- Keywords found: deployment, Docker [2 matches]
- Score: 1.0
- Status: ❌ NOT NEEDED (below threshold)
```

### Dependency Detection

After identifying which specialists are needed, the orchestrator determines execution order.

#### Sequential Indicators

**Backend → Frontend Dependencies**:
- "frontend needs backend API"
- "UI calls authentication endpoint"
- "component fetches data from API"
- "form submits to server"
- "dashboard displays database data"

**Backend → Mobile Dependencies**:
- "mobile app consumes API"
- "native app calls GraphQL"
- "app syncs with server"

**AI → Backend → Frontend Chain**:
- "backend integrates ML model"
- "API serves AI predictions"
- "UI displays recommendations"

**Decision Template**:
```
Strategy: Sequential
Order: backend-architect → frontend-developer
Reason: Frontend UI calls authentication endpoints created by backend
```

#### Parallel Indicators

**Independence Signals**:
- "separate admin dashboard"
- "independent API changes"
- "standalone service"
- "no shared interfaces"
- "different repositories"
- "background worker"
- "scheduled tasks"

**Decision Template**:
```
Strategy: Parallel
Reason: Admin dashboard and public API are separate systems with no shared interfaces
Warning: Verify no hidden dependencies exist before parallel execution
```

#### Safe Default

When dependencies are unclear:
```
Strategy: Sequential (safe default)
Reason: Dependencies not explicitly stated - sequential execution prevents integration issues
Order: [Typical dependency chain based on technology stack]
```

**Default chains**:
1. `devops-automator → backend-architect → frontend-developer`
2. `backend-architect → ai-engineer` (if backend provides data to AI)
3. `ai-engineer → backend-architect → frontend-developer` (if AI model is integrated into backend)

### User Confirmation Workflow

Before executing multi-specialist coordination, the orchestrator presents the plan to the user for approval:

```
**Multi-Specialist Work Detected**

Specialists Needed:
- ✅ backend-architect (Score: 3.0) - API endpoints, database schema, authentication
- ✅ frontend-developer (Score: 2.5) - Login/register UI, protected routes, user profile

Execution Strategy: Sequential
- Reason: Frontend UI requires backend API endpoints to be created first
- Order: backend-architect → frontend-developer

Estimated Duration: 60-90 minutes
Quality Gates: Per-specialist verification + integration review

Proceed with this multi-specialist plan?

Options:
1. Yes, proceed with multi-specialist workflow (Recommended)
2. Run in parallel instead (if you know work is independent)
3. Run sequentially in different order (specify order)
4. Modify specialist selection (choose different specialists)
```

---

## Specialist Coordination

### Orchestrator Responsibilities

The orchestrator (via `/agency:implement`) manages the entire multi-specialist workflow:

1. **Setup Phase**:
   - Create handoff directory structure
   - Generate per-specialist plans from main plan
   - Initialize execution-state.json
   - Create integration/ directory with shared contracts

2. **Execution Phase**:
   - Spawn specialists in determined order (sequential or parallel)
   - Monitor progress via execution-state.json updates
   - Track completion via summary.md file creation

3. **Verification Phase**:
   - Spawn reality-checker for each specialist
   - Manage fix loops for CRITICAL issues (max 3 iterations)
   - Update execution-state.json with verification results

4. **Integration Phase**:
   - Run integrated code review after all specialists complete
   - Validate API contracts match across specialists
   - Check type consistency and error handling alignment
   - Test end-to-end user journeys

5. **Completion Phase**:
   - Generate aggregated reality-check-report.md
   - Create multi-specialist PR/issue comments
   - Archive handoff directory for reference

### Sequential Execution Workflow

**Used when**: Dependencies exist between specialists (e.g., frontend needs backend API)

**Process**:
```
FOR EACH specialist IN execution_order:

  1. Check Dependencies
     - Verify dependencies_met = true in execution-state.json
     - If false, wait for previous specialist to complete

  2. Update Execution State
     - Set status = "in_progress"
     - Set started_at = current_timestamp
     - Write to execution-state.json

  3. Spawn Specialist
     - Task tool with specialist's agent type
     - Provide path to their plan.md
     - Specialist works autonomously

  4. Specialist Completes
     - Specialist creates summary.md
     - Specialist creates files-changed.json
     - Specialist updates execution-state.json

  5. Verification
     - Spawn reality-checker
     - Verify against plan.md and summary.md
     - If CRITICAL issues → Fix loop (max 3 iterations)
     - Create verification.md

  6. Update Execution State
     - Set status = "completed"
     - Set verification = "passed|failed"
     - Set completed_at = current_timestamp
     - Calculate duration_minutes

  7. Unblock Next Specialist
     - Set next specialist's dependencies_met = true
     - Remove from waiting_for list

END FOR
```

**Example Timeline (Backend → Frontend)**:

```
14:30 - Create handoff directory structure
14:35 - Spawn backend-architect
        └─ Reads: .agency/handoff/auth/backend-architect/plan.md
        └─ Implements: API endpoints, database schema
        └─ Creates: summary.md, files-changed.json
15:20 - backend-architect completes
15:22 - Spawn reality-checker for backend
        └─ Verifies: plan.md vs summary.md vs actual code
        └─ Creates: verification.md
15:25 - Verification PASSED (no CRITICAL issues)
15:25 - Unblock frontend-developer (dependencies_met = true)
15:26 - Spawn frontend-developer
        └─ Reads: .agency/handoff/auth/frontend-developer/plan.md
        └─ Reads: .agency/handoff/auth/backend-architect/summary.md (API contracts)
        └─ Implements: Login/register UI, authentication flows
        └─ Creates: summary.md, files-changed.json
16:10 - frontend-developer completes
16:12 - Spawn reality-checker for frontend
        └─ Verifies: plan.md vs summary.md vs actual code
        └─ Creates: verification.md
16:15 - Verification PASSED
16:16 - All specialists complete → Integration review
```

### Parallel Execution Workflow

**Used when**: Specialists work independently with no shared dependencies

**Process**:
```
1. Check All Specialists Ready
   - Verify all have dependencies_met = true
   - If any dependencies exist, warn and suggest sequential

2. Update Execution State for All
   - Set all specialists status = "in_progress"
   - Set all started_at = current_timestamp
   - Write to execution-state.json

3. Spawn All Specialists Simultaneously
   - Single orchestrator message with multiple Task calls
   - Each specialist gets their plan.md
   - All work autonomously in parallel

4. Wait for All Completions
   - Track via summary.md creation
   - Monitor execution-state.json updates

5. Verify All Specialists
   - Spawn reality-checker for each (can be parallel)
   - Track verification results
   - Handle fix loops independently

6. Update Execution State
   - Mark all as completed
   - Record verification results
   - Calculate durations

Proceed to Integration Review
```

**Example Timeline (Admin Dashboard || Public API)**:

```
14:30 - Create handoff directory structure
14:35 - Spawn backend-architect AND frontend-developer in parallel
        ├─ backend-architect:
        │  └─ Implements: Admin API endpoints
        └─ frontend-developer:
           └─ Implements: Public dashboard UI
15:45 - backend-architect completes (admin API)
15:50 - frontend-developer completes (public dashboard)
15:52 - Spawn reality-checker for both (parallel)
        ├─ Verify backend-architect work
        └─ Verify frontend-developer work
16:00 - Both verifications PASSED
16:01 - Integration review (check no conflicts)
```

### Integration Contracts

To ensure seamless integration, specialists document their interfaces:

#### API Contracts (Backend → Frontend/Mobile)

**Backend creates in**: `integration/api-contract.md`
**Frontend/Mobile reads**: Before implementing API calls

**Required documentation**:
- Endpoint URLs and HTTP methods
- Request body schemas (JSON structure, required fields, validation rules)
- Response schemas for success and error cases
- Authentication requirements (headers, tokens, cookies)
- Rate limiting and caching policies
- Example requests/responses

#### Type Definitions (Cross-Specialist)

**Any specialist can create/update**: `integration/type-definitions.ts`
**All specialists use**: To ensure type consistency

**Required exports**:
- Shared data models (User, Product, Order, etc.)
- API request/response types
- Error types
- Enum values

#### Integration Tests (Cross-Specialist Validation)

**Created by**: Orchestrator or lead specialist
**Location**: `integration/integration-tests.md`

**Contents**:
- End-to-end user journey tests
- API integration test scenarios
- Expected behavior across specialists
- Test data and fixtures

---

## Per-Specialist Verification

The reality-checker agent verifies each specialist's work individually before allowing handoff to the next specialist.

### Reality-Checker's Role

**Purpose**: Evidence-based validation to prevent fantasy approvals

**Core Principles**:
- Default to "NEEDS WORK" unless overwhelming evidence proves success
- Verify code matches claims (don't trust summary.md blindly)
- Check integration points are properly documented
- Ensure quality gates pass (build, type-check, lint, tests)
- Focus on CRITICAL and HIGH severity issues

### Per-Specialist Verification Workflow

**For EACH specialist after they complete their work**:

```
1. Read Specialist's Assignment
   - Load: .agency/handoff/{feature}/{specialist}/plan.md
   - Extract: Required tasks, integration points, success criteria

2. Read Specialist's Claims
   - Load: .agency/handoff/{feature}/{specialist}/summary.md
   - Extract: Claimed features, files changed, integration documentation

3. Verify Code Matches Claims
   - Load files from files-changed.json
   - Grep for claimed features in actual code
   - Verify files exist and were actually modified
   - Check git log for recent changes

4. Check Integration Points
   - Verify API contracts documented (if backend)
   - Verify type definitions exported (if creating shared types)
   - Check dependencies documented for next specialist

5. Run Quality Gates
   - Build verification (code compiles)
   - Type check (TypeScript strict mode passes)
   - Linter (no critical errors)
   - Tests (specialist's tests pass)

6. Write Verification Report
   - Create: .agency/handoff/{feature}/{specialist}/verification.md
   - Include: Assignment vs delivery, code verification, issues found
   - Classify: CRITICAL, HIGH, MEDIUM, LOW severity
```

### Verification Report Structure

**File**: `verification.md`

```markdown
# Verification Report: backend-architect

**Verified By**: reality-checker
**Verification Date**: 2024-12-12T15:22:00Z
**Overall Status**: ✅ VERIFIED | ❌ NEEDS_WORK | ⚠️ PARTIAL

---

## Assignment vs. Delivery

**Assigned Tasks** (from plan.md):
1. Implement authentication API endpoints (login, register, logout)
2. Create users database schema with proper indexes
3. Implement JWT token generation and verification
4. Set up password hashing with bcrypt

**Claimed Completion** (from summary.md):
1. Authentication API endpoints - ✅ VERIFIED (found in src/api/auth/)
2. Users database schema - ✅ VERIFIED (found in prisma/schema.prisma)
3. JWT token management - ✅ VERIFIED (found in src/services/auth.ts)
4. Password hashing - ✅ VERIFIED (bcrypt with 12 rounds confirmed)

---

## Code Verification

**Files Claimed**: 12 created, 5 modified
**Files Verified**: 12 created ✅, 5 modified ✅

**Feature Implementation**:
- ✅ POST /api/auth/login endpoint: Found in src/api/auth/login.ts:45
- ✅ POST /api/auth/register endpoint: Found in src/api/auth/register.ts:32
- ✅ JWT generation: Found in src/services/auth.ts:78
- ✅ Password hashing: Found in src/services/auth.ts:123 (bcrypt.hash, 12 rounds)
- ✅ Database schema: Found in prisma/schema.prisma:15-30

---

## Integration Points

**API Contracts Documented**: ✅ YES
- Location: .agency/handoff/auth/integration/api-contract.md
- Completeness: All endpoints documented with request/response examples
- Authentication: JWT Bearer token format specified

**Type Definitions Exported**: ✅ YES
- Location: integration/type-definitions.ts
- Types: User, AuthResponse, ApiError
- Consistency: Matches database schema and API responses

**Handoff to Frontend**: ✅ READY
- API contracts complete
- Example requests provided
- Error codes documented

---

## Quality Assessment

**Build Verification**: ✅ PASS (npm run build successful)
**Type Check**: ✅ PASS (tsc --noEmit, 0 errors)
**Linter**: ✅ PASS (0 errors, 2 warnings - acceptable)
**Tests**: ✅ PASS (15 tests, 92% coverage)

**Code Quality**: ✅ GOOD
- Proper error handling implemented
- Input validation with Zod schemas
- No hardcoded secrets (env variables used)

---

## Issues Found

**CRITICAL**: 0 issues

**HIGH**: 0 issues

**MEDIUM**: 2 issues
1. Missing rate limiting on registration endpoint (prevents spam accounts)
2. No email verification before account activation (security best practice)

**LOW**: 3 issues
1. API response times not optimized (avg 150ms, could be <100ms)
2. Missing API documentation comments (JSDoc)
3. Test coverage could be higher for edge cases

---

## Specialist Status

**Overall Verification**: ✅ VERIFIED

**Reasoning**:
- All assigned tasks completed and verified in code
- Integration points properly documented
- Quality gates pass
- No CRITICAL or HIGH issues
- MEDIUM/LOW issues documented but don't block handoff

**Required Fixes**: NONE (MEDIUM/LOW issues can be addressed later)

**Ready for Handoff**: ✅ YES
- Frontend developer can proceed
- All dependencies met
- API contracts complete

---

**Next Steps**:
1. Frontend developer can begin implementation
2. Consider addressing MEDIUM issues in future iteration
3. Monitor API performance in production
```

### Cross-Specialist Integration Checks

After all specialists complete individual verification, the reality-checker performs integration validation:

#### 1. API Contract Validation

**Check**: Frontend expectations match backend implementation

```markdown
## API Contract Validation

**Frontend Expectations** (from frontend-developer/summary.md):
- Endpoint: POST /api/auth/login
- Request: { email: string, password: string }
- Response: { token: string, user: User }

**Backend Implementation** (from backend-architect/summary.md):
- Endpoint: POST /api/auth/login ✅ MATCH
- Request: { email: string, password: string } ✅ MATCH
- Response: { token: string, refreshToken: string, user: User } ⚠️ EXTRA FIELD

**Status**: ⚠️ MINOR MISMATCH
- Backend returns refreshToken not documented in frontend expectations
- Impact: Frontend ignores extra field (no breaking issue)
- Action: Document refreshToken in API contract
```

#### 2. Type Consistency Check

**Check**: Type definitions match across all layers

```markdown
## Type Consistency Check

**User Type Definition**:

| Field      | Frontend Type | Backend Type  | Database Type | Status      |
|------------|---------------|---------------|---------------|-------------|
| id         | string        | string        | uuid          | ✅ MATCH    |
| email      | string        | string        | varchar(255)  | ✅ MATCH    |
| name       | string        | string        | varchar(100)  | ✅ MATCH    |
| createdAt  | Date          | timestamp     | timestamp     | ⚠️ FORMAT   |

**Issues**:
1. createdAt format: Frontend expects Date object, backend returns ISO string
   - Impact: Frontend needs to parse string to Date
   - Fix: Document in type definitions that createdAt is ISO 8601 string
```

#### 3. Error Handling Alignment

**Check**: Error responses consistent across specialists

```markdown
## Error Handling Alignment

**Frontend Error Handling** (expects):
```typescript
interface ApiError {
  error: {
    code: string;
    message: string;
  }
}
```

**Backend Error Responses** (returns):
```typescript
{
  success: false,
  error: {
    code: string,
    message: string
  }
}
```

**Status**: ⚠️ SCHEMA MISMATCH
- Backend includes `success: false` field not expected by frontend
- Frontend expects only `error` object
- Impact: Frontend error parsing may fail
- Fix: Align error response format in API contract
```

### Aggregated Reality-Check Report

After verifying all specialists and integration points, create final report:

**File**: `.agency/handoff/{feature}/reality-check-report.md`

```markdown
# Multi-Specialist Reality Check Report

**Feature**: user-authentication
**Specialists Involved**: 2 (backend-architect, frontend-developer)
**Verification Date**: 2024-12-12T16:15:00Z
**Overall Status**: ✅ VERIFIED WITH NOTES

---

## Individual Specialist Verification

### Backend Architect
**Status**: ✅ VERIFIED
**Summary**: All API endpoints and database schema implemented correctly
**Issues**: 0 critical, 0 high, 2 medium, 3 low
**Details**: See `.agency/handoff/auth/backend-architect/verification.md`

**Key Findings**:
- ✅ All authentication endpoints working
- ✅ Database schema optimized with indexes
- ✅ Security best practices followed (JWT, bcrypt)
- ⚠️ Missing rate limiting (medium priority)

### Frontend Developer
**Status**: ✅ VERIFIED
**Summary**: Login/register UI and authentication flows implemented
**Issues**: 0 critical, 0 high, 1 medium, 2 low
**Details**: See `.agency/handoff/auth/frontend-developer/verification.md`

**Key Findings**:
- ✅ All UI components accessible and responsive
- ✅ Form validation working correctly
- ✅ Protected routes redirecting properly
- ⚠️ Missing loading states for API calls (medium priority)

---

## Cross-Specialist Integration Analysis

### API Contract Validation
**Status**: ⚠️ MINOR MISMATCHES

**Issues**:
1. ⚠️ Backend returns `refreshToken` not documented in frontend expectations
2. ⚠️ Error response format inconsistent (`success` field mismatch)

**Impact**: LOW - Frontend currently ignores extra fields, no breaking issues
**Action**: Update API contract documentation

### Type Consistency
**Status**: ⚠️ FORMAT DIFFERENCES

**Issues**:
1. ⚠️ `createdAt` field: Backend returns ISO string, frontend expects Date object

**Impact**: LOW - Frontend successfully parses ISO strings to Date
**Action**: Document in type definitions that timestamps are ISO 8601 strings

### Error Handling Alignment
**Status**: ⚠️ SCHEMA MISMATCH

**Issues**:
1. ⚠️ Error response shape differs between frontend expectations and backend

**Impact**: MEDIUM - Error messages may not display correctly
**Action**: Align error response format in next iteration

### End-to-End Integration Testing
**Status**: ✅ PASSED

**User Journeys Tested**:
1. User Registration: ✅ WORKING (created account, received token)
2. User Login: ✅ WORKING (authenticated successfully)
3. Protected Route Access: ✅ WORKING (redirects when unauthenticated)
4. Logout Flow: ✅ WORKING (clears session, redirects to login)

---

## Production Readiness Assessment

**Overall Status**: ✅ READY WITH NOTES

**Deployment Readiness**: READY
- Core functionality working end-to-end
- No critical or high severity issues
- Integration validated successfully
- Quality gates passed for all specialists

**Required Fixes Before Production**: NONE

**Recommended Improvements** (can be addressed post-launch):
1. Add rate limiting to prevent spam (backend - medium priority)
2. Improve error message consistency (all - medium priority)
3. Add loading states to API calls (frontend - medium priority)
4. Increase test coverage for edge cases (all - low priority)

---

## Summary

✅ **Multi-specialist coordination successful**
✅ **All specialists completed assigned work**
✅ **Integration validated end-to-end**
⚠️ **Minor documentation and consistency improvements needed**

**Timeline**: 1 hour 45 minutes (within estimate)
**Quality**: Production-ready with minor improvement opportunities

---

**Evidence Location**:
- Backend Verification: `.agency/handoff/auth/backend-architect/verification.md`
- Frontend Verification: `.agency/handoff/auth/frontend-developer/verification.md`
- Integration Contracts: `.agency/handoff/auth/integration/`
- Test Results: See individual verification reports

**Verified By**: reality-checker
**Next Steps**: Address recommended improvements in future sprint
```

---

## Integration Points

Successful multi-specialist coordination depends on well-defined integration points.

### API Contracts

**Owned by**: Backend specialist
**Consumed by**: Frontend, mobile, AI specialists

**Documentation requirements**:

#### Endpoint Specification
```markdown
## POST /api/auth/login

**Description**: Authenticate user with email and password

**Authentication**: None (public endpoint)

**Rate Limiting**: 5 requests per minute per IP

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "email": "string",      // Required, valid email format
  "password": "string"    // Required, min 8 characters
}
```

**Response (Success - 200)**:
```json
{
  "success": true,
  "data": {
    "token": "string",        // JWT access token (1 hour expiration)
    "refreshToken": "string", // Refresh token (7 days expiration)
    "user": {
      "id": "string",         // UUID v4
      "email": "string",
      "name": "string",
      "avatar": "string | null"
    }
  }
}
```

**Response (Error - 401 Unauthorized)**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```

**Response (Error - 422 Validation)**:
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": ["Invalid email format"],
      "password": ["Password must be at least 8 characters"]
    }
  }
}
```

**Response (Error - 429 Rate Limit)**:
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many login attempts. Please try again in 1 minute."
  }
}
```

**Example Request (curl)**:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123"
  }'
```

**Example Response**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "8f7d6e5c4b3a2...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": "John Doe",
      "avatar": null
    }
  }
}
```
```

### Shared Types

**Created by**: Any specialist (typically backend first)
**Location**: `integration/type-definitions.ts`
**Used by**: All specialists to ensure consistency

```typescript
/**
 * User entity representing an authenticated user
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 */
export interface User {
  id: string;           // UUID v4 format
  email: string;        // Validated email address
  name: string;         // Display name
  avatar?: string;      // Avatar URL (optional)
  createdAt: string;    // ISO 8601 timestamp
  updatedAt: string;    // ISO 8601 timestamp
}

/**
 * Authentication response from login/register endpoints
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 */
export interface AuthResponse {
  token: string;         // JWT access token (1 hour expiration)
  refreshToken: string;  // Refresh token (7 days expiration)
  user: User;           // Authenticated user object
}

/**
 * Standard API error response format
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 */
export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;                    // Error code (e.g., "INVALID_CREDENTIALS")
    message: string;                 // Human-readable error message
    details?: Record<string, string[]>; // Validation errors by field (optional)
  };
}

/**
 * Standard API success response format
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 */
export interface ApiSuccessResponse<T> {
  success: true;
  data: T;
}

/**
 * API response union type
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 */
export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;
```

### Environment Variables

**Documented by**: Each specialist for their domain
**Location**: Specialist's summary.md + root `.env.example`

**Example from backend-architect/summary.md**:
```markdown
## Environment Variables Required

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/myapp

# Authentication
JWT_SECRET=<secure-random-string-min-32-chars>
JWT_EXPIRATION=1h
REFRESH_TOKEN_EXPIRATION=7d

# Security
BCRYPT_SALT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100

# CORS
FRONTEND_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000,https://app.example.com

# Optional
REDIS_URL=redis://localhost:6379  # For session caching (optional)
```
```

### Integration Testing

**Created by**: Reality-checker or orchestrator
**Location**: `integration/integration-tests.md`

```markdown
# Integration Test Scenarios

## End-to-End User Journeys

### Journey 1: New User Registration

**Steps**:
1. Frontend: User visits /register page
2. Frontend: User fills form (email, name, password)
3. Frontend: Submit button clicked
4. Frontend: POST /api/auth/register with form data
5. Backend: Validate input (email format, password strength)
6. Backend: Check email not already registered
7. Backend: Hash password with bcrypt
8. Backend: Insert user into database
9. Backend: Generate JWT token and refresh token
10. Backend: Return 201 with tokens and user object
11. Frontend: Store tokens in localStorage
12. Frontend: Redirect to /dashboard
13. Frontend: Display user profile

**Expected Results**:
- ✅ User created in database
- ✅ JWT token valid and can be decoded
- ✅ Frontend authenticated state updated
- ✅ User redirected to dashboard
- ✅ User profile displayed correctly

**Test Data**:
```json
{
  "email": "newuser@example.com",
  "name": "New User",
  "password": "SecurePass123!"
}
```

**Validation Points**:
- [ ] Email uniqueness check works
- [ ] Password hashing applied (not stored in plain text)
- [ ] JWT token contains correct user ID
- [ ] Frontend receives and stores tokens
- [ ] Protected route accessible after registration

### Journey 2: Existing User Login

**Steps**:
1. Frontend: User visits /login page
2. Frontend: User enters email and password
3. Frontend: Submit button clicked
4. Frontend: POST /api/auth/login with credentials
5. Backend: Validate input format
6. Backend: Find user by email
7. Backend: Verify password with bcrypt.compare
8. Backend: Generate new JWT and refresh tokens
9. Backend: Return 200 with tokens and user object
10. Frontend: Store tokens in localStorage
11. Frontend: Redirect to /dashboard
12. Frontend: Fetch user data with authenticated request

**Expected Results**:
- ✅ Correct credentials accepted
- ✅ Invalid credentials rejected with 401
- ✅ JWT token valid and can be decoded
- ✅ Frontend authenticated state updated
- ✅ User redirected to dashboard

**Test Data (Valid)**:
```json
{
  "email": "existing@example.com",
  "password": "CorrectPassword123"
}
```

**Test Data (Invalid)**:
```json
{
  "email": "existing@example.com",
  "password": "WrongPassword"
}
```

**Validation Points**:
- [ ] Valid credentials return 200 with tokens
- [ ] Invalid password returns 401 error
- [ ] Non-existent email returns 401 error
- [ ] Rate limiting prevents brute force (5 attempts/min)
- [ ] JWT token contains correct user data

### Journey 3: Protected Route Access

**Steps**:
1. Frontend: User navigates to /dashboard (protected)
2. Frontend: Check if JWT token exists in localStorage
3. If NO token:
   - Frontend: Redirect to /login
4. If token exists:
   - Frontend: Include token in Authorization header
   - Frontend: GET /api/auth/user
   - Backend: Verify JWT signature and expiration
   - Backend: Extract user ID from token
   - Backend: Fetch user from database
   - Backend: Return 200 with user object
   - Frontend: Display dashboard with user data

**Expected Results**:
- ✅ Unauthenticated users redirected to /login
- ✅ Authenticated users can access dashboard
- ✅ Invalid/expired tokens rejected with 401
- ✅ User data fetched and displayed

**Validation Points**:
- [ ] Missing token redirects to login
- [ ] Invalid token returns 401
- [ ] Expired token returns 401
- [ ] Valid token grants access
- [ ] User data matches authenticated user
```

---

## PR/Issue Comments

After multi-specialist implementation completes, the orchestrator creates comprehensive PR/issue comments documenting the work.

### Multi-Specialist GitHub PR Comments

**Created by**: Orchestrator after completion
**Format**: Markdown with collapsible sections

```markdown
## Multi-Specialist Implementation: User Authentication ✅

**Specialists Involved**: 2
**Execution Strategy**: Sequential
**Duration**: 1 hour 45 minutes
**Overall Status**: ✅ VERIFIED WITH NOTES

---

### 🔧 Backend Architect

<details>
<summary><strong>API Endpoints & Database</strong> (45 minutes) - ✅ VERIFIED</summary>

**Work Completed**:
- ✅ POST /api/auth/login - User authentication
- ✅ POST /api/auth/register - User registration
- ✅ POST /api/auth/refresh - Token refresh
- ✅ POST /api/auth/logout - User logout
- ✅ GET /api/auth/user - Get authenticated user

**Database Schema**:
- ✅ `users` table with proper indexes
- ✅ `sessions` table for token management
- ✅ Migrations: 2 created, 2 applied

**Security**:
- ✅ Password hashing (bcrypt, 12 rounds)
- ✅ JWT tokens (1 hour expiration)
- ✅ Refresh tokens (7 days expiration)
- ✅ Input validation (Zod schemas)
- ⚠️ Rate limiting: Not implemented (recommended for future)

**Testing**:
- ✅ 15 tests passing (92% coverage)
- ✅ Performance: < 200ms response time (p95)

**Files Changed**: 12 created, 5 modified
**Verification**: See `.agency/handoff/auth/backend-architect/verification.md`

</details>

---

### 🎨 Frontend Developer

<details>
<summary><strong>UI Components & Authentication Flows</strong> (50 minutes) - ✅ VERIFIED</summary>

**Work Completed**:
- ✅ Login page with form validation
- ✅ Registration page with password strength indicator
- ✅ Protected route HOC with authentication check
- ✅ User profile component
- ✅ Authentication context provider

**Features**:
- ✅ Form validation (react-hook-form)
- ✅ Loading states during API calls
- ✅ Error handling and display
- ✅ Responsive design (mobile-first)
- ✅ Accessibility (WCAG AA compliant)

**Integration**:
- ✅ All backend API endpoints integrated
- ✅ JWT token management (localStorage)
- ✅ Automatic redirect on authentication state change
- ✅ Protected routes working correctly

**Testing**:
- ✅ 12 tests passing (87% coverage)
- ✅ Accessibility tests (axe, 0 violations)

**Files Changed**: 8 created, 4 modified
**Verification**: See `.agency/handoff/auth/frontend-developer/verification.md`

</details>

---

### 🔗 Integration Analysis

<details>
<summary><strong>Cross-Specialist Integration</strong> - ✅ VALIDATED</summary>

**API Contract Validation**: ⚠️ MINOR MISMATCHES
- ✅ All endpoints match frontend expectations
- ⚠️ Backend returns `refreshToken` not documented initially (docs updated)
- ⚠️ Error response format minor inconsistency (non-breaking)

**Type Consistency**: ⚠️ FORMAT DIFFERENCES
- ✅ User type matches across backend/frontend
- ⚠️ `createdAt` field: Backend returns ISO string, frontend expects Date (frontend parses correctly)

**End-to-End Testing**: ✅ ALL JOURNEYS PASSED
1. ✅ User Registration: Working end-to-end
2. ✅ User Login: Working end-to-end
3. ✅ Protected Route Access: Working end-to-end
4. ✅ Logout Flow: Working end-to-end

**Integration Status**: ✅ Production Ready

</details>

---

### 📊 Quality Metrics

| Metric | Backend | Frontend | Overall |
|--------|---------|----------|---------|
| Tests Passing | 15/15 (100%) | 12/12 (100%) | 27/27 (100%) |
| Test Coverage | 92% | 87% | 90% |
| Build Status | ✅ Pass | ✅ Pass | ✅ Pass |
| Type Check | ✅ Pass | ✅ Pass | ✅ Pass |
| Linter | ✅ Pass | ✅ Pass | ✅ Pass |
| Verification | ✅ Verified | ✅ Verified | ✅ Verified |

---

### 📁 Handoff Documentation

**Location**: `.agency/handoff/user-authentication/`

- **Backend Plan**: `backend-architect/plan.md`
- **Backend Summary**: `backend-architect/summary.md`
- **Backend Verification**: `backend-architect/verification.md`
- **Frontend Plan**: `frontend-developer/plan.md`
- **Frontend Summary**: `frontend-developer/summary.md`
- **Frontend Verification**: `frontend-developer/verification.md`
- **API Contracts**: `integration/api-contract.md`
- **Type Definitions**: `integration/type-definitions.ts`
- **Reality Check Report**: `reality-check-report.md`

---

### ⚠️ Recommended Improvements (Post-Launch)

**Medium Priority**:
1. Add rate limiting to registration endpoint (prevent spam accounts)
2. Improve error message consistency across API
3. Add loading states to all API calls (better UX)

**Low Priority**:
1. Increase test coverage for edge cases
2. Add API documentation (JSDoc/OpenAPI)
3. Optimize API response times (currently 150ms, target <100ms)

---

### ✅ Production Readiness

**Status**: READY FOR DEPLOYMENT

**Reasoning**:
- ✅ All core functionality working end-to-end
- ✅ No critical or high severity issues
- ✅ Integration validated successfully
- ✅ All quality gates passed
- ⚠️ Minor improvements can be addressed post-launch

**Deployment Checklist**:
- [ ] Environment variables configured in production
- [ ] Database migrations applied
- [ ] SSL certificates configured (for secure cookies)
- [ ] CORS whitelist updated with production domain
- [ ] Monitoring and logging configured

---

**Implemented by**: Agency Multi-Specialist Workflow
**Orchestrated by**: `/agency:implement user-authentication-plan`
**Verified by**: reality-checker agent
```

### Multi-Specialist Jira ADF Comments

**Format**: Atlassian Document Format (ADF) JSON for Jira

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [
        {
          "type": "text",
          "text": "Multi-Specialist Implementation: User Authentication ",
          "marks": []
        },
        {
          "type": "emoji",
          "attrs": { "shortName": ":white_check_mark:" }
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        { "type": "text", "text": "Specialists Involved: ", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": "2" },
        { "type": "hardBreak" },
        { "type": "text", "text": "Execution Strategy: ", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": "Sequential" },
        { "type": "hardBreak" },
        { "type": "text", "text": "Duration: ", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": "1 hour 45 minutes" },
        { "type": "hardBreak" },
        { "type": "text", "text": "Overall Status: ", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": "VERIFIED WITH NOTES", "marks": [{ "type": "strong" }, { "type": "textColor", "attrs": { "color": "#00875a" } }] }
      ]
    },
    {
      "type": "rule"
    },
    {
      "type": "expand",
      "attrs": { "title": "Backend Architect (45 minutes) - VERIFIED" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Work Completed:", "marks": [{ "type": "strong" }] }
          ]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " POST /api/auth/login - User authentication" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " POST /api/auth/register - User registration" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Database schema: users and sessions tables" }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Security:", "marks": [{ "type": "strong" }] }
          ]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Password hashing (bcrypt, 12 rounds)" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " JWT tokens (1 hour expiration)" }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Files Changed: ", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "12 created, 5 modified" }
          ]
        }
      ]
    },
    {
      "type": "expand",
      "attrs": { "title": "Frontend Developer (50 minutes) - VERIFIED" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Work Completed:", "marks": [{ "type": "strong" }] }
          ]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Login page with form validation" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Registration page with password strength indicator" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Protected route system with authentication" }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Integration:", "marks": [{ "type": "strong" }] }
          ]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " All backend API endpoints integrated" }
                  ]
                }
              ]
            },
            {
              "type": "listItem",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " JWT token management working" }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Files Changed: ", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "8 created, 4 modified" }
          ]
        }
      ]
    },
    {
      "type": "rule"
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [
        { "type": "text", "text": "Quality Metrics" }
      ]
    },
    {
      "type": "table",
      "content": [
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableHeader",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Metric" }] }]
            },
            {
              "type": "tableHeader",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Backend" }] }]
            },
            {
              "type": "tableHeader",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Frontend" }] }]
            },
            {
              "type": "tableHeader",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Overall" }] }]
            }
          ]
        },
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Tests Passing" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "15/15 (100%)" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "12/12 (100%)" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "27/27 (100%)" }] }]
            }
          ]
        },
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Coverage" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "92%" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "87%" }] }]
            },
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "90%" }] }]
            }
          ]
        },
        {
          "type": "tableRow",
          "content": [
            {
              "type": "tableCell",
              "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Verification" }] }]
            },
            {
              "type": "tableCell",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Verified" }
                  ]
                }
              ]
            },
            {
              "type": "tableCell",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Verified" }
                  ]
                }
              ]
            },
            {
              "type": "tableCell",
              "content": [
                {
                  "type": "paragraph",
                  "content": [
                    { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                    { "type": "text", "text": " Verified" }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "rule"
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [
        { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
        { "type": "text", "text": " Production Readiness" }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        { "type": "text", "text": "Status: ", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": "READY FOR DEPLOYMENT", "marks": [{ "type": "strong" }, { "type": "textColor", "attrs": { "color": "#00875a" } }] }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        { "type": "text", "text": "Reasoning:", "marks": [{ "type": "strong" }] }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                { "type": "text", "text": " All core functionality working end-to-end" }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                { "type": "text", "text": " No critical or high severity issues" }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                { "type": "text", "text": " Integration validated successfully" }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "emoji", "attrs": { "shortName": ":white_check_mark:" } },
                { "type": "text", "text": " All quality gates passed" }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Collapsible Specialist Summaries

Both GitHub and Jira comments use collapsible sections (GitHub `<details>`, Jira `expand` blocks) to:

1. **Keep comments concise**: Top-level view shows overall status
2. **Provide detail on demand**: Users can expand sections for specifics
3. **Organize by specialist**: Clear separation of concerns
4. **Highlight status**: Visual indicators (✅, ⚠️, ❌) for quick scanning

### Overall Status Indicators

**Status Badge System**:
- ✅ **VERIFIED**: No critical/high issues, ready to proceed
- ⚠️ **VERIFIED WITH NOTES**: Minor issues documented, non-blocking
- ❌ **NEEDS_WORK**: Critical/high issues require fixes

**Color Coding** (where supported):
- Green: Success, verified, passed
- Yellow: Warnings, notes, minor issues
- Red: Failures, critical issues, blockers

---

## Supported Specialists

The handoff system supports coordination between these specialist agents:

### 1. frontend-developer

**Domain**: Modern web UI, React, Next.js, responsive design
**Typical Responsibilities**:
- Component development (React, Vue, Angular)
- UI implementation from designs
- Client-side state management
- API integration (consuming backend endpoints)
- Responsive and accessible design
- Performance optimization (Core Web Vitals)

**Keywords**: React, component, UI, form, button, Tailwind, CSS, responsive, Next.js, routing, hook, JSX

**Integration Points**:
- **Consumes**: Backend API endpoints, type definitions
- **Provides**: UI components, frontend build artifacts, component documentation

### 2. backend-architect

**Domain**: Server-side architecture, APIs, databases, scalability
**Typical Responsibilities**:
- REST/GraphQL API development
- Database schema design and migrations
- Authentication and authorization
- Business logic implementation
- Performance optimization (caching, indexing)
- API security (input validation, rate limiting)

**Keywords**: API, endpoint, REST, GraphQL, database, schema, Prisma, SQL, JWT, authentication, Express

**Integration Points**:
- **Consumes**: Infrastructure (from DevOps), data requirements (from frontend/mobile)
- **Provides**: API endpoints, database schemas, type definitions, API documentation

### 3. ai-engineer

**Domain**: Machine learning, AI integration, data pipelines
**Typical Responsibilities**:
- ML model training and deployment
- AI feature implementation (RAG, embeddings, LLM integration)
- Data pipeline development
- Model monitoring and optimization
- Bias testing and AI ethics
- Inference API creation

**Keywords**: AI, ML, model, embedding, vector, RAG, LLM, GPT, OpenAI, training, inference, NLP

**Integration Points**:
- **Consumes**: Backend data access, infrastructure (GPU resources)
- **Provides**: ML models, inference APIs, embedding services, AI feature documentation

### 4. mobile-app-builder

**Domain**: Native mobile applications (iOS, Android, React Native)
**Typical Responsibilities**:
- Native app development (iOS/Android)
- Cross-platform development (React Native, Flutter)
- Mobile UI/UX implementation
- Offline data sync
- Push notifications
- App store optimization

**Keywords**: mobile, iOS, Android, React Native, Swift, Kotlin, native, push notification, offline, sync

**Integration Points**:
- **Consumes**: Backend APIs (same as web frontend)
- **Provides**: Mobile app builds, app store assets, mobile-specific features

### 5. devops-automator

**Domain**: Infrastructure, CI/CD, deployment, monitoring
**Typical Responsibilities**:
- Infrastructure provisioning (AWS, GCP, Azure)
- CI/CD pipeline setup
- Deployment automation
- Monitoring and logging
- Container orchestration (Docker, Kubernetes)
- Performance and security optimization

**Keywords**: deployment, CI/CD, Docker, Kubernetes, infrastructure, AWS, Terraform, monitoring, scaling

**Integration Points**:
- **Consumes**: Application code, deployment requirements
- **Provides**: Infrastructure, deployment pipelines, monitoring dashboards, environment configs

### 6. senior-developer

**Domain**: Architecture review, code quality, best practices
**Typical Responsibilities**:
- Architecture planning and review
- Technical debt assessment
- Code review and quality standards
- Scalability analysis
- Best practice recommendations
- Cross-team coordination

**Keywords**: architecture, design pattern, refactor, technical debt, code review, best practice, scalability

**Integration Points**:
- **Consumes**: Technical requirements, system constraints
- **Provides**: Architecture plans, technical guidance, quality standards

### 7. rapid-prototyper

**Domain**: Quick MVPs, prototypes, proof of concepts
**Typical Responsibilities**:
- Rapid feature prototyping
- MVP development
- Technical feasibility demos
- Experimental implementations
- Quick mockups and wireframes

**Keywords**: prototype, MVP, quick, demo, proof of concept, experimental, mockup

**Integration Points**:
- **Consumes**: Feature requirements, design mockups
- **Provides**: Working prototypes, feasibility reports, demo applications

### Additional Specialists

The system also supports:
- **ux-architect**: User experience design, research, interaction patterns
- **ui-designer**: Visual design, brand consistency, design systems
- **project-shepherd**: Project management, sprint planning, coordination
- **reality-checker**: Quality assurance, integration testing, production readiness

Each specialist can be integrated into the multi-specialist handoff system following the same patterns.

---

## Examples

### Example 1: Full-Stack Authentication (Backend + Frontend)

**Feature**: User authentication with login, register, and protected routes

#### Detection Phase

**Keyword Analysis**:
```
Backend Architect:
- Keywords: API, endpoint, database, authentication, JWT, Prisma, schema
- Score: 3.5 (NEEDED)

Frontend Developer:
- Keywords: React, component, form, UI, Tailwind, routing
- Score: 2.5 (NEEDED)
```

**Dependency Detection**:
```
Strategy: Sequential
Reason: Frontend login UI needs backend authentication API
Order: backend-architect → frontend-developer
```

#### Execution

**Backend Architect** (45 minutes):
1. Reads `plan.md`: Implement auth API, database schema, JWT tokens
2. Implements:
   - POST /api/auth/login, /api/auth/register endpoints
   - Users table with indexes
   - JWT token generation/verification
   - Password hashing (bcrypt)
3. Creates `summary.md`: Documents API contracts, type definitions
4. Creates `files-changed.json`: 12 files created, 5 modified
5. Verified by reality-checker: ✅ PASSED

**Frontend Developer** (50 minutes):
1. Reads `plan.md`: Implement login/register UI, protected routes
2. Reads `backend-architect/summary.md`: Gets API contracts
3. Implements:
   - Login page with form validation
   - Register page with password strength
   - Protected route HOC
   - Authentication context
4. Creates `summary.md`: Documents components, integration
5. Creates `files-changed.json`: 8 files created, 4 modified
6. Verified by reality-checker: ✅ PASSED

#### Integration Review

**Cross-Specialist Validation**:
- ✅ API contracts match (frontend calls match backend endpoints)
- ✅ Type definitions consistent (User interface aligned)
- ⚠️ Minor error format difference (non-breaking)

**End-to-End Testing**:
- ✅ User registration working
- ✅ User login working
- ✅ Protected routes redirecting correctly
- ✅ Logout clearing session

**Result**: ✅ VERIFIED - Ready for production

---

### Example 2: AI-Powered Search (AI + Backend + Frontend)

**Feature**: Semantic search with embeddings and LLM-powered results

#### Detection Phase

**Keyword Analysis**:
```
AI Engineer:
- Keywords: AI, embedding, vector, RAG, LLM, semantic, search
- Score: 3.5 (NEEDED)

Backend Architect:
- Keywords: API, database, endpoint, indexing
- Score: 2.0 (NEEDED)

Frontend Developer:
- Keywords: React, component, UI, search, form
- Score: 2.5 (NEEDED)
```

**Dependency Detection**:
```
Strategy: Sequential
Reason: Backend needs AI embeddings, Frontend needs Backend search API
Order: ai-engineer → backend-architect → frontend-developer
```

#### Execution

**AI Engineer** (60 minutes):
1. Reads `plan.md`: Implement embedding generation, vector storage, RAG pipeline
2. Implements:
   - Embedding model integration (all-MiniLM-L6-v2)
   - Vector database setup (Pinecone)
   - RAG pipeline (retrieve → rank → generate)
   - Batch embedding scripts
3. Creates `summary.md`: Documents embedding API, vector schemas
4. Creates `files-changed.json`: 15 files created, 6 modified
5. Verified by reality-checker: ✅ PASSED

**Backend Architect** (40 minutes):
1. Reads `plan.md`: Integrate AI embeddings into search API
2. Reads `ai-engineer/summary.md`: Gets embedding API contracts
3. Implements:
   - GET /api/search/semantic endpoint
   - Integration with AI embedding service
   - Caching layer for search results
   - Search history tracking
4. Creates `summary.md`: Documents search API
5. Creates `files-changed.json`: 8 files created, 3 modified
6. Verified by reality-checker: ✅ PASSED

**Frontend Developer** (45 minutes):
1. Reads `plan.md`: Implement search UI with real-time results
2. Reads `backend-architect/summary.md`: Gets search API contracts
3. Implements:
   - Search input with autocomplete
   - Real-time result streaming
   - Result highlighting
   - Loading states and error handling
4. Creates `summary.md`: Documents search components
5. Creates `files-changed.json`: 6 files created, 2 modified
6. Verified by reality-checker: ✅ PASSED

#### Integration Review

**Cross-Specialist Validation**:
- ✅ AI embedding API integrated correctly into backend
- ✅ Backend search API consumes embeddings properly
- ✅ Frontend displays search results correctly
- ✅ Type definitions consistent (SearchResult interface)

**End-to-End Testing**:
- ✅ Search query → embedding generation → vector search → LLM response
- ✅ Real-time streaming working
- ✅ Result highlighting accurate
- ✅ Error handling working

**Result**: ✅ VERIFIED - Ready for production

---

### Example 3: Mobile App with Backend (Backend + Mobile)

**Feature**: E-commerce mobile app with product catalog and checkout

#### Detection Phase

**Keyword Analysis**:
```
Backend Architect:
- Keywords: API, database, GraphQL, product, order, payment
- Score: 3.0 (NEEDED)

Mobile App Builder:
- Keywords: mobile, iOS, Android, React Native, native, app
- Score: 3.5 (NEEDED)
```

**Dependency Detection**:
```
Strategy: Sequential
Reason: Mobile app consumes backend GraphQL API
Order: backend-architect → mobile-app-builder
```

#### Execution

**Backend Architect** (70 minutes):
1. Reads `plan.md`: Implement GraphQL API for products, orders, payments
2. Implements:
   - GraphQL schema (Product, Order, Cart types)
   - Product catalog queries and mutations
   - Order creation and payment processing
   - Stripe payment integration
3. Creates `summary.md`: Documents GraphQL schema, operations
4. Creates `files-changed.json`: 18 files created, 7 modified
5. Verified by reality-checker: ✅ PASSED

**Mobile App Builder** (90 minutes):
1. Reads `plan.md`: Implement native mobile app with catalog and checkout
2. Reads `backend-architect/summary.md`: Gets GraphQL schema
3. Implements:
   - Product listing screen (React Native)
   - Product detail screen with add to cart
   - Shopping cart with quantity controls
   - Checkout flow with payment (Stripe)
   - Offline mode with local storage
4. Creates `summary.md`: Documents mobile screens, data flow
5. Creates `files-changed.json`: 25 files created, 8 modified
6. Verified by reality-checker: ✅ PASSED

#### Integration Review

**Cross-Specialist Validation**:
- ✅ GraphQL queries match backend schema
- ✅ Product data types consistent
- ✅ Payment flow working end-to-end
- ✅ Offline sync working correctly

**End-to-End Testing**:
- ✅ Browse products → add to cart → checkout → payment
- ✅ Offline mode stores cart locally
- ✅ Payment processing (Stripe test mode)
- ✅ Order confirmation displayed

**Result**: ✅ VERIFIED - Ready for app store submission

---

## Best Practices

### When to Use Multi-Specialist

**Use multi-specialist for**:
- ✅ Full-stack features requiring both UI and API
- ✅ AI-powered features needing ML model + backend + frontend
- ✅ Mobile apps requiring native development + backend services
- ✅ Complex features spanning multiple technology layers
- ✅ Features requiring specialized expertise in different domains

**Don't use multi-specialist for**:
- ❌ Single-domain changes (e.g., CSS styling only)
- ❌ Bug fixes confined to one layer
- ❌ Refactoring within a single codebase
- ❌ Simple features implementable by one specialist

### How to Write Good Handoff Plans

**Per-Specialist Plans Should**:
1. **Be Focused**: Only include tasks relevant to this specialist
2. **Be Specific**: Clear, actionable tasks (not vague goals)
3. **Include Context**: Multi-specialist awareness (who else is working)
4. **Define Dependencies**: What you need from others, what others need from you
5. **Set Success Criteria**: How reality-checker will verify completion

**Example Good Plan**:
```markdown
## Your Responsibilities

✅ Implement authentication API with these endpoints:
   - POST /api/auth/login (email/password → JWT token)
   - POST /api/auth/register (user data → JWT token)
   - GET /api/auth/user (JWT → user profile)

✅ Create database schema:
   - users table (id, email, password_hash, name, created_at)
   - sessions table (id, user_id, token_hash, expires_at)
   - Indexes on email (unique), user_id, token_hash

✅ Security requirements:
   - bcrypt password hashing (12 rounds minimum)
   - JWT tokens (1 hour expiration)
   - Input validation with Zod schemas
```

**Example Bad Plan**:
```markdown
## Your Responsibilities

- Build authentication (too vague)
- Make it secure (unclear success criteria)
- Create database stuff (what tables? what fields?)
```

### Integration Contract Guidelines

**Good API Contracts Include**:
1. **Endpoint URL and method**: `POST /api/auth/login`
2. **Request schema**: Required fields, types, validation rules
3. **Success response schema**: Status code, data structure
4. **Error response schemas**: All possible error codes with examples
5. **Authentication requirements**: Headers, tokens, cookies
6. **Rate limiting**: Requests per minute/hour
7. **Examples**: curl commands, actual request/response JSON

**Good Type Definitions Include**:
1. **JSDoc comments**: Explain what each type represents
2. **Field documentation**: What each field contains, format constraints
3. **Creation metadata**: Who created this type, who uses it
4. **Example values**: Help other specialists understand usage

**Example**:
```typescript
/**
 * User entity representing an authenticated user
 *
 * @created-by backend-architect
 * @used-by frontend-developer, mobile-app-builder
 *
 * @example
 * {
 *   id: "550e8400-e29b-41d4-a716-446655440000",
 *   email: "user@example.com",
 *   name: "John Doe",
 *   createdAt: "2024-12-12T14:30:00Z"
 * }
 */
export interface User {
  id: string;           // UUID v4 format
  email: string;        // Validated email address
  name: string;         // Display name (1-100 chars)
  avatar?: string;      // Avatar URL (optional)
  createdAt: string;    // ISO 8601 timestamp
  updatedAt: string;    // ISO 8601 timestamp
}
```

### Testing Multi-Specialist Features

**Per-Specialist Testing**:
1. **Unit tests**: Test individual functions/components
2. **Integration tests**: Test specialist's code with dependencies
3. **Coverage targets**: ≥80% for critical paths
4. **Quality gates**: Build, type-check, lint must pass

**Cross-Specialist Testing**:
1. **API contract tests**: Verify frontend calls match backend responses
2. **Type consistency tests**: Ensure shared types match across layers
3. **End-to-end tests**: Test complete user journeys across all specialists
4. **Performance tests**: Validate response times, load handling

**Example E2E Test Scenario**:
```javascript
describe('User Authentication E2E', () => {
  it('should allow new user to register and login', async () => {
    // Frontend: Navigate to registration page
    await page.goto('/register');

    // Frontend: Fill and submit form
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('button[type="submit"]');

    // Backend: Verify user created in database
    const user = await db.users.findOne({ email: 'newuser@example.com' });
    expect(user).toBeTruthy();
    expect(user.password).not.toBe('SecurePass123!'); // Password hashed

    // Frontend: Verify redirect to dashboard
    await page.waitForURL('/dashboard');

    // Frontend: Verify user profile displayed
    const username = await page.textContent('[data-testid="username"]');
    expect(username).toBe('newuser@example.com');

    // Frontend: Logout
    await page.click('[data-testid="logout"]');

    // Frontend: Verify redirect to login
    await page.waitForURL('/login');

    // Frontend: Login with same credentials
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('button[type="submit"]');

    // Frontend: Verify successful login and dashboard access
    await page.waitForURL('/dashboard');
    expect(await page.textContent('[data-testid="username"]')).toBe('newuser@example.com');
  });
});
```

### Communication and Escalation

**When to Ask Questions**:
- ✅ Plan is ambiguous or contradictory
- ✅ Dependencies from other specialists unclear
- ✅ Integration contracts missing or incomplete
- ✅ Technical constraints make plan infeasible
- ✅ Security or performance concerns

**How to Document Issues**:
1. **Be specific**: "API returns `userId` but frontend expects `id`" (not "types don't match")
2. **Provide evidence**: Link to code, show examples
3. **Suggest solutions**: Don't just identify problems
4. **Classify severity**: CRITICAL, HIGH, MEDIUM, LOW

**Escalation Path**:
1. **Specialist → Specialist**: Try to resolve integration issues directly
2. **Specialist → Orchestrator**: Escalate if cross-specialist coordination needed
3. **Orchestrator → User**: Escalate if architectural decision or timeline impact

### Common Pitfalls to Avoid

**Don't**:
1. ❌ Skip documentation of integration points ("they'll figure it out")
2. ❌ Change shared types without coordinating with other specialists
3. ❌ Assume dependencies met without checking execution-state.json
4. ❌ Add features outside your assigned scope (scope creep)
5. ❌ Merge PRs before all specialists complete and verify
6. ❌ Skip verification (reality-checker catches issues early)
7. ❌ Run parallel execution when sequential dependencies exist

**Do**:
1. ✅ Document all integration contracts before starting
2. ✅ Verify previous specialist completed before starting sequential work
3. ✅ Create comprehensive summary.md for next specialist
4. ✅ Test integration points, not just your isolated code
5. ✅ Ask questions early when requirements unclear
6. ✅ Track all file changes in files-changed.json
7. ✅ Wait for reality-checker verification before handoff

---

## Conclusion

The multi-specialist handoff system enables complex features to be implemented with the right expertise at each layer, while maintaining clear integration contracts, quality standards, and evidence-based verification. By following this guide, teams can coordinate multiple specialists effectively, catch integration issues early, and deliver production-ready features with confidence.

**Key Takeaways**:
1. Use keyword scoring to detect when multiple specialists are needed
2. Choose sequential execution when dependencies exist, parallel when independent
3. Create focused per-specialist plans with clear responsibilities
4. Document integration contracts (API specs, types, environment) thoroughly
5. Verify each specialist's work before allowing handoff
6. Validate cross-specialist integration with end-to-end testing
7. Communicate via structured handoff directory (plans, summaries, verifications)

For more information, see:
- `/agency:implement` command documentation
- Individual specialist agent definitions
- Reality-checker verification procedures
- GitHub/Jira integration guides
