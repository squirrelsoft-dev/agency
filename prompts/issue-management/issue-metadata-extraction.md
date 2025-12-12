# Issue Management: Metadata Extraction

Extract structured metadata from GitHub or Jira issue output.

## When to Use

**After fetching issue** with:
- `github-issue-fetch.md` - GitHub issue JSON output
- `jira-issue-fetch.md` - Jira issue CSV output

**Purpose**: Parse raw issue data into structured components for planning.

---

## Core Metadata Fields

Extract these fields from every issue:

### 1. Issue Identifier

**GitHub**:
```bash
# From JSON output
ISSUE_NUMBER=$(echo "$ISSUE_DATA" | jq -r '.number')
ISSUE_ID="issue-$ISSUE_NUMBER"
```

**Jira**:
```bash
# From CSV output (first column)
ISSUE_KEY=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f1)
ISSUE_ID="$ISSUE_KEY"
```

### 2. Title/Summary

**GitHub**:
```bash
TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
```

**Jira**:
```bash
TITLE=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f2 | sed 's/^"//;s/"$//')
```

### 3. Description/Body

**GitHub**:
```bash
DESCRIPTION=$(echo "$ISSUE_DATA" | jq -r '.body // ""')
```

**Jira**:
```bash
DESCRIPTION=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f3 | sed 's/^"//;s/"$//')
```

### 4. Labels/Tags

**GitHub**:
```bash
# Extract label names as array
LABELS=$(echo "$ISSUE_DATA" | jq -r '.labels[].name' | tr '\n' ',' | sed 's/,$//')

# Example: "feature,high-priority,backend"
```

**Jira**:
```bash
# Labels are comma-separated in CSV
LABELS=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f8)

# Example: "backend,security,api"
```

### 5. Priority

**GitHub**:
```bash
# GitHub doesn't have native priority - infer from labels
if echo "$LABELS" | grep -q "critical\|urgent\|high-priority"; then
  PRIORITY="High"
elif echo "$LABELS" | grep -q "low-priority"; then
  PRIORITY="Low"
else
  PRIORITY="Medium"
fi
```

**Jira**:
```bash
# Jira has explicit priority field
PRIORITY=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f5)

# Values: Highest, High, Medium, Low, Lowest
```

### 6. Issue Type

**GitHub**:
```bash
# Infer from labels
if echo "$LABELS" | grep -q "bug"; then
  ISSUE_TYPE="Bug"
elif echo "$LABELS" | grep -q "feature"; then
  ISSUE_TYPE="Feature"
elif echo "$LABELS" | grep -q "enhancement"; then
  ISSUE_TYPE="Enhancement"
else
  ISSUE_TYPE="Task"
fi
```

**Jira**:
```bash
# Jira has explicit issue type
ISSUE_TYPE=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f6)

# Values: Story, Bug, Task, Epic, Sub-task, etc.
```

---

## Parsing Description Sections

Many issues use structured descriptions with sections:

### Extract Acceptance Criteria

**Common patterns**:
- `## Acceptance Criteria`
- `## AC`
- `## Success Criteria`
- `## Definition of Done`

```bash
# Extract acceptance criteria section
ACCEPTANCE_CRITERIA=$(echo "$DESCRIPTION" | sed -n '/## Acceptance Criteria/,/^##/p' | grep -v '^##')

# Parse checklist items
echo "$ACCEPTANCE_CRITERIA" | grep -E '^\s*-\s*\[[ x]\]' | while read -r item; do
  # Each item is a success criterion
  CRITERION=$(echo "$item" | sed 's/^\s*-\s*\[[ x]\]\s*//')
  echo "Criterion: $CRITERION"
done
```

### Extract Technical Requirements

**Common patterns**:
- `## Technical Requirements`
- `## Implementation Details`
- `## Technical Details`

```bash
# Extract technical requirements section
TECH_REQUIREMENTS=$(echo "$DESCRIPTION" | sed -n '/## Technical Requirements/,/^##/p' | grep -v '^##')
```

### Extract Context/Background

**Common patterns**:
- `## Description`
- `## Background`
- `## Context`
- `## Problem`

```bash
# Extract description section
CONTEXT=$(echo "$DESCRIPTION" | sed -n '/## Description/,/^##/p' | grep -v '^##')
```

---

## Handle Missing Fields

### Missing Description

