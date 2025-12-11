---
description: Work on any issue end-to-end with intelligent orchestration (auto-detects GitHub/Jira)
argument-hint: issue number, URL, or 'next'
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Work on Issue: $ARGUMENTS

Implement a GitHub or Jira issue end-to-end using the Agency orchestrator and specialized agents.

## Your Mission

Work on issue: **$ARGUMENTS**

Follow the full development lifecycle: fetch → plan → review → implement → test → code review → commit → PR.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

---

## Phase 1: Issue Fetch & Analysis

### Detect Issue Source

Analyze `$ARGUMENTS` to determine the source:

**GitHub Issue** if:
- Numeric only: `123`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- `next` keyword (find next GitHub issue)

**Jira Issue** if:
- Jira key format: `PROJ-123`
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`

### Fetch Issue Details

**For GitHub**:
```bash
# Numeric issue
gh issue view $ARGUMENTS

# Find next issue (if $ARGUMENTS is "next")
gh issue list --assignee @me --state open --limit 1 --json number,title,body
```

**For Jira**:
```bash
# Assuming acli (Atlassian CLI) is installed
acli issue get $ARGUMENTS
```

### Extract Key Information

From the issue, identify:
- **Title**: What is being requested?
- **Description**: Detailed requirements
- **Acceptance Criteria**: How to verify success
- **Labels/Type**: Bug, feature, enhancement, etc.
- **Priority**: Urgency level
- **Dependencies**: Related issues or blockers

---

## Phase 2: Repository Setup

### Fetch Latest & Create Branch

```bash
# Fetch latest from remote
git fetch origin

# Checkout and update main branch
git checkout main
git pull origin main

# Create feature branch
# Format: feature/issue-NUMBER or feature/JIRA-KEY
git checkout -b feature/issue-$ARGUMENTS
```

**Branch Naming**:
- GitHub: `feature/issue-123` or `bugfix/issue-123`
- Jira: `feature/PROJ-123` or `bugfix/PROJ-123`

Use the `github-workflow-best-practices` skill for branching guidance if needed.

---

## Phase 3: Planning & Architecture

### Use TodoWrite for Tracking

Create a todo list with these phases:
```
1. Analyze issue requirements
2. Create implementation plan
3. Review plan with specialist
4. Implement solution
5. Run build and tests
6. Code review
7. Commit and create PR
```

### Create Implementation Plan

Analyze the issue and create a detailed plan covering:

**What to Build**:
- Files to create or modify
- Components/functions needed
- Data models or API endpoints
- UI changes (if applicable)

**Dependencies**:
- External libraries needed
- API integrations
- Database changes

**Implementation Steps**:
1. Step-by-step breakdown
2. Order of operations
3. Testing strategy

**Risks & Edge Cases**:
- Potential issues
- Edge cases to handle
- Performance considerations

### Select Reviewer Agent

Based on the issue type, select the appropriate specialist to review your plan:

| Issue Type | Reviewer Agent |
|------------|----------------|
| **Backend/API** | Backend Architect |
| **Frontend/UI** | Frontend Developer or ArchitectUX |
| **Mobile** | Mobile App Builder |
| **DevOps/Infrastructure** | DevOps Automator |
| **AI/ML** | AI Engineer |
| **Performance** | Performance Benchmarker |
| **General** | Plan agent or Senior Developer |

### Get Plan Reviewed

Use the Task tool to spawn the reviewer agent:

```
Task: Review implementation plan

Agent: [selected specialist]

Context:
- Issue: [issue details]
- Proposed plan: [your plan]

Instructions:
- Review the plan for completeness
- Identify potential issues or risks
- Suggest improvements or alternatives
- Confirm technical approach is sound

Please provide feedback on this implementation plan.
```

### Incorporate Feedback & Get User Approval

1. Update the plan based on reviewer feedback
2. Present the final plan to the user
3. Wait for explicit approval before proceeding

**Use AskUserQuestion** or clearly present:
```markdown
## Implementation Plan for Issue #$ARGUMENTS

### Summary
[Brief overview of what will be implemented]

### Files to Create/Modify
- `path/to/file1.ts` - [purpose]
- `path/to/file2.ts` - [purpose]

### Key Implementation Decisions
1. [Decision 1 and rationale]
2. [Decision 2 and rationale]

