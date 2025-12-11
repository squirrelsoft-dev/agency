# Agency Quality Gates Standard

## Overview

This document defines the unified quality gates standard for all Agency orchestrators. Quality gates are checkpoints that ensure code meets specified criteria before progressing to the next phase of development.

**Last Updated**: 2024-12-11
**Applies To**: All orchestrator agents (orchestrator-agent, agents-orchestrator)

---

## Quality Gate Philosophy

### Core Principles

1. **Safety First**: Mandatory gates prevent critical issues from reaching production
2. **Flexibility**: Optional gates adapt to project context and requirements
3. **Fast Feedback**: Gates provide immediate, actionable feedback
4. **Measurable**: All gates have clear pass/fail criteria
5. **Automated**: Gates run automatically with minimal manual intervention

### Gate Categories

- **Mandatory Gates**: Must pass before proceeding (4 gates)
- **Optional Gates**: Context-dependent, can be skipped with documentation (4 gates)

---

## Mandatory Gates

All orchestrators MUST enforce these gates. No exceptions without explicit user approval.

### 1. Planning Gate

**Purpose**: Ensure user has reviewed and approved the implementation plan before work begins

**When**: Before any implementation starts
**Check**: User has explicitly approved the plan or set auto-approve flag
**Pass Criteria**:
- User responds with "yes", "approve", "y", "go ahead", or equivalent
- OR user previously set `auto_approve: true` flag
- OR task classified as "Quick Fix" (<20 LOC impact)

**Fail Criteria**:
- No explicit user approval
- User responds with "no", "wait", "modify", or requests changes

**Fail Action**:
1. Return to planning phase
2. Address user feedback
3. Present updated plan
4. Re-request approval

**Bypass**: Only if user explicitly says "skip approval" or "just do it"

**Example**:
```markdown
📋 **Plan: Add Dark Mode Toggle**

I'll use 3 agents across 2 phases:
1. frontend-developer → Theme provider + toggle
2. backend-architect → User preference API
3. evidence-collector → Visual testing

Approve? (y/auto/modify)

→ Waiting for user response (Planning Gate)
```

---

### 2. Build Gate

**Purpose**: Ensure code compiles and has no syntax errors before proceeding

**When**: After any code changes
**Check**: Code compiles successfully with zero compilation errors
**Pass Criteria**:
- TypeScript: `tsc --noEmit` exits with code 0
- JavaScript: No syntax errors
- Python: No syntax errors, imports resolve
- Other languages: Compiler/interpreter returns success

**Fail Criteria**:
- Compilation errors
- Syntax errors
- Import/module resolution failures
- Build script fails

**Fail Action**:
1. Capture full error output
2. Retry with error context (attempt 1/3)
3. If still failing, retry with adjusted approach (attempt 2/3)
4. If still failing, try different strategy (attempt 3/3)
5. If 3 attempts fail, escalate to user with options

**Retry Strategy**:
```
Attempt 1: Fix syntax/import errors directly
Attempt 2: Check dependencies, resolve conflicts
Attempt 3: Simplify implementation, remove complex patterns
Escalate: Present error to user with recommendations
```

**Bypass**: Never (compilation must succeed)

**Example**:
```markdown
Phase 4: Implementation
  Task 1 → Build Gate → ✅ PASS (TypeScript compiled)
  Task 2 → Build Gate → ❌ FAIL (Type error in Button.tsx:15)
    Retry 1/3: Fixing type annotation...
  Task 2 → Build Gate → ✅ PASS
```

---

### 3. Test Gate

**Purpose**: Validate functionality works as expected before delivery

**When**: After implementation completes
**Check**: Tests pass or documented acceptable failures exist
**Pass Criteria**:
- ≥90% of tests passing
- OR all critical tests passing + documented rationale for failures
- OR no tests exist for prototypes (document this)

**Fail Criteria**:
- <90% tests passing without documentation
- Critical test failures
- New code breaks existing tests

**Fail Action**:
1. Analyze test failures
2. Retry with test failure context (attempt 1/3)
3. If still failing, adjust implementation (attempt 2/3)
4. If still failing, re-evaluate approach (attempt 3/3)
5. If 3 attempts fail, escalate with test report

