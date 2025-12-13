---
description: Triage issues with multi-specialist analysis and recommendations
argument-hint: issue number, epic/milestone, or empty for all un-triaged
allowed-tools: Read, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion
---

# Triage Issue(s): $ARGUMENTS

Get comprehensive triage analysis from multiple specialist agents who each provide domain-specific insights and recommendations as comments on the issue.

## Your Mission

Triage: **$ARGUMENTS**

Coordinate multi-specialist triage analysis where each relevant expert reviews the issue and adds their perspective as a comment.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

---

## Phase 0: Initialize Progress Tracking

Use TodoWrite tool to create todo list:

```javascript
[
  {
    "content": "Determine triage scope and fetch issues",
    "status": "in_progress",
    "activeForm": "Determining triage scope and fetching issues"
  },
  {
    "content": "Analyze issues and select specialists",
    "status": "pending",
    "activeForm": "Analyzing issues and selecting specialists"
  },
  {
    "content": "Spawn specialists for triage analysis",
    "status": "pending",
    "activeForm": "Spawning specialists for triage analysis"
  },
  {
    "content": "Aggregate triage results",
    "status": "pending",
    "activeForm": "Aggregating triage results"
  }
]
```

---

## Phase 1: Determine Triage Scope

### Step 1: Parse Arguments

Analyze `$ARGUMENTS` to determine triage scope:

**Single Issue** if:
- Numeric only: `123`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- Jira key format: `PROJ-123`
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`

**Epic/Milestone** if:
- GitHub milestone: `milestone:1`, `milestone:Sprint-23`
- GitHub label: `epic:user-auth`, `label:epic`
- Jira epic: `epic:PROJ-456`, `PROJ-456` (with Epic issue type)
- Jira sprint: `sprint:current`, `sprint:23`

**All Un-triaged Issues** if:
- Empty arguments or `all`

### Step 2: Confirm Scope (for "all" or empty)

If no arguments or "all" specified:

```
Use AskUserQuestion tool:
  Question: "No specific issue specified. What would you like to triage?"

  Options:
    - "All un-triaged issues in current sprint/milestone (Recommended)"
      Description: "Find all open issues in the active sprint/milestone that don't have triage comments yet."

    - "All open un-triaged issues"
      Description: "Triage all open issues across the entire project that haven't been triaged. May be a large number."

    - "Specify issue, epic, or milestone"
      Description: "Provide a specific issue number, epic, or milestone to triage."

    - "Cancel"
      Description: "Exit triage command."
```

### Step 3: Fetch Issues

**For Single Issue**:

GitHub:
```bash
gh issue view $ARGUMENTS --json number,title,body,state,labels,assignees,milestone,comments
```

Jira:
```bash
# Extract issue key if URL provided
ISSUE_KEY=$(echo "$ARGUMENTS" | grep -oP '[A-Z]+-\d+' || echo "$ARGUMENTS")

acli jira --action getIssue \
  --issue "$ISSUE_KEY" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,issuetype,assignee,labels,comments"
```

**For Epic/Milestone**:

GitHub (Milestone):
```bash
# If milestone name/ID provided
MILESTONE_ID=$(echo "$ARGUMENTS" | grep -oP 'milestone:(\d+|\S+)' | cut -d: -f2)

gh issue list \
  --milestone "$MILESTONE_ID" \
  --state open \
  --json number,title,body,labels,comments \
  --limit 100
```

GitHub (Epic Label):
```bash
# If epic label provided
EPIC_LABEL=$(echo "$ARGUMENTS" | grep -oP 'epic:\S+|label:\S+' | cut -d: -f2)

gh issue list \
  --label "$EPIC_LABEL" \
  --state open \
  --json number,title,body,labels,comments \
  --limit 100
```

Jira (Epic):
```bash
# Extract epic key
EPIC_KEY=$(echo "$ARGUMENTS" | grep -oP 'epic:[A-Z]+-\d+|[A-Z]+-\d+' | sed 's/epic://')

# Fetch all issues in epic
acli jira --action getIssueList \
  --jql "\"Epic Link\" = $EPIC_KEY AND status != Done" \
  --outputFormat 2 \
  --maxResults 100
```

Jira (Sprint):
```bash
# If sprint specified
SPRINT_ID=$(echo "$ARGUMENTS" | grep -oP 'sprint:\S+' | cut -d: -f2)

# Handle "current" keyword
if [[ "$SPRINT_ID" == "current" ]]; then
  acli jira --action getIssueList \
    --jql "sprint in openSprints() AND status != Done" \
    --outputFormat 2 \
    --maxResults 100
else
  acli jira --action getIssueList \
    --jql "sprint = $SPRINT_ID AND status != Done" \
    --outputFormat 2 \
    --maxResults 100
