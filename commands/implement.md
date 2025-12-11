---
description: Execute implementation from an existing plan file
argument-hint: plan-file path
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion]
---

# Implement from Plan: $ARGUMENTS

Execute implementation from an existing plan file with specialist delegation and quality gates.

## Your Mission

Implement the plan from: **$ARGUMENTS**

Follow the implementation lifecycle: validate plan → select specialist → implement → verify → review → report.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

---

## Phase 1: Plan Validation & Parsing (3-5 min)

### Read Plan File

**Plan File Location**:
- If `$ARGUMENTS` is a full path: Read directly
- If `$ARGUMENTS` is just a filename: Look in `.agency/plans/`
- If `$ARGUMENTS` doesn't include `.md`: Add `.md` extension

```bash
# Example paths to check:
# 1. $ARGUMENTS (if full path)
# 2. .agency/plans/$ARGUMENTS (if filename)
# 3. .agency/plans/$ARGUMENTS.md (if no extension)
```

Use the Read tool to load the plan file contents.

### Extract Plan Components

Parse the plan file and extract:

**Required Components**:
- **Objective**: What are we building?
- **Requirements**: List of functional requirements
- **File Changes**: Which files will be created/modified
- **Implementation Steps**: Ordered sequence of tasks
- **Success Criteria**: How to verify completion
- **Dependencies**: External libraries, APIs, services

**Optional Components**:
- **Architecture Decisions**: Technical approach rationale
- **Testing Strategy**: How to validate the implementation
- **Rollback Plan**: How to undo if needed
- **Performance Targets**: Expected benchmarks

### Validate Plan Completeness

Check the plan has:
- [ ] Clear objective statement
- [ ] At least 3 implementation steps
- [ ] List of files to modify/create
- [ ] Success criteria defined
- [ ] No placeholder text ([TODO], [TBD], etc.)

If plan is incomplete, ask the user:
```
Use AskUserQuestion tool to clarify:
- Missing requirements
- Unclear implementation steps
- Undefined success criteria
```

**Do NOT proceed** if plan validation fails. Get user input first.

---

## Phase 2: Specialist Selection (2-3 min)

### Analyze Plan Keywords

Scan the plan for technology keywords to determine the best specialist:

**Frontend Specialist** (`frontend-developer`) if plan mentions:
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
- TypeScript, JavaScript, JSX, TSX
- Tailwind, CSS, styled-components
- shadcn, Radix UI, Headless UI
- Component, UI, UX, design system

**Backend Specialist** (`backend-architect`) if plan mentions:
- API, REST, GraphQL, tRPC
- Database, SQL, PostgreSQL, MySQL, MongoDB
- Prisma, Drizzle, TypeORM
- Authentication, authorization, JWT
- Microservices, serverless
- Node.js server, Express, Fastify

**Mobile Specialist** (`mobile-app-builder`) if plan mentions:
- React Native, Expo
- iOS, Android, mobile
- SwiftUI, Kotlin, Flutter
- Mobile app, native

**AI/ML Specialist** (`ai-engineer`) if plan mentions:
- Machine learning, ML, AI
- LLM, embeddings, vector database
- TensorFlow, PyTorch, scikit-learn
- Mastra, Pixeltable, AI SDK
- Model training, inference, RAG

**Senior Developer** (`senior-developer`) if plan mentions:
- Laravel, Livewire, FluxUI
- Advanced CSS, Three.js
- Complex integrations
- OR if no clear specialty matches

### Get User Approval

Present the selected specialist to the user:

```
Use AskUserQuestion tool:
"I've analyzed the plan and selected [SPECIALIST] based on these keywords: [KEYWORDS].

Proceed with [SPECIALIST] for implementation?"

Options:
- Yes, proceed with [SPECIALIST] (Recommended)
- No, use a different specialist
```

If user selects "Other", ask which specialist they prefer.

---

## Phase 3: Implementation Delegation (30-180 min)

### Prepare Specialist Context

Create a comprehensive task description for the specialist:

```markdown
**Task**: Implement the plan from $ARGUMENTS

**Plan Objective**: [Extracted from Phase 1]

**Requirements**:
[Bullet list from plan]

**Files to Create/Modify**:
[List from plan]

**Implementation Steps**:
[Ordered steps from plan]

**Success Criteria**:
[Criteria from plan]

**Important Notes**:
- Follow the plan exactly - do not add extra features
- Implement all requirements before proceeding to next step
- Run tests after each significant change
- Create meaningful git commits as you progress
- Ask for clarification if any requirement is unclear
```

### Spawn Implementation Specialist

Use the Task tool to spawn the selected specialist:

```bash
Task tool with:
- subagent_type: [selected-specialist]
- description: "Implement plan: [plan-filename]"
- prompt: [comprehensive context from above]
```

### Monitor Progress

The specialist will work autonomously. You can:
- Check TodoWrite updates for progress tracking
- The specialist may use AskUserQuestion for clarifications
- Respond to any interactive confirmations for destructive operations