**Retry Strategy**:
```
Attempt 1: Fix obvious bugs causing test failures
Attempt 2: Adjust edge case handling
Attempt 3: Simplify logic, add guards
Escalate: Present failing tests with analysis
```

**Bypass**: Only for:
- Prototypes (document: "Prototype - tests deferred")
- Exploratory work (document: "Experimental - validation manual")
- When user explicitly approves proceeding with failures

**Example**:
```markdown
Phase 5: Testing (Test Gate)
  reality-checker → 8/10 tests PASS (80%) ⚠️
    Failing: edge case with null values
  Retry 1/3: Adding null checks...
  reality-checker → 10/10 tests PASS (100%) ✅
```

---

### 4. Review Gate

**Purpose**: Ensure code quality, security, and best practices before delivery

**When**: Before PR creation or final delivery
**Check**: Code review by specialist agent completes successfully
**Pass Criteria**:
- No critical security vulnerabilities
- No critical performance issues
- Code follows project conventions
- Documentation adequate for changes

**Fail Criteria**:
- Critical security issues (SQL injection, XSS, etc.)
- Critical performance problems (N+1 queries, memory leaks)
- Major architectural violations

**Fail Action**:
1. Document issues found
2. Prioritize by severity (critical/high/medium/low)
3. Fix critical and high-severity issues
4. Re-run review
5. Escalate if unable to resolve

**Retry Strategy**:
```
Attempt 1: Fix all critical issues
Attempt 2: Address high-severity issues
Attempt 3: Document remaining issues with risk assessment
Escalate: Present trade-offs to user
```

**Bypass**: Only with explicit user acknowledgment of risks

**Example**:
```markdown
Phase 6: Review (Review Gate)
  reality-checker →
    ❌ Critical: SQL injection in search endpoint
    ⚠️ High: Missing input validation
    ℹ️ Medium: Could use better variable names

  Fixing critical and high issues...
  reality-checker → ✅ PASS (all critical/high resolved)
```

---

## Optional Gates

Context-dependent gates that can be skipped based on project requirements.

### 5. Type Checking Gate

**Purpose**: Ensure type safety in statically-typed languages

**When**: TypeScript, Python (with type hints), or other typed projects
**Check**: Type checker reports zero errors
**Pass Criteria**:
- TypeScript: `tsc --noEmit` with zero errors
- Python: `mypy` or `pyright` with zero errors

**Fail Criteria**: Any type errors

**Can Skip When**:
- Pure JavaScript project (no TypeScript)
- Prototype/MVP work
- Gradual typing migration in progress
- User explicitly approves skipping

**Example**:
```yaml
project_type: prototype
optional_gates:
  type_checking: false  # Skipped for prototypes
```

---

### 6. Linting Gate

**Purpose**: Enforce code style and catch common mistakes

**When**: Any project with linting configuration
**Check**: Linter reports zero errors (warnings OK)
**Pass Criteria**:
- ESLint, Pylint, RuboCop, etc. exit with zero errors
- Warnings are acceptable

**Fail Criteria**: Linting errors (not warnings)

**Can Skip When**:
- No linting configuration exists
- User prefers to fix linting later
- Warnings-only output

**Example**:
```markdown
Linting Gate:
  ✅ 0 errors
  ⚠️ 3 warnings (unused imports)
  → PASS (warnings acceptable)
```

---

### 7. Performance Benchmarks Gate

**Purpose**: Validate performance meets SLA targets

**When**: Performance-critical features, API endpoints, database queries
**Check**: Performance metrics meet defined targets
**Pass Criteria**:
- API response time < target (e.g., 200ms p95)
- Database query time < target (e.g., 50ms)
- Page load time < target (e.g., 2s)
- Memory usage < target

**Fail Criteria**: Performance significantly below targets (>2x)

**Can Skip When**:
- Non-critical features
- Performance not a requirement
- Optimization deferred to later phase

**Example**:
```markdown
Performance Gate:
  API response (p95): 180ms (target: 200ms) ✅
  Database query: 45ms (target: 50ms) ✅
  → PASS
```

