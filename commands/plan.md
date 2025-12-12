---
description: Create a detailed implementation plan without executing (research → plan → review → present)
argument-hint: issue number, URL, or description
allowed-tools: Read, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion
---

# Create Implementation Plan: $ARGUMENTS

Create a comprehensive implementation plan for an issue or feature request without executing it.

## Your Mission

Create an implementation plan for: **$ARGUMENTS**

Follow the planning lifecycle: analyze → research → plan → review → present (NO IMPLEMENTATION).

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

---

## Phase 1: Requirements Analysis

<!-- Component: prompts/issue-management/github-issue-fetch.md -->
<!-- Component: prompts/issue-management/jira-issue-fetch.md -->
<!-- Component: prompts/issue-management/issue-metadata-extraction.md -->

### Determine Input Type and Fetch Issue

Analyze `$ARGUMENTS` to determine the source:

**GitHub Issue Detection**:
- Numeric only: `123`, `456`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- `next` keyword: Find next open issue assigned to current user

**Jira Issue Detection**:
- Jira key format: `PROJ-123`, `ABC-456`
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`
- `next` keyword: Find next open issue in active sprint

**Text Description**:
- If no pattern matches, use the description as-is

### Fetch Issue (if applicable)

**For GitHub**:
```bash
gh issue view $ARGUMENTS --json number,title,body,state,labels,assignees,milestone,createdAt,updatedAt
```

**For Jira**:
```bash
acli jira --action getIssue \
  --issue "$ARGUMENTS" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,issuetype,assignee,reporter,labels,created,updated"
```

### Extract Metadata

From the fetched issue, extract:
- **Issue ID**: Issue number or key
- **Title/Summary**: Main description
- **Description**: Full details
- **Labels/Type**: Bug, feature, enhancement
- **Priority**: High, medium, low
- **Acceptance Criteria**: Expected outcomes
- **Technical Requirements**: Implementation details

### Handle Missing Information

<!-- Component: prompts/error-handling/ask-user-retry.md -->

If issue lacks detail or requirements are unclear:
```
Use AskUserQuestion tool:

"**Issue Analysis**

The issue/description needs clarification:
- [List missing or unclear elements]

**Options**:
A) Provide missing details now
B) Proceed with available information and refine later
C) Update the issue/description first

Please select an option (A/B/C) or provide the missing information:"
```

---

## Phase 2: Research & Context Gathering

### Use Explore Agent for Research

Spawn an Explore agent to gather context (keeps main context lean):

```
Task: Research codebase for [feature/area]

Agent: Explore

Instructions:
Find relevant code related to this implementation:
1. Existing similar features or patterns
2. Related components, services, or modules
3. Database schemas or API endpoints involved
4. Testing patterns used in this area
5. Dependencies and integrations

Provide a summary with:
- Key files and their purposes
- Existing patterns to follow
- Potential integration points
- Any concerns or risks discovered
```

### Research Outcomes

The Explore agent should provide:
- **Existing Patterns**: How similar features are implemented
- **Integration Points**: Where new code will connect
- **Dependencies**: Libraries or services needed
- **Conventions**: Coding style, testing approach, file organization
- **Risks**: Potential issues or conflicts

---

## Phase 3: Create Implementation Plan

### Structure Your Plan

Create a comprehensive plan following this structure:

1. **Overview** - Summary, scope (in/out), objectives
2. **Technical Approach** - Architecture, components, data flow, tech stack
3. **File Changes** - New files, modified files, estimated LOC
4. **Implementation Phases** - Phase-by-phase breakdown with time estimates
5. **Testing Strategy** - Unit (70%), integration (20%), E2E (10%), coverage target 80%+
6. **Risks & Mitigation** - Identified risks with impact/probability/mitigation
7. **Success Criteria** - Testable criteria for completion verification
8. **Alternative Approaches** - Considered alternatives with pros/cons

**Reference**: See `prompts/reporting/summary-template.md` for detailed plan template format.

---

## Phase 4: Plan Review

<!-- Component: prompts/specialist-selection/multi-specialist-routing.md -->
<!-- Component: prompts/planning/plan-validation.md -->

### Validate Plan Before Review

**Validation Checklist**:

- [ ] **Clear objective statement** - Specific and actionable
- [ ] **At least 3 implementation steps** - Ordered and actionable
- [ ] **List of files to modify/create** - Specific file paths
- [ ] **Success criteria defined** - Testable criteria
- [ ] **No placeholder text** - No [TODO], [TBD], etc.
- [ ] **Dependencies identified** - External libraries, APIs, services
- [ ] **Scope is reasonable** - Can be completed in one session

**If validation fails**:
```
Use AskUserQuestion tool:

"**Plan Validation Failed**

The plan is missing:
- [LIST MISSING COMPONENTS]

Cannot proceed without a complete plan.