**Destructive Operations** that require user confirmation:
- Database migrations that drop tables/columns
- Deletion of existing files
- Breaking changes to public APIs
- Changes to environment configuration

If specialist encounters blockers, they should:
1. Document the blocker in TodoWrite
2. Attempt workarounds if possible
3. Ask user for guidance if stuck

---

## Phase 4: Verification & Quality Gates (5-10 min)

### Run Build

Verify the code compiles/builds successfully:

```bash
# For Next.js/React projects
npm run build

# For TypeScript projects
npm run type-check

# For general Node.js
npm run build || npm run compile
```

**Quality Gate**: Build MUST pass. If build fails:
1. Read build errors
2. Fix critical issues
3. Re-run build
4. Do NOT proceed until build passes

### Run Type Check

Verify TypeScript types are correct:

```bash
# TypeScript projects
npm run type-check || npx tsc --noEmit

# Check for type errors
```

**Quality Gate**: Type check MUST pass. Type errors are blockers.

### Run Linter

Check code style and quality:

```bash
# ESLint
npm run lint

# Or
npx eslint .
```

**Quality Gate**: Linting errors MUST be fixed. Warnings are acceptable but should be minimized.

### Run Tests

Execute the test suite:

```bash
# Run all tests
npm test

# Or specific test commands
npm run test:unit
npm run test:integration
npm run test:e2e
```

**Quality Gate**: All tests MUST pass. If tests fail:
1. Analyze test failures
2. Fix code or update tests as appropriate
3. Re-run tests
4. Do NOT proceed until all tests pass

### Check Test Coverage

Verify sufficient test coverage:

```bash
# Generate coverage report
npm run test:coverage || npm test -- --coverage
```

**Quality Gate Target**: 80%+ coverage