---

### 8. Accessibility Audit Gate

**Purpose**: Ensure UI meets accessibility standards

**When**: UI features, public-facing interfaces
**Check**: WCAG 2.1 AA compliance
**Pass Criteria**:
- No critical accessibility violations
- All interactive elements keyboard accessible
- Proper ARIA labels
- Color contrast meets standards

**Fail Criteria**: Critical accessibility violations

**Can Skip When**:
- Internal tools (document decision)
- Accessibility deferred to later phase
- Non-UI features

**Example**:
```markdown
Accessibility Gate:
  ✅ Keyboard navigation works
  ✅ ARIA labels present
  ✅ Color contrast ratios pass
  ❌ One form missing label
  Fixing label... → ✅ PASS
```

---

## Retry & Escalation Protocol

### Retry Strategy

All gates follow this standard retry pattern:

```
Gate Check → Result

If PASS:
  ✅ Proceed to next phase

If FAIL:
  📋 Attempt 1/3: Fix obvious issues
    → Retry gate

  If still FAIL:
    📋 Attempt 2/3: Adjust approach
      → Retry gate

  If still FAIL:
    📋 Attempt 3/3: Alternative strategy or specialist
      → Retry gate

  If still FAIL:
    ⚠️ Escalate to user
```

### Escalation Options

When a gate fails after 3 attempts, present these options to the user:

1. **Skip Gate (with risk documentation)**
   ```markdown
   ⚠️ **Risk**: Proceeding with test failures may cause runtime errors
   **Recommendation**: Fix tests before deployment
   **User Decision**: Proceed anyway? (document risk)
   ```

2. **Modify Requirements**
   ```markdown
   💡 **Alternative**: Simplify feature to make tests pass
   **Trade-off**: Reduced functionality but working implementation
   **User Decision**: Accept simplified version?
   ```

3. **Abort Workflow**
   ```markdown
   🛑 **Stop**: Pause implementation, preserve partial work
   **Next Steps**: User can review, provide guidance, restart later
   ```

4. **Debug with Specialist**
   ```markdown
   🔍 **Deep Dive**: Spawn specialist agent to investigate
   **Agent**: senior-developer or domain expert
   **Goal**: Root cause analysis and fix strategy
   ```

### Escalation Example

```markdown
Build Gate: Failed after 3 attempts

**Error**: TypeScript compilation error in auth.service.ts
**Attempts**:
  1. Fixed import paths → Still failing
  2. Updated type definitions → Still failing
  3. Simplified implementation → Still failing

⚠️ **Escalating to User**

**Options**:
1. ⏭️ Skip type checking (⚠️ Risk: Runtime type errors)
2. 🔄 Switch to JavaScript (Trade-off: Lose type safety)
3. 🛑 Abort and investigate (Recommended)
4. 🔍 Call senior-developer for deep dive

Which would you prefer?
```

---

## Quality Metrics

### Target Metrics

Track these KPIs to measure quality gate effectiveness:

| Metric | Target | Measurement |
|--------|--------|-------------|
| **First-Attempt Pass Rate** | ≥85% | % of tasks passing gates on first try |
| **Average Retries per Task** | <2.0 | Mean retries across all tasks |
| **Escalation Rate** | <5% | % of tasks requiring user escalation |
| **Gate Bypass Rate** | <10% | % of gates skipped (excluding optional) |
| **Critical Issue Detection** | 100% | % of critical issues caught by gates |

### Measurement Example

```markdown
# Quality Gate Dashboard - Sprint 42

## Overall Performance
- **Tasks Completed**: 24
- **First-Attempt Pass Rate**: 87.5% (21/24) ✅
- **Average Retries**: 0.8 per task ✅
- **Escalations**: 1 (4.2%) ✅

## Gate Breakdown
- **Planning Gate**: 24/24 passed (100%)
- **Build Gate**: 22/24 first-attempt, 2 retries (91.7%)
- **Test Gate**: 20/24 first-attempt, 3 retries, 1 escalated (83.3%)
- **Review Gate**: 23/24 passed, 1 retry (95.8%)

## Optional Gates (when applicable)
- **Type Checking**: 18/20 applicable tasks passed (90%)
- **Linting**: 15/24 ran, 14 passed (93.3%)
- **Performance**: 3/3 performance-critical tasks passed (100%)
- **Accessibility**: 8/10 UI tasks passed (80%)

## Trends
- Build quality improving (91.7% vs 85% last sprint) ✅
- Test coverage needs attention (83.3% vs target 85%) ⚠️
- Review quality excellent (95.8%) ✅
```