fi
```

**For All Un-triaged**:

Filter fetched issues to exclude those with triage comments. Look for comment markers like:
- `<!-- TRIAGE:` (GitHub)
- `**[Triage]**` (Jira)
- Comments from known specialist agents

---

## Phase 2: Analyze Issues & Select Specialists

For each issue to triage, use the orchestrator to determine which specialists are relevant.

### Step 1: Spawn Orchestrator for Specialist Selection

```
Task: Analyze issue and select triage specialists

Agent: agents-orchestrator

Context:
Issue: $ISSUE_NUMBER - $ISSUE_TITLE

Issue Details:
$ISSUE_BODY

Labels: $ISSUE_LABELS
Type: $ISSUE_TYPE (if Jira)
Priority: $ISSUE_PRIORITY

Instructions:
Analyze this issue and identify 2-4 specialist agents who should provide triage input.

Selection Guidelines:
- **Frontend-only changes**: ux-architect, ui-designer, frontend-developer
- **Backend-only changes**: backend-architect, senior-developer
- **Full-stack features**: senior-developer, ux-architect, ui-designer, frontend-developer
- **Mobile features**: mobile-app-builder, ux-architect, ui-designer
- **DevOps/Infrastructure**: devops-automator, backend-architect
- **AI/ML features**: ai-engineer, backend-architect
- **Performance issues**: performance-benchmarker, relevant domain specialist
- **Security issues**: backend-architect, devops-automator
- **Testing needs**: test-results-analyzer, relevant domain specialist

Based on the issue description, labels, and type, return ONLY:
1. A JSON array of 2-4 specialist agent names
2. Brief reasoning for each selection (one sentence)

Output Format:
{
  "specialists": ["agent-name-1", "agent-name-2", "agent-name-3"],
  "reasoning": {
    "agent-name-1": "Reason for selection",
    "agent-name-2": "Reason for selection",
    "agent-name-3": "Reason for selection"
  }
}

Do NOT implement anything. ONLY analyze and recommend specialists.
```

### Step 2: Parse Specialist Selection

Extract the list of specialist agents from the orchestrator's response.

Validate that:
- 2-4 specialists were selected
- Each specialist exists in the agency catalog
- No duplicate specialists

If validation fails, use a fallback:
- Default to: `["senior-developer", "ux-architect", "frontend-developer"]` for general issues

---

## Phase 3: Spawn Specialists for Triage

### Step 1: Spawn All Specialists in Parallel

For each selected specialist, spawn them to perform triage analysis:

```
Task: Triage analysis for issue #$ISSUE_NUMBER

Agent: $SPECIALIST_NAME

Context:
Issue: #$ISSUE_NUMBER - $ISSUE_TITLE
Provider: $PROVIDER (GitHub/Jira)

Issue Details:
$ISSUE_BODY

Labels/Type: $ISSUE_LABELS
Priority: $ISSUE_PRIORITY
Assignee: $ISSUE_ASSIGNEE

Instructions:
As a $SPECIALIST_NAME, provide triage analysis for this issue from your domain perspective.

**CRITICAL - Skill Loading**:
Before beginning analysis, activate ALL relevant skills:

1. Load agency skills for your domain:
   - Use the Skill tool for relevant agency-* skills
   - Example: nextjs-16-expert, typescript-5-expert, tailwindcss-4-expert, etc.

2. Load user skills from ~/.claude/skills:
   - Check ~/.claude/skills/ for additional expertise
   - Activate any skills relevant to this issue's technology stack
   - Examples: react-patterns, api-design, database-optimization, etc.

3. Verify skill loading:
   - Confirm which skills were successfully activated
   - Note any missing skills that would be helpful

**Your Triage Responsibilities**:

1. **Complexity Assessment**:
   - Estimate effort (Small/Medium/Large)
   - Identify technical challenges from your domain perspective
   - Note dependencies or prerequisites

2. **Technical Approach**:
   - Recommend implementation approach from your expertise
   - Identify patterns or best practices to apply
   - Suggest architectural considerations

3. **Risks & Concerns**:
   - Highlight potential issues from your domain
   - Note edge cases to consider
   - Identify testing requirements

4. **Resources & Skills Needed**:
   - What expertise is required?
   - What documentation should be reviewed?
   - Any third-party integrations needed?

5. **Acceptance Criteria Validation**:
   - Are the acceptance criteria clear and testable?
   - What's missing from your domain perspective?
   - Suggest additions if needed

**Output Format**:

Generate a triage comment in this format:

