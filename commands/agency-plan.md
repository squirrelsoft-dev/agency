---
description: Create a detailed implementation plan without executing (research → plan → review → present)
argument-hint: issue number, URL, or description
allowed-tools: [Read, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
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

### Determine Input Type

Analyze `$ARGUMENTS`:

**If Issue Number or URL**:
- Fetch issue details using `gh issue view` (GitHub) or `acli issue get` (Jira)
- Extract title, description, acceptance criteria

**If Text Description**:
- Use the description as-is
- May need to clarify scope with user

### Extract Requirements

Identify:
- **What**: What needs to be built?
- **Why**: What problem does this solve?
- **Who**: Who is the user/stakeholder?
- **Success Criteria**: How will we know it's done?
- **Constraints**: Technical limitations, deadlines, dependencies

### Clarify Ambiguities

If requirements are unclear, use AskUserQuestion to clarify:
- Specific functionality details
- Technical preferences (libraries, frameworks)
- Scope boundaries
- Performance requirements
- Security considerations

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

Create a comprehensive plan with these sections:

#### 1. Overview
```markdown
## Implementation Plan: [Feature Name]

### Summary
[2-3 sentence overview of what will be implemented]

### Scope
**In Scope**:
- [Item 1]
- [Item 2]

**Out of Scope**:
- [Item A]
- [Item B]
```

#### 2. Technical Approach

```markdown
### Architecture

[Describe the high-level architecture]

**Components**:
- **Component A**: [Purpose and responsibility]
- **Component B**: [Purpose and responsibility]

**Data Flow**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Technology Stack**:
- Framework: [e.g., Next.js 15, React 18]
- State Management: [e.g., Zustand, Context API]
- Styling: [e.g., Tailwind CSS]
- Database: [e.g., PostgreSQL via Supabase]
- Testing: [e.g., Jest, Playwright]
```

#### 3. Files to Create/Modify

```markdown
### File Changes

**New Files**:
- `app/features/[feature]/page.tsx` - Main feature page
- `components/[Feature]/[Component].tsx` - Feature components
- `lib/api/[feature].ts` - API layer
- `lib/db/schema/[feature].ts` - Database schema

**Modified Files**:
- `app/layout.tsx` - Add navigation link
- `lib/types.ts` - Add new types
- `middleware.ts` - Add authorization check

**Total Estimated Changes**: X files, ~Y LOC
```

#### 4. Implementation Steps

```markdown
### Phase-by-Phase Breakdown

**Phase 1: Foundation** (Estimated: 2-3 hours)
1. Create database schema and migrations
2. Set up API routes
3. Create base types and interfaces

**Phase 2: Core Logic** (Estimated: 3-4 hours)
1. Implement business logic
2. Add data validation
3. Create service layer

**Phase 3: UI Implementation** (Estimated: 4-5 hours)
1. Create component structure
2. Implement forms and interactions
3. Add loading and error states
4. Integrate with API

**Phase 4: Testing** (Estimated: 2-3 hours)
1. Unit tests for logic
2. Integration tests for API
3. E2E tests for critical flows
4. Manual QA

**Phase 5: Polish** (Estimated: 1-2 hours)
1. Error handling
2. Loading states
3. Responsive design
4. Accessibility review

**Total Estimated Time**: 12-17 hours
```

#### 5. Testing Strategy

```markdown
### Testing Plan

**Unit Tests** (70% of test effort):
- Business logic functions
- Utility functions
- Data transformations

**Integration Tests** (20% of test effort):
- API endpoints
- Database operations
- Authentication flows

**E2E Tests** (10% of test effort):
- Critical user journeys
- Happy path flows
- Error scenarios

**Test Coverage Target**: 80%+
```

#### 6. Risks & Mitigation

```markdown
### Risks

**Risk 1: [Description]**
- **Impact**: High/Medium/Low
- **Probability**: High/Medium/Low
- **Mitigation**: [How to address]

**Risk 2: [Description]**
- **Impact**: High/Medium/Low
- **Probability**: High/Medium/Low
- **Mitigation**: [How to address]
```

#### 7. Alternative Approaches

```markdown
### Alternatives Considered

**Alternative 1: [Approach]**
- **Pros**: [Benefits]
- **Cons**: [Drawbacks]
- **Why Not Chosen**: [Reason]

**Alternative 2: [Approach]**
- **Pros**: [Benefits]
- **Cons**: [Drawbacks]
- **Why Not Chosen**: [Reason]
```

---

## Phase 4: Plan Review

### Select Reviewer Specialist

Based on the plan type, select an appropriate reviewer:

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

### Create Summary

Present the plan to the user in a clear, actionable format:

```markdown
# Implementation Plan: [Feature Name]

## 📋 Summary
[Brief overview]

## 🎯 Scope
**What we'll build**:
- [Item 1]
- [Item 2]
- [Item 3]

**What we won't build** (out of scope):
- [Item A]
- [Item B]

## 🏗️ Technical Approach
[High-level architecture description]

**Stack**: [Technology choices]

## 📁 File Changes
- **New Files**: X files
- **Modified Files**: Y files
- **Estimated LOC**: ~Z lines

See detailed file list below.

## 📅 Estimated Timeline
- **Phase 1 - Foundation**: 2-3 hours
- **Phase 2 - Core Logic**: 3-4 hours
- **Phase 3 - UI**: 4-5 hours
- **Phase 4 - Testing**: 2-3 hours
- **Phase 5 - Polish**: 1-2 hours

**Total**: 12-17 hours

## ⚠️ Risks
1. [Risk 1 and mitigation]
2. [Risk 2 and mitigation]

## ✅ Next Steps
1. Review this plan
2. Provide feedback or approval
3. Run `/agency:implement` to execute
4. Or modify requirements and re-plan

---

## Detailed Implementation Plan

[Include the complete plan from Phase 3]

---

**Reviewed by**: [Specialist agent name]
**Plan Status**: Ready for approval
```

### Save Plan to File

Create a plan file for future reference:

```bash
mkdir -p .agency/plans
echo "[plan content]" > .agency/plans/plan-$ARGUMENTS-$(date +%Y%m%d).md
```

### Get User Feedback

Ask the user:
```
**This plan is complete and ready for review.**

Options:
- **Approve**: Ready to implement? Run `/agency:implement .agency/plans/plan-...md`
- **Modify**: Want changes? Let me know what to adjust
- **Questions**: Need clarification on any part?
- **Alternatives**: Want to explore a different approach?

What would you like to do?
```

---

## Output Deliverables

At the end of this command, provide:

1. **Complete Implementation Plan** (markdown document)
2. **Specialist Review** (feedback summary)
3. **Plan File** (saved to `.agency/plans/`)
4. **Next Steps** (how to proceed)

---

## Error Handling

### If Requirements Are Too Vague

Ask clarifying questions using AskUserQuestion:
- What specific functionality is needed?
- What are the acceptance criteria?
- Any technical preferences or constraints?
- What's the priority/urgency?

### If Specialist Reviewer Raises Concerns

- Address concerns in the plan
- If significant issues, re-plan with new approach
- If minor issues, note them as risks/considerations
- Always incorporate feedback before final presentation

### If Research Reveals Blockers

- Document blockers clearly in risks section
- Propose mitigation strategies
- May need to adjust scope or approach
- Inform user of constraints

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
