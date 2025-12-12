# Code Review: Reality Checker Spawn

Spawn the reality-checker agent to review implementation.

## When to Use

**Trigger after**:
- Specialist completes implementation
- All quality gates pass (build, type-check, lint, tests)
- Before marking work as complete

**Purpose**:
- Verify plan compliance
- Find bugs and logic errors
- Identify security vulnerabilities
- Check code quality
- Validate integration points (multi-specialist)

---

## Single-Specialist Review

**Task Tool Configuration**:
```
Tool: Task
subagent_type: testing-reality-checker
description: "Review implementation of [plan-filename/issue-id]"
```

**Prompt Template**:
```markdown
Review the implementation for:

**Plan Compliance**:
- All requirements from the plan implemented
- No extra features added beyond plan scope
- Success criteria met
- All specified files created/modified

**Code Quality**:
- No obvious bugs or logic errors
- Follows project coding standards
- Proper error handling
- No hardcoded values that should be configurable
- Efficient algorithms and data structures

**Security**:
- No SQL injection vulnerabilities
- No XSS vulnerabilities
- No exposed secrets or credentials
- Proper input validation
- Authentication/authorization checks

**Performance**:
- No obvious performance issues
- No unnecessary re-renders (React)
- Proper database indexing (if applicable)
- Efficient queries and data fetching

**Testing**:
- Tests adequately cover the implementation
- Edge cases tested
- Error paths tested

**Files to review**: [list of modified/created files]

Provide findings with severity levels:
- **CRITICAL**: Must fix before merge (security, data loss, crashes)
- **HIGH**: Should fix before merge (bugs, incorrect behavior)
- **MEDIUM**: Consider fixing (code quality, performance)
- **LOW**: Nice to have (style, minor improvements)

**Focus on CRITICAL and HIGH severity issues only.**
```

---

## Multi-Specialist Review

**Per-Specialist Verification**:

For EACH specialist that worked:

```
Tool: Task
subagent_type: testing-reality-checker
description: "Verify [SPECIALIST] work for [feature]"
```

**Prompt Template**:
```markdown
**Multi-Specialist Verification Mode**

Specialist: [SPECIALIST_NAME]
Feature: [FEATURE_NAME]
Handoff Directory: .agency/handoff/[FEATURE]/[SPECIALIST]/

**Inputs**:
- Plan: .agency/handoff/[FEATURE]/[SPECIALIST]/plan.md
- Summary: .agency/handoff/[FEATURE]/[SPECIALIST]/summary.md
- Files: [list from files-changed.json]

**Verification Checklist**:

✅ **Plan Compliance**
- All tasks in plan.md completed
- Summary matches plan scope
- No extra features added

✅ **Code Quality**
- No bugs in changed files
- Follows project patterns
- Proper error handling

✅ **Security**
- No vulnerabilities introduced
- Proper validation at boundaries

✅ **Tests**
- Adequate test coverage
- All tests passing

✅ **Integration Points**
- APIs/interfaces documented
- Contracts match expectations
- Ready for handoff to dependent specialists

**Output**: Write findings to .agency/handoff/[FEATURE]/[SPECIALIST]/verification.md

**Severity Levels**: CRITICAL, HIGH, MEDIUM, LOW

**If CRITICAL issues found**:
- Document issues clearly
- Suggest specific fixes
- Mark verification as FAILED
```

---

## Integrated Review (Multi-Specialist)

**After ALL specialists verified individually**, run one integrated review:

```
Tool: Task
subagent_type: code-reviewer
description: "Multi-specialist integration review for [feature]"
```

**Prompt Template**:
```markdown
**Multi-Specialist Integration Review**

Feature: [FEATURE_NAME]
Specialists: [LIST_OF_SPECIALISTS]
Handoff Directory: .agency/handoff/[FEATURE]/

**Context**:
- Read ALL specialist summaries
- Review ALL files changed across all specialists
- Check integration points between specialists

**Focus Areas**:

1. **Cross-Specialist Integration**
   - Frontend ↔ Backend: API contracts match
   - Mobile ↔ Backend: Data formats consistent
   - AI ↔ Backend: Model integration correct
   - Data types aligned across boundaries

2. **Consistency**
   - Naming conventions consistent
   - Error handling patterns aligned
   - Code style uniform

3. **Overall Architecture**
   - Components work together
   - No architectural conflicts
   - Scalability maintained

4. **Security Across Boundaries**
   - Authentication flows complete
   - Authorization checks at all layers
   - Data validation at system boundaries

**Organize Findings**:
- By specialist (backend issues, frontend issues)
- By integration point (API contract mismatches)
- Overall concerns

**Output Format**: Standard code review with severity levels
```

---

## Handling Review Findings

**CRITICAL or HIGH issues found**:
1. Read review findings carefully
2. Fix each critical/high issue
3. Re-run quality gates if changes are significant
4. Re-run reality-checker to verify fixes
5. **Maximum 3 fix iterations** - escalate to user after that

**MEDIUM or LOW issues**:
- Document in implementation summary
- User decides whether to address
- Don't block completion

---

## Fix Loop

```
Loop (max 3 iterations):
  1. Reality-checker finds CRITICAL/HIGH issues
  2. Fix issues
  3. Re-run quality gates (if needed)
  4. Re-run reality-checker
  5. If PASS → Exit loop
  6. If FAIL → Continue loop

After 3 iterations:
  - Document remaining issues
  - Ask user for guidance
  - Don't auto-fix further (risk making it worse)
```