```markdown
## Triage: $SPECIALIST_ROLE

**Assessed By**: $SPECIALIST_NAME
**Date**: $(date +%Y-%m-%d)
**Skills Activated**: [list of skills loaded]

### Complexity Assessment
**Effort Estimate**: [Small/Medium/Large]
**Technical Challenges**:
- [Challenge 1 from domain perspective]
- [Challenge 2]

### Recommended Approach
[Describe recommended implementation approach from your expertise]

### Risks & Concerns
- [Risk 1 from domain perspective]
- [Risk 2]

### Required Resources
- **Expertise**: [Skills/knowledge needed]
- **Documentation**: [Docs to review]
- **Integrations**: [Third-party services/APIs]

### Acceptance Criteria Review
- ✅ [Criteria that are clear]
- ⚠️ [Criteria needing clarification]
- ➕ [Suggested additional criteria]

### Additional Notes
[Any other domain-specific insights]
```

**After generating the triage comment**:

Add this comment to the issue:

**For GitHub**:
```bash
gh issue comment $ISSUE_NUMBER --body "$(cat triage-comment.md)"
```

**For Jira**:
```bash
# Use jira-adf-generator skill to format for Jira
acli jira --action addComment \
  --issue "$ISSUE_KEY" \
  --comment "$(cat triage-comment-adf.json)"
```

**Important**:
- Use Read/Write/Bash tools to interact with the codebase if needed for analysis
- DO NOT implement anything - this is analysis only
- Focus on YOUR domain expertise
- Be specific and actionable in recommendations
```

### Step 2: Execute Parallel Triage

Spawn all specialists in parallel using Task tool with `run_in_background: true`:

```bash
# Example for 4 specialists
TASK_IDS=()

# Spawn specialist 1
Task: ux-architect triage → TASK_ID_1
TASK_IDS+=("$TASK_ID_1")

# Spawn specialist 2
Task: ui-designer triage → TASK_ID_2
TASK_IDS+=("$TASK_ID_2")

# Spawn specialist 3
Task: frontend-developer triage → TASK_ID_3
TASK_IDS+=("$TASK_ID_3")

# Spawn specialist 4
Task: senior-developer triage → TASK_ID_4
TASK_IDS+=("$TASK_ID_4")

# Wait for all to complete
for TASK_ID in "${TASK_IDS[@]}"; do
  TaskOutput: $TASK_ID (blocking)
done
```

### Step 3: Verify Comments Posted

After all specialists complete, verify triage comments were added:

**GitHub**:
```bash
gh issue view $ISSUE_NUMBER --comments | grep "## Triage:"
```

**Jira**:
```bash
acli jira --action getComments --issue "$ISSUE_KEY" | grep "Triage:"
```

Count successful triage comments vs. expected specialists.

---

## Phase 4: Aggregate Results

### Step 1: Summary Report

For each triaged issue, generate a summary:

```markdown
## Triage Summary: Issue #$ISSUE_NUMBER

**Issue**: $ISSUE_TITLE
**Provider**: $PROVIDER
**Triaged By**: [list of specialists who provided input]

### Consensus Findings

**Complexity**: [Small/Medium/Large - based on specialist consensus]

**Key Challenges**:
- [Common challenges identified across specialists]

**Recommended Approach**:
- [Synthesized approach from specialist inputs]

**Critical Risks**:
- [High-priority risks flagged by multiple specialists]

**Skills Required**:
- [Combined list of expertise needed]

### Specialist Breakdown

[For each specialist]
**$SPECIALIST_NAME**:
- Effort: [S/M/L]
- Key Concern: [Main point]
- Recommendation: [One-liner]

### Next Steps

1. Review detailed triage comments on the issue
2. Clarify any acceptance criteria gaps identified
3. Assign to appropriate team member with required skills
4. Consider complexity estimate when planning sprint

---
**Triage Completed**: $(date +%Y-%m-%d)
**Total Specialists**: $SPECIALIST_COUNT
**Triage Command**: `/agency:triage $ARGUMENTS`
```

Save summary to `.agency/triage/issue-$ISSUE_NUMBER-triage-$(date +%Y%m%d).md`

### Step 2: Multi-Issue Summary (if multiple issues triaged)

If triaging epic/milestone/all:

```markdown
## Bulk Triage Summary

**Scope**: $TRIAGE_SCOPE
**Date**: $(date +%Y-%m-%d)
**Issues Triaged**: $TOTAL_ISSUES

### Triage Results

| Issue | Title | Complexity | Specialists | Comments |
|-------|-------|------------|-------------|----------|
| #123  | ...   | Medium     | 3           | ✅       |
| #124  | ...   | Large      | 4           | ✅       |
| #125  | ...   | Small      | 2           | ✅       |

### Complexity Distribution
- **Small**: $SMALL_COUNT issues
- **Medium**: $MEDIUM_COUNT issues
- **Large**: $LARGE_COUNT issues

### Most Common Challenges
1. [Challenge 1] - mentioned in X issues
2. [Challenge 2] - mentioned in Y issues
3. [Challenge 3] - mentioned in Z issues