### Testing Strategy
[How we'll verify this works]

**Ready to proceed with implementation?**
```

**STOP HERE until user approves the plan.**

---

## Phase 4: Implementation (Delegated to Specialist)

### Select Implementation Agent

Based on the work type, select the best specialist:

| Work Type | Implementation Agent |
|-----------|---------------------|
| **React/UI** | Frontend Developer |
| **Node.js/Express API** | Backend Architect |
| **Python Backend** | Backend Architect |
| **Mobile (iOS/Android)** | Mobile App Builder |
| **AI/ML Features** | AI Engineer |
| **DevOps/CI/CD** | DevOps Automator |
| **Laravel/Livewire** | senior-developer |
| **Complex/Mixed** | Senior Developer |

### Spawn Implementation Agent

Use the Task tool to spawn the implementation agent:

```
Task: Implement issue #$ARGUMENTS

Agent: [selected specialist]

Context:
- Issue details: [from Phase 1]
- Approved implementation plan: [from Phase 3]
- Branch: feature/issue-$ARGUMENTS

Instructions:
1. Implement the solution according to the approved plan
2. Activate relevant skills for technology expertise:
   - `nextjs-16-expert` (for Next.js)
   - `typescript-5-expert` (for TypeScript)
   - `tailwindcss-4-expert` (for Tailwind CSS)
   - `supabase-latest-expert` (for Supabase)
   - `next-auth-beta-expert` (for NextAuth)
   - [other relevant skills]
3. Write clean, maintainable code following best practices
4. Handle edge cases and error scenarios
5. Add appropriate logging and error handling

**Do NOT commit changes** - I will handle verification and commit.

Please implement the solution now.
```

**Wait for the implementation agent to complete.**

---

## Phase 5: Verification & Quality Gates

### Build Verification

Run the build to ensure no compilation errors:

```bash
npm run build
# or
pnpm build
# or
yarn build
```

**If build fails**:
- Fix the errors
- Re-run build
- Repeat until successful

### Type Checking (if TypeScript)

```bash
npx tsc --noEmit
```

**Fix any type errors.**

### Linting

```bash
npm run lint
# or
pnpm lint
```

**Fix critical lint errors.** (Warnings are okay if minor)

### Run Tests

```bash
npm test
# or
pnpm test
# or specific test file
npm test -- <test-file>
```

**If tests fail**:
- Analyze failures
- Fix implementation or update tests
- Re-run until passing

### Code Review

Spawn a code review agent to review the changes:

```
Task: Code review for issue #$ARGUMENTS

Agent: Reality Checker or Senior Developer

Context:
- Issue: [issue details]
- Changes made: [summary]

Instructions:
Use the `code-review-standards` skill to review the changes for:
1. **Security**: No vulnerabilities (XSS, SQL injection, etc.)
2. **Code Quality**: Readable, maintainable, follows conventions
3. **Performance**: No obvious performance issues
4. **Testing**: Adequate test coverage
5. **Edge Cases**: Handles error scenarios properly

Please review the git diff and provide feedback.
```

**Address significant issues raised in review.**

---

## Phase 6: Completion & PR Creation

### Stage and Review Changes

```bash
# See what changed
git status

# Review the diff
git diff

# Stage changes
git add -A

# Review staged changes
git diff --cached
```

### Create Commit

Use conventional commit format:

```bash
git commit -m "$(cat <<'EOF'
<type>(scope): <description>

<body explaining what and why>

Closes #$ARGUMENTS
EOF
)"
```

**Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `docs`: Documentation
- `test`: Adding tests
- `chore`: Maintenance

**Example**:
```
feat(auth): add OAuth login support

Implemented OAuth authentication flow using GitHub provider.
Added login/logout buttons to navigation.
Configured session management with NextAuth.

Closes #123
```

Use the `github-workflow-best-practices` skill for commit message guidance.

### Push Branch

```bash
git push -u origin feature/issue-$ARGUMENTS
```

### Create Pull Request

**For GitHub**:
```bash
gh pr create --title "[Issue #$ARGUMENTS]: <brief description>" --body "$(cat <<'EOF'
## Summary
[Brief summary of changes]

## Changes Made
- [Change 1]
- [Change 2]
- [Change 3]

## Testing
- [How this was tested]
- [Test results]

## Screenshots (if UI changes)
[Add screenshots]

## Checklist
- [x] Build passes
- [x] Tests pass
- [x] Linting passes
- [x] Code reviewed

Closes #$ARGUMENTS
EOF
)"
```

**For Jira** (using GitHub with Jira integration):
```bash
gh pr create --title "[$ARGUMENTS]: <brief description>" --body "..."
```

The PR body should include:
- Summary of changes
- Link to issue (`Closes #$ARGUMENTS` for GitHub, `[PROJ-123]` for Jira)
- Test plan or verification steps
- Screenshots (if UI changes)
- Notes for reviewers

---

## Phase 7: Report Completion

Update the todo list to mark all tasks complete.

Report to the user:

```markdown
✅ **Issue #$ARGUMENTS Complete**

**Pull Request Created**: [PR URL]

**Summary**:
[Brief summary of what was implemented]

**Changes**:
- [File 1]: [Changes]
- [File 2]: [Changes]

**Verification**:
- ✅ Build passing
- ✅ Tests passing (X tests, Y coverage)
- ✅ Linting passing
- ✅ Code review complete

**Next Steps**:
- PR is ready for review
- Assigned reviewers will be notified
- Merge when approved

[Any caveats or follow-up items]
```

---

## Error Handling

### If Phase Fails

**Planning Failure**:
- Ask user for clarification
- Provide options to modify or abandon

**Implementation Failure**:
- Review error from implementation agent
- Either fix directly or re-delegate with adjusted instructions

**Verification Failure**:
- Fix issues and re-run verification
- Don't proceed to PR until all gates pass

**PR Creation Failure**:
- Check GitHub/Jira authentication
- Verify permissions
- Retry or provide manual instructions

### If Issue is Unclear

Use AskUserQuestion to clarify:
- What exactly should be implemented?
- What are the acceptance criteria?
- Are there specific technical requirements?
- Any constraints or preferences?

---

## Important Notes

- **Always wait for user approval** before starting implementation
- **The implementation agent does the coding**, not you (the orchestrator)
- **Activate relevant skills** to enhance agent knowledge
- **Keep the user informed** at each phase
- **Don't leave the repository in a broken state** - always ensure build/tests pass
- **Use TodoWrite** to track progress throughout

---

## Skills to Reference

Activate and reference these skills as needed:
- `agency-workflow-patterns` - Orchestration patterns (REQUIRED)
- `github-workflow-best-practices` - GitHub workflows, branching, PRs
- `code-review-standards` - Review criteria
- `testing-strategy` - Testing best practices

## Related Commands

- `/agency:plan` - Planning only (no implementation)
- `/agency:review` - Code review only
- `/agency:test` - Test generation only

---

**Remember**: You are the orchestrator. Coordinate the work, but delegate implementation to specialists. Keep context lean and focused on coordination.