---

## Gate Configuration

### Project-Level Configuration

Configure gates in `.claude/agency-settings.yaml`:

```yaml
quality_gates:
  # Mandatory gates (cannot disable)
  mandatory:
    planning: true
    build: true
    test: true
    review: true

  # Optional gates (can disable)
  optional:
    type_checking: true      # Enable for TypeScript projects
    linting: true            # Enable if .eslintrc exists
    performance: false       # Enable only for perf-critical features
    accessibility: true      # Enable for public-facing UI

  # Retry configuration
  retry:
    max_attempts: 3
    backoff: exponential     # linear, exponential, immediate

  # Escalation configuration
  escalation:
    auto_escalate_after: 3   # attempts
    notify_user: true
    provide_options: true
```

### Per-Task Overrides

Override gates for specific tasks:

```yaml
task:
  name: "Quick prototype"
  quality_gates:
    optional:
      type_checking: false   # Skip type checking for prototype
      linting: false         # Skip linting for speed
    mandatory:
      test: false            # ⚠️ Requires user approval to skip mandatory gate
```

---

## Gate Implementation Checklist

For orchestrator developers implementing quality gates:

### Build Gate Implementation
- [ ] Detect project type (TypeScript, JavaScript, Python, etc.)
- [ ] Run appropriate compiler/checker
- [ ] Capture full error output
- [ ] Parse errors for actionable feedback
- [ ] Implement retry logic with error context
- [ ] Track retry count
- [ ] Escalate after max retries

### Test Gate Implementation
- [ ] Detect test framework (Jest, Pytest, etc.)
- [ ] Run test suite
- [ ] Parse test results (pass/fail counts)
- [ ] Calculate pass rate
- [ ] Check for critical test failures
- [ ] Implement retry logic
- [ ] Generate test report
- [ ] Document acceptable failures if applicable

### Review Gate Implementation
- [ ] Spawn appropriate reviewer agent
- [ ] Run security checks (Snyk, npm audit, etc.)
- [ ] Check code quality (linting, complexity)
- [ ] Validate documentation
- [ ] Categorize issues by severity
- [ ] Generate review report
- [ ] Prioritize fixes

---

## Examples

### Example 1: Full Pipeline with All Gates

```markdown
# Feature Implementation: User Authentication

## Phase 1: Planning Gate
User requested: "Add login with Google OAuth"
Plan created: Auth flow, API endpoints, UI components
→ User approved ✅
**Planning Gate: PASS**

## Phase 2: Implementation

### Task 1: Backend OAuth Setup
Build Gate:
  - TypeScript compilation: ✅ PASS
  - Imports resolved: ✅ PASS
  **Build Gate: PASS**

Type Checking Gate (Optional):
  - 0 type errors: ✅ PASS
  **Type Checking Gate: PASS**

### Task 2: Frontend Login Component
Build Gate:
  - React JSX syntax: ✅ PASS
  **Build Gate: PASS**

Linting Gate (Optional):
  - ESLint: 0 errors, 2 warnings: ✅ PASS
  **Linting Gate: PASS**

## Phase 3: Testing

Test Gate:
  - Unit tests: 15/15 PASS ✅
  - Integration tests: 4/5 PASS ⚠️
    Failed: "OAuth callback timeout" (edge case)
  - Pass rate: 90.5% (19/21)
  **Test Gate: PASS** (>90% threshold)

## Phase 4: Review

Review Gate:
  - Security scan: ✅ No critical issues
  - Code quality: ✅ Good
  - Documentation: ✅ Complete
  **Review Gate: PASS**

Accessibility Gate (Optional - UI feature):
  - ARIA labels: ✅ Present
  - Keyboard nav: ✅ Works
  - Color contrast: ✅ Passes
  **Accessibility Gate: PASS**

## Result
✅ All mandatory gates passed
✅ All applicable optional gates passed
→ Ready for deployment
```