### Resource Requirements
**Most Needed Skills**:
- [Skill 1]: Required for X issues
- [Skill 2]: Required for Y issues

**Documentation Gaps**:
- [Gap 1]: Needed for X issues

### Recommendations
1. [Overall recommendation 1]
2. [Overall recommendation 2]

---
**Triage Session Complete**
**Duration**: $DURATION
**Success Rate**: $SUCCESS_RATE% (X/Y issues successfully triaged)
```

---

## Phase 5: Report Completion

Update TodoWrite to mark all tasks complete.

Present concise summary to user:

```markdown
## Triage Complete ✅

**Scope**: $TRIAGE_SCOPE
**Issues Triaged**: $TOTAL_ISSUES
**Specialists Engaged**: [unique list of specialists used]

### Results Summary

Successfully triaged $SUCCESS_COUNT/$TOTAL_ISSUES issues with multi-specialist analysis.

**Triage Comments Added**:
- ✅ $COMMENT_COUNT specialist comments posted
- Each issue received input from $AVG_SPECIALISTS specialists (avg)

**Complexity Breakdown**:
- Small: $SMALL_COUNT
- Medium: $MEDIUM_COUNT
- Large: $LARGE_COUNT

### View Triage Analysis

**Individual Reports**:
- `.agency/triage/issue-*-triage-*.md`

**Aggregate Summary** (if multiple):
- `.agency/triage/bulk-triage-$(date +%Y%m%d).md`

**Issue Comments**:
View detailed specialist analysis directly on each issue in $PROVIDER.

### Next Steps

1. Review specialist recommendations on issues
2. Clarify any flagged acceptance criteria gaps
3. Assign issues to team members with required skills
4. Factor complexity estimates into sprint planning
5. Address common challenges identified across issues

---

**Triage Command**: `/agency:triage $ARGUMENTS`
```

---

## Error Handling

### If Issue Not Found

```
Use AskUserQuestion tool:
  Question: "Issue $ARGUMENTS not found. What would you like to do?"

  Options:
    - "Try different issue number/key"
    - "Cancel triage"
```

### If No Issues Match Filter

For epic/milestone/all scenarios:

```markdown
**No Un-triaged Issues Found**

Checked: $SCOPE
Result: All issues in this scope have already been triaged or there are no open issues.

Options:
1. Triage a different scope
2. Re-triage existing issues (will add new specialist perspectives)
3. Cancel
```

### If Specialist Selection Fails

Fallback to default specialist set based on issue type:
- **General/Unknown**: senior-developer, ux-architect, frontend-developer
- **Bug**: senior-developer, test-results-analyzer
- **Feature**: senior-developer, ux-architect, ui-designer, frontend-developer

### If Comment Posting Fails

**Authentication Issue**:
```bash
# Check auth
gh auth status  # GitHub
# or check acli config  # Jira

# Provide re-auth instructions
```

**Permission Issue**:
```markdown
**Cannot Post Comments**

Issue: Insufficient permissions to comment on $PROVIDER issue.

Options:
1. Save triage analysis to local files only
2. Provide triage summary for manual posting
3. Check repository/project permissions
```

**Rate Limiting**:
```markdown
**API Rate Limit Reached**

Provider: $PROVIDER
Limit Reset: $RESET_TIME

Options:
1. Wait for rate limit reset ($MINUTES minutes)
2. Continue with remaining issues later
3. Save triage analysis locally for now
```

### If Parallel Specialist Spawn Fails

Retry failed specialist spawns sequentially:
```bash
# If parallel spawn failed
for SPECIALIST in "${FAILED_SPECIALISTS[@]}"; do
  # Retry spawn without background flag
  Task: $SPECIALIST triage (blocking)
done
```

---

## Important Notes

- **Triage is analysis, not implementation** - Specialists provide insights only
- **Multiple perspectives** - Each specialist brings domain expertise
- **Skills are critical** - Agents must load relevant skills for accurate assessment
- **Parallel execution** - All specialists review simultaneously for efficiency
- **Persistent record** - Comments remain on issue for future reference
- **Consensus building** - Multiple specialists help validate complexity and approach

---

## Skills to Reference

**Required**:
- `agency-workflow-patterns` - Orchestration patterns
- `jira-adf-generator` - For formatting Jira comments (if using Jira)

**Specialist-Specific** (loaded by each specialist):
- Technology skills (nextjs-16-expert, typescript-5-expert, etc.)
- User-provided skills from ~/.claude/skills
- Domain-specific patterns and best practices

---

## Related Commands

- `/agency:work [issue]` - Implement issue after triage
- `/agency:plan [issue]` - Create detailed plan after triage
- `/agency:sprint [sprint-id]` - Triage and implement all issues in sprint

---

**Remember**: Triage provides the critical first analysis that informs all downstream work. Multiple specialist perspectives ensure comprehensive understanding before implementation begins.