Options:
1. Add missing information now
2. Return to planning phase
3. Provide guidance on what's needed"
```

### Select Reviewer Specialist

Based on detected keywords and plan type:

| Plan Type | Reviewer Agent |
|-----------|----------------|
| **Backend/API** | Backend Architect |
| **Frontend/UI** | Frontend Developer or ArchitectUX |
| **Full Stack** | Senior Developer |
| **Mobile** | Mobile App Builder |
| **AI/ML** | AI Engineer |
| **DevOps** | DevOps Automator |
| **Performance-Critical** | Performance Benchmarker |

### Spawn Reviewer Agent

```
Task: Review implementation plan

Agent: [selected specialist]

Context:
- Requirement: [what's being built]
- Proposed plan: [your complete plan]

Instructions:
Review this implementation plan for:
1. **Completeness**: Are all aspects covered?
2. **Feasibility**: Is the approach sound?
3. **Architecture**: Is the design appropriate?
4. **Risks**: Are there additional concerns?
5. **Estimates**: Are time estimates realistic?
6. **Best Practices**: Does it follow conventions?

Provide feedback:
- What's good about this plan?
- What's missing or needs improvement?
- Any alternative approaches to consider?
- Any risks or concerns?

Use the `code-review-standards` and relevant technology skills.
```

### Incorporate Feedback

1. Review the specialist's feedback
2. Update the plan based on suggestions
3. Address any concerns raised
4. Refine estimates if needed

---

## Phase 5: Present Plan to User

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/next-steps-template.md -->

### Create Summary

Present the plan using the standardized template (see `prompts/reporting/summary-template.md`):

**Key sections to include**:
- Header with date, issue ID, reviewer, status
- Summary (2-3 sentences)
- Scope (in/out)
- Technical approach with tech stack
- File changes (new/modified files with descriptions)
- Implementation phases with time estimates
- Testing strategy (unit/integration/E2E split)
- Risks and mitigation
- Success criteria
- Next steps (see `prompts/reporting/next-steps-template.md`)

**Next steps section should include**:
- Review plan instructions
- Approval/modification options
- Implementation command: `/agency:implement .agency/plans/plan-[feature].md`
- Alternative paths (modify requirements, re-plan, iterate)

### Save Plan to File

Create a plan file for future reference:

```bash
mkdir -p .agency/plans
PLAN_FILE=".agency/plans/plan-$(echo $ARGUMENTS | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$(date +%Y%m%d).md"
# Write plan content to file
```

### Get User Feedback

Ask the user what they'd like to do next with the plan.

---

## Output Deliverables

At the end of this command, provide:

1. **Complete Implementation Plan** (markdown document)
2. **Specialist Review** (feedback summary)
3. **Plan File** (saved to `.agency/plans/`)
4. **Next Steps** (how to proceed)

---

## Error Handling

<!-- Component: prompts/error-handling/ask-user-retry.md -->

### If Requirements Are Too Vague

```
Use AskUserQuestion tool:

"**Requirements Need Clarification**

The current requirements are too vague to create a detailed plan.

**Missing Information**:
- [What specific functionality is needed?]
- [What are the acceptance criteria?]
- [Technical preferences or constraints?]
- [Priority/urgency?]

**Options**:
A) Provide the missing information now
B) Proceed with assumptions (I'll document them)
C) Update the issue/description first

Please select an option (A/B/C) or provide clarification:"
```

### If Specialist Reviewer Raises Concerns

**Critical concerns**:
- Re-plan with new approach
- Document why original approach was rejected
- Get user approval for new direction

**Minor concerns**:
- Note them as risks/considerations in plan
- Include mitigation strategies
- Proceed with implementation

**Always incorporate feedback** before final presentation.

### If Research Reveals Blockers

**Hard blockers** (cannot proceed):
```
Use AskUserQuestion tool:

"**Implementation Blocker Detected**

Cannot proceed with current approach due to:
- [Blocker description]

**Impact**: [What this prevents]

**Options**:
A) Adjust scope to work around blocker
B) Explore alternative approach
C) Resolve blocker first, then plan
D) Abort planning

Please select an option (A/B/C/D):"
```

**Soft blockers** (can work around):
- Document clearly in risks section
- Propose mitigation strategies
- May need to adjust scope or approach
- Inform user of constraints and workarounds

---

## Important Notes

- **This is planning only** - no code will be written
- **Be thorough** - a good plan saves time in implementation
- **Get specialist review** - leverage expertise early
- **Save the plan** - it can be used for `/agency:implement`
- **Present clearly** - user should understand the approach
- **Think through risks** - identify issues before implementation

---

## Skills to Reference

Activate and reference these skills as needed:
- `agency-workflow-patterns` - Planning patterns (REQUIRED)
- `github-workflow-best-practices` - Development workflows
- `code-review-standards` - Quality considerations
- `testing-strategy` - Test planning

---

## Related Commands

- `/agency:work` - Plan + Implement + PR (full workflow)
- `/agency:implement` - Implement from existing plan
- `/agency:review` - Review existing code

---

**Remember**: You are creating a roadmap, not building the feature. Be thorough, thoughtful, and leverage specialists for domain expertise. A great plan makes implementation smooth.