```bash
if [ -z "$DESCRIPTION" ] || [ "$DESCRIPTION" = "null" ]; then
  echo "Warning: Issue has no description"

  # Use AskUserQuestion tool:
  # "Issue $ISSUE_ID has no description. Would you like to:"
  # - Proceed and I'll ask clarifying questions
  # - Update the issue with a description first
  # - Provide requirements verbally now
fi
```

### Missing Labels

```bash
if [ -z "$LABELS" ]; then
  echo "Warning: Issue has no labels"

  # Suggest labeling for better specialist selection
  # Use inferred type from title analysis
fi
```

### Missing Priority

```bash
if [ -z "$PRIORITY" ]; then
  # Default to Medium
  PRIORITY="Medium"
  echo "No priority specified, defaulting to Medium"
fi
```

---

## Extract Assignee Information

**GitHub**:
```bash
ASSIGNEE=$(echo "$ISSUE_DATA" | jq -r '.assignees[0].login // "unassigned"')
```

**Jira**:
```bash
ASSIGNEE=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f7)
```

**Use case**: Notify assignee, track workload, route notifications

---

## Extract Milestone/Sprint

**GitHub**:
```bash
MILESTONE=$(echo "$ISSUE_DATA" | jq -r '.milestone.title // "none"')
MILESTONE_DUE=$(echo "$ISSUE_DATA" | jq -r '.milestone.dueOn // "none"')
```

**Jira**:
```bash
# Sprint info requires separate query
SPRINT=$(acli jira --action getIssue \
  --issue "$ISSUE_KEY" \
  --outputFormat 2 \
  --columns "sprint" | tail -n +2 | cut -d',' -f1)
```

---

## Extract Timestamps

**GitHub**:
```bash
CREATED_AT=$(echo "$ISSUE_DATA" | jq -r '.createdAt')
UPDATED_AT=$(echo "$ISSUE_DATA" | jq -r '.updatedAt')
```

**Jira**:
```bash
CREATED_AT=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f9)
UPDATED_AT=$(echo "$ISSUE_DATA" | tail -n +2 | cut -d',' -f10)
```

**Use case**: Track issue age, staleness, urgency

---

## Build Structured Metadata Object

After extraction, create a structured object for downstream use:

```bash
# Create metadata summary
cat > /tmp/issue-metadata.json <<EOF
{
  "id": "$ISSUE_ID",
  "title": "$TITLE",
  "description": "$DESCRIPTION",
  "type": "$ISSUE_TYPE",
  "priority": "$PRIORITY",
  "labels": ["$(echo $LABELS | sed 's/,/","/g')"],
  "assignee": "$ASSIGNEE",
  "milestone": "$MILESTONE",
  "created_at": "$CREATED_AT",
  "updated_at": "$UPDATED_AT",
  "acceptance_criteria": "$ACCEPTANCE_CRITERIA",
  "technical_requirements": "$TECH_REQUIREMENTS"
}
EOF
```

---

## Validation

After extraction, verify:

- [ ] Issue ID is valid and non-empty
- [ ] Title is present and descriptive
- [ ] Description is present (warn if missing)
- [ ] Priority is set (default to Medium if missing)
- [ ] Type is determined
- [ ] Labels are parsed correctly

If validation fails:
```
Use AskUserQuestion tool:

"Issue metadata incomplete:
- Missing: [list missing fields]

Would you like to:
- Proceed with available information
- Provide missing details now
- Update the issue first"
```

---

## Integration with Planning

Pass extracted metadata to plan creation:

```bash
# Use metadata to create plan
PLAN_FILE=".agency/plans/plan-${ISSUE_ID}.md"

cat > "$PLAN_FILE" <<EOF
# Implementation Plan: $TITLE

**Issue**: $ISSUE_ID
**Type**: $ISSUE_TYPE
**Priority**: $PRIORITY
**Labels**: $LABELS

## Objective

$CONTEXT

## Acceptance Criteria

$ACCEPTANCE_CRITERIA

## Technical Requirements

$TECH_REQUIREMENTS

[... rest of plan template ...]
EOF
```

---

## Notes

- Always handle null/empty values gracefully
- Description parsing is best-effort - formats vary widely
- Markdown formatting in descriptions may need cleanup
- Jira wiki markup may need conversion to markdown
- Custom section headers vary by team - adapt patterns as needed
- Consider caching metadata for reuse across workflow phases