### Example 2: Gate Failure and Recovery

```markdown
# Feature Implementation: Product Search

## Phase 2: Implementation

Build Gate:
  - TypeScript compilation: ❌ FAIL
    Error: Type 'SearchResult' is not assignable to 'Product'

  Attempt 1/3: Adding type assertion...
  - TypeScript compilation: ❌ FAIL
    Error: Still incompatible types

  Attempt 2/3: Updating Product interface...
  - TypeScript compilation: ✅ PASS
  **Build Gate: PASS** (after 2 retries)

## Phase 3: Testing

Test Gate:
  - Search tests: 3/8 PASS ❌ (37.5%)
    Failed: 5 tests for edge cases

  Attempt 1/3: Fixing null handling...
  - Search tests: 5/8 PASS ⚠️ (62.5%)
    Failed: 3 tests for special characters

  Attempt 2/3: Escaping special characters...
  - Search tests: 7/8 PASS ⚠️ (87.5%)
    Failed: 1 test for Unicode

  Attempt 3/3: Adding Unicode support...
  - Search tests: 8/8 PASS ✅ (100%)
  **Test Gate: PASS** (after 3 retries)

## Phase 4: Review

Performance Gate (Optional - search is perf-critical):
  - Search latency (p95): 450ms ❌ (target: 200ms)

  ⚠️ **Escalating to User**

  Performance below target. Options:
  1. Add caching (quick fix, 80% improvement expected)
  2. Optimize database query (complex, 90% improvement)
  3. Skip gate and optimize later (⚠️ Risk: Slow search)

  User selected: Option 1 (Add caching)

  Implementing cache layer...
  - Search latency (p95): 180ms ✅ (target: 200ms)
  **Performance Gate: PASS**

## Result
✅ All gates passed (2 retries on build, 3 on test, 1 escalation resolved)
→ Ready for deployment
```

---

## Best Practices

### For Orchestrators

1. **Always Run Mandatory Gates**: Never skip planning, build, test, or review without user approval
2. **Provide Context in Retries**: Pass error details to agents so they can fix issues intelligently
3. **Track Metrics**: Log gate results for continuous improvement
4. **Clear Communication**: Explain gate failures clearly to users
5. **Escalate Early**: If 2 retries fail similarly, consider escalating before attempt 3

### For Agents

1. **Respect Gate Feedback**: Use error messages to guide fixes
2. **Don't Bypass Gates**: Work within the quality framework
3. **Document Assumptions**: If skipping optional gates, explain why
4. **Learn from Failures**: Adjust approach based on gate feedback

### For Users

1. **Trust the Process**: Gates catch real issues before they become problems
2. **Provide Context**: If requesting gate bypass, explain constraints
3. **Review Metrics**: Use quality dashboards to identify improvement opportunities
4. **Customize Thoughtfully**: Only disable gates after understanding trade-offs

---

## Maintenance & Updates

### Version History

- **v1.0** (2024-12-11): Initial quality gates standard
  - 4 mandatory gates
  - 4 optional gates
  - Retry protocol with 3 attempts
  - Escalation options framework

### Future Enhancements

Potential additions for v2.0:
- **Dependency Audit Gate**: Check for vulnerable dependencies
- **Documentation Gate**: Ensure README and API docs updated
- **Migration Gate**: Validate database migrations before apply
- **Deployment Gate**: Pre-deployment smoke tests

### Feedback

To suggest improvements to this standard:
1. Create issue in agency plugin repository
2. Tag with `quality-gates` label
3. Provide specific use case and rationale

---

**Related Documentation**:
- [Agent Catalog](/docs/agent-catalog.md) - Agent capabilities and selection
- [Orchestration Playbook](/docs/orchestration-playbook.md) - Orchestration best practices

**Last Review**: 2024-12-11
**Next Review**: 2025-03-11 (Quarterly)