If coverage is below 80%:
1. Note coverage gaps in report
2. Recommend adding tests (but don't block)
3. User can decide if coverage is acceptable

---

## Phase 5: Code Review (5-7 min)

### Spawn Testing Reality Checker

Use the Task tool to spawn the code review agent:

```bash
Task tool with:
- subagent_type: testing-reality-checker
- description: "Review implementation of [plan-filename]"
- prompt: "Review the implementation for:

  **Plan Compliance**:
  - All requirements from the plan implemented
  - No extra features added beyond plan scope
  - Success criteria met

  **Code Quality**:
  - No obvious bugs or logic errors
  - Follows project coding standards
  - Proper error handling
  - No hardcoded values that should be configurable

  **Security**:
  - No SQL injection vulnerabilities
  - No XSS vulnerabilities
  - No exposed secrets or credentials
  - Proper input validation

  **Performance**:
  - No obvious performance issues
  - Efficient algorithms and data structures
  - No unnecessary re-renders (React)
  - Proper database indexing (if applicable)

  Files to review: [list of modified files]

  Provide findings with severity levels:
  - CRITICAL: Must fix before merge
  - HIGH: Should fix before merge
  - MEDIUM: Consider fixing
  - LOW: Nice to have

  Focus on CRITICAL and HIGH severity issues only."
```

### Address Critical Issues

If the reality checker finds CRITICAL or HIGH severity issues:

1. Read the review findings
2. Fix each critical issue
3. Re-run verification (Phase 4) if code changes are significant
4. Document fixes in TodoWrite

**Do NOT skip critical fixes**. These are blockers to completion.

Medium and Low severity issues:
- Document them in the implementation summary
- User can decide whether to address them

---

## Phase 6: Completion & Reporting (2-3 min)

### Save Implementation Summary

Create a summary document in `.agency/implementations/`:

```bash
# Generate filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FEATURE_NAME=[extracted from plan filename]
SUMMARY_FILE=".agency/implementations/impl-${FEATURE_NAME}-${TIMESTAMP}.md"
```

Write summary using Write tool:

```markdown
# Implementation Summary: [Feature Name]

**Date**: [Current date]
**Plan**: $ARGUMENTS
**Specialist**: [Selected specialist]
**Duration**: [Approximate time taken]

## Objective

[Plan objective]

## Requirements Implemented

- [x] Requirement 1
- [x] Requirement 2
- [x] Requirement 3
...

## Files Changed

### Created
- file1.ts - [Brief description]
- file2.tsx - [Brief description]

### Modified
- file3.ts - [Brief description]
- file4.tsx - [Brief description]

### Deleted
- file5.ts - [Brief description]

## Verification Results

### Build: ✅ PASS / ❌ FAIL
[Build output summary if failed]

### Type Check: ✅ PASS / ❌ FAIL
[Type errors if failed]

### Linter: ✅ PASS / ⚠️ WARNINGS
[Warning count and summary]

### Tests: ✅ PASS / ❌ FAIL
- Total: X tests
- Passed: Y tests
- Failed: Z tests
[Test failure summary if failed]

### Coverage: [X]%
- Target: 80%
- Actual: [X]%
[Coverage gaps if below target]

## Code Review Findings

### Critical Issues: [X]
[List if any, or "None"]

### High Priority Issues: [X]
[List if any, or "None"]

### Medium/Low Issues: [X]
[Brief summary or "None"]

## Success Criteria Status

- [x] Criterion 1: Met
- [x] Criterion 2: Met
- [ ] Criterion 3: Partially met - [Explanation]

## Next Steps

[If all criteria met]:
- Ready for commit and PR creation
- Consider running `/agency:review` for additional review
- Run `/agency:test` if test coverage is below 80%

[If issues remain]:
- Address [X] critical issues
- Re-run verification
- Consider additional testing

## Notes

[Any important notes, gotchas, or decisions made during implementation]
```

### Report Results to User

Provide a concise summary:

```
## Implementation Complete: [Feature Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Specialist**: [Selected specialist]

**Verification**:
- Build: [PASS/FAIL]
- Type Check: [PASS/FAIL]
- Linter: [PASS/WARNINGS]
- Tests: [X/Y passed]
- Coverage: [X]%

**Code Review**:
- Critical Issues: [X]
- High Priority: [X]
- Medium/Low: [X]

**Files Changed**: [X] created, [Y] modified, [Z] deleted

**Summary Report**: $SUMMARY_FILE

**Next Steps**:
[Recommended actions based on results]
```

### Update TodoWrite

Mark all implementation tasks as completed in TodoWrite.

---

## Interactive Mode Guidelines

Throughout the implementation:

**ASK the user** when:
- Plan is incomplete or ambiguous
- Specialist selection is uncertain
- Destructive operations are about to be performed
- Critical issues are found that need direction
- Build/tests fail and root cause is unclear

**DO NOT ask** for:
- Confirmation of every file change
- Approval of every commit
- Permission to run standard verification steps
- Approval of obvious bug fixes

**Autonomous decisions** you can make:
- Running builds, tests, linters
- Creating standard file structures
- Following established patterns in codebase
- Fixing obvious typos or syntax errors
- Standard git operations (add, commit)

---

## Error Handling

### If Plan File Not Found

```
Error: Plan file not found at: [attempted paths]

Please provide:
1. Full path to plan file, OR
2. Plan filename (will look in .agency/plans/), OR
3. Create plan file first using /agency:plan
```

### If Build Fails

```
Error: Build failed with [X] errors

Top errors:
[List top 3-5 errors]

Attempting to fix critical issues...
[Try automatic fixes]

If unfixable, ask user for guidance.
```

### If Tests Fail

```
Error: [X] tests failed

Failed tests:
[List failed test names and errors]

Possible causes:
[Analyze and suggest]

Recommendation: [Fix suggestions]
```

### If Specialist Gets Stuck

```
Warning: Specialist encountered blocker: [BLOCKER]

Attempted workarounds:
[List attempts]

User guidance needed:
[Specific question]
```

---

## Success Indicators

Implementation is successful when:

- ✅ All plan requirements implemented
- ✅ Build passes
- ✅ Type check passes
- ✅ Linter passes (or warnings acceptable)
- ✅ All tests pass
- ✅ Coverage ≥ 80% (or user accepts lower)
- ✅ No critical code review issues
- ✅ Success criteria from plan met
- ✅ Implementation summary saved

**Partial Success** when:
- ⚠️ Most requirements implemented
- ⚠️ Some tests fail (non-critical features)
- ⚠️ Coverage 60-79%
- ⚠️ Only medium/low code review issues

**Failure** when:
- ❌ Build fails
- ❌ Type check fails
- ❌ Critical tests fail
- ❌ Critical code review issues
- ❌ Core requirements not implemented

---

## Best Practices

1. **Follow the Plan**: Implement exactly what's in the plan, no more, no less
2. **Quality Gates Matter**: Don't skip verification steps
3. **Communicate Proactively**: Update TodoWrite, ask when unclear
4. **Document Everything**: Save summaries, capture decisions
5. **Think About Users**: Consider edge cases, error states, accessibility
6. **Security First**: Never compromise on security issues
7. **Test Thoroughly**: Aim for 80%+ coverage, test edge cases
8. **Review Before Complete**: Always run code review before marking done

---

## Example Usage

```bash
# Implement from a plan file
/agency:implement feature-user-authentication

# With full path
/agency:implement .agency/plans/add-dark-mode-support.md

# After creating a plan
/agency:plan 123
/agency:implement plan-issue-123-20241210
```

---

## Tips

- **Start with a good plan**: Quality of implementation depends on plan clarity
- **Choose the right specialist**: Match specialist expertise to the technology stack
- **Don't skip quality gates**: Build, tests, linting catch issues early
- **Review before commit**: Code review finds issues humans miss
- **Document for posterity**: Future you will thank present you

---

## Related Commands

- `/agency:plan [issue]` - Create an implementation plan first
- `/agency:review [pr]` - Review code after implementation
- `/agency:test [component]` - Generate additional tests
- `/agency:work [issue]` - Full end-to-end workflow (plan + implement + review)
