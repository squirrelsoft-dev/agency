# Planning: Plan Validation

Validate that a plan is complete before starting implementation.

## When to Use

**Before implementation starts**:
- In `implement.md` Phase 1
- In `work.md` after plan creation
- In `plan.md` before presenting to user

**Purpose**: Catch incomplete/ambiguous plans early, before wasting time on implementation.

---

## Extract Plan Components

Parse the plan file and extract:

### Required Components

- **Objective**: What are we building? (1-3 sentences)
- **Requirements**: List of functional requirements (3+ items)
- **File Changes**: Which files will be created/modified (1+ files)
- **Implementation Steps**: Ordered sequence of tasks (3+ steps)
- **Success Criteria**: How to verify completion (2+ criteria)
- **Dependencies**: External libraries, APIs, services (if applicable)

### Optional Components

- **Architecture Decisions**: Technical approach rationale
- **Testing Strategy**: How to validate the implementation
- **Rollback Plan**: How to undo if needed
- **Performance Targets**: Expected benchmarks
- **Security Considerations**: Auth, validation, etc.

---

## Validation Checklist

Check the plan has:

- [ ] **Clear objective statement**
  - Not vague ("improve the app")
  - Specific ("add JWT authentication to user API")

- [ ] **At least 3 implementation steps**
  - Actionable steps, not goals
  - Ordered logically
  - Reasonably scoped

- [ ] **List of files to modify/create**
  - Specific file paths
  - Not "various files" or "TBD"

- [ ] **Success criteria defined**
  - Testable criteria
  - Not just "it works"
  - Includes verification steps

- [ ] **No placeholder text**
  - No [TODO], [TBD], [FILL IN], etc.
  - No "we'll figure this out later"
  - No missing sections

- [ ] **Dependencies identified**
  - External libraries listed
  - APIs/services documented
  - Version constraints specified (if critical)

- [ ] **Scope is reasonable**
  - Not too broad ("rebuild the entire app")
  - Not too narrow ("change one variable name")
  - Can be completed in one work session

---

## Validation Failures

### If Plan is Incomplete

```
Use AskUserQuestion tool:

"**Plan Validation Failed**

The plan is missing:
- [LIST MISSING COMPONENTS]

Cannot proceed with implementation until plan is complete.

Options:
1. Add missing information now
2. Return to planning phase
3. Cancel implementation"
```

**Do NOT proceed** if plan validation fails.

### If Plan is Ambiguous

```
Use AskUserQuestion tool:

"**Plan Needs Clarification**

Ambiguous sections:
- [SECTION 1]: [WHY AMBIGUOUS]
- [SECTION 2]: [WHY AMBIGUOUS]

Please clarify before implementation:
[SPECIFIC QUESTIONS]"
```

Get clarification before proceeding.

---

## Common Plan Issues

### Issue 1: Vague Objective

**Bad**: "Make the app better"
**Good**: "Add real-time notifications using WebSockets"

**Fix**: Ask user to specify what exactly should be built.

### Issue 2: Missing File List

**Bad**: "Update authentication files"
**Good**:
```
Files to modify:
- src/auth/jwt.ts - Add token refresh
- src/middleware/auth.ts - Update verification
- src/types/user.ts - Add refresh token fields
```

**Fix**: Ask user to specify which files will be changed and how.

### Issue 3: Non-Actionable Steps

**Bad**:
```
1. Improve authentication
2. Make it secure
3. Test it
```

**Good**:
```
1. Install jsonwebtoken library
2. Create JWT generation function in src/auth/jwt.ts
3. Add token verification middleware in src/middleware/auth.ts
4. Update user login endpoint to return JWT
5. Add refresh token endpoint
6. Write unit tests for JWT functions
```

**Fix**: Ask user to break down vague steps into specific actions.

### Issue 4: Untestable Success Criteria

**Bad**: "Authentication should work"
**Good**:
```
Success Criteria:
- User can login with valid credentials and receive JWT
- JWT includes user ID and expiration
- Protected endpoints reject requests without valid JWT
- Token refresh endpoint generates new JWT
- All unit tests pass (>80% coverage)
```

**Fix**: Ask user how to verify each requirement is working.

---

## Edge Cases

### Partial Plan (Iterative Development)

If plan explicitly states it's a partial implementation:
```
"Phase 1 of 3: Backend API only, frontend in Phase 2"
```

**Valid** - Proceed with clearly scoped partial implementation.

### Research/Exploration Plan

If plan is for research:
```
"Investigate GraphQL vs tRPC for API layer"
```

**Different validation** - Check for:
- Research questions defined
- Evaluation criteria specified
- Decision timeline

### Bug Fix Plan

If plan is a bug fix:
```
"Fix: Users can't login after password reset"
```

**Different validation** - Check for:
- Bug reproduction steps
- Root cause hypothesis
- Proposed fix
- Verification steps

---

## Validation Output

After validation:

```markdown
## Plan Validation: [PASS/FAIL]

**Objective**: ✅ Clear and specific
**Requirements**: ✅ 5 requirements defined
**File Changes**: ✅ 7 files listed
**Implementation Steps**: ✅ 12 actionable steps
**Success Criteria**: ✅ 4 testable criteria
**Dependencies**: ✅ 2 libraries identified
**Placeholders**: ✅ None found

**Scope Assessment**: Reasonable (estimated 60-90 min implementation)

**Validation**: PASSED - Ready for implementation
```

OR

```markdown
## Plan Validation: FAILED

**Issues Found**:
- ❌ Objective too vague: "improve authentication"
- ❌ Only 2 implementation steps (need 3+)
- ❌ No success criteria defined
- ❌ Placeholder text found: [TODO: Add database schema]

**Validation**: FAILED - Cannot proceed
**Recommendation**: Ask user for clarification
```
