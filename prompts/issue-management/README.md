# Issue Management Components

Reusable components for fetching and parsing GitHub and Jira issues.

## Overview

These components provide a unified workflow for working with issues from both GitHub and Jira, handling:
- Issue fetching via CLI tools (gh for GitHub, acli for Jira)
- Metadata extraction (title, description, labels, priority)
- Dependency parsing (blockers, prerequisites, related work)
- Status checking (is issue ready to work on?)

## Components

### 1. github-issue-fetch.md (201 lines)

**Purpose**: Fetch GitHub issues using gh CLI

**Handles**:
- Issue numbers: `123`
- GitHub URLs: `https://github.com/owner/repo/issues/123`
- Next issue: `next` keyword

**Output**: JSON with issue details (number, title, body, labels, state, etc.)

**Example**:
```bash
gh issue view 123 --json number,title,body,labels,assignees
```

### 2. jira-issue-fetch.md (302 lines)

**Purpose**: Fetch Jira issues using acli

**Handles**:
- Issue keys: `PROJ-123`
- Jira URLs: `https://company.atlassian.net/browse/PROJ-123`
- Next issue: `next` keyword (from active sprint)

**Output**: CSV with issue details (key, summary, description, status, priority, etc.)

**Example**:
```bash
acli jira --action getIssue \
  --issue "PROJ-123" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,labels"
```

### 3. issue-metadata-extraction.md (361 lines)

**Purpose**: Extract structured metadata from issue output

**Extracts**:
- Issue identifier (number/key)
- Title/Summary
- Description/Body
- Labels/Tags
- Priority (explicit or inferred)
- Issue type (Bug, Feature, Task, etc.)
- Acceptance criteria
- Technical requirements
- Assignee, milestone, timestamps

**Handles**:
- GitHub JSON output
- Jira CSV output
- Missing fields gracefully
- Markdown sections parsing

### 4. dependency-parsing.md (376 lines)

**Purpose**: Parse dependency references from issue descriptions

**Detects**:
- Direct references: `depends on #123`, `blocked by PROJ-456`
- Full URLs to issues/PRs
- Inline mentions: `builds on #123`
- Checklist items: `- [ ] #123 - Complete authentication`

**Checks**:
- Dependency status (open vs closed/done)
- Blocking vs related dependencies
- Work readiness based on blockers

**Output**: List of dependencies with status, recommendation to proceed or wait

## Usage Workflow

### Typical Flow (for /agency:work command)

```markdown
## Phase 1: Fetch and Analyze Issue

### Step 1: Detect Issue Source
{{include:prompts/issue-management/github-issue-fetch.md}}
OR
{{include:prompts/issue-management/jira-issue-fetch.md}}

### Step 2: Extract Metadata
{{include:prompts/issue-management/issue-metadata-extraction.md}}

### Step 3: Parse Dependencies
{{include:prompts/issue-management/dependency-parsing.md}}

### Step 4: Check Readiness
- If blocking dependencies exist: Ask user to confirm proceeding
- If dependencies complete: Continue to planning
```

## Integration Points

**Used by commands**:
- `work.md` - Full issue-to-PR workflow
- `sprint.md` - Multi-issue sprint workflow
- `plan.md` - Convert issue to implementation plan

**Outputs to**:
- Plan generation - Issue metadata → plan structure
- TodoWrite - Issue details in progress tracking
- Branch naming - Issue number/key → branch name
- Commit messages - Issue references
- PR creation - Link to original issue

## Error Handling

All components handle:
- Issue not found
- No issues matching "next" criteria
- Permission errors
- Missing/incomplete issue descriptions
- Invalid issue references in dependencies

## Examples

### GitHub Example

```bash
# User input: 123
# Detects: GitHub issue number

# Fetch
gh issue view 123 --json number,title,body,labels

# Extract
ISSUE_ID="issue-123"
TITLE="Add user authentication"
DESCRIPTION="Implement login and registration..."
LABELS="feature,high-priority,backend"
PRIORITY="High"

# Parse dependencies
DEPENDENCIES="#122" # Found "depends on #122"
STATUS="⚠️ #122: OPEN (blocking)"

# Result: Warn user about blocker, ask to proceed or wait
```

### Jira Example

```bash
# User input: PROJ-456
# Detects: Jira issue key

# Fetch
acli jira --action getIssue --issue "PROJ-456" --outputFormat 2

# Extract
ISSUE_ID="PROJ-456"
TITLE="Refactor payment processing"
DESCRIPTION="Move to new payment gateway..."
LABELS="backend,refactoring,api"
PRIORITY="Medium"

# Parse dependencies
DEPENDENCIES="PROJ-455,PROJ-451"
STATUS="✅ PROJ-455: Done, ✅ PROJ-451: Done"

# Result: All dependencies complete, ready to proceed
```

## Notes

- Components are platform-agnostic where possible
- Handle both explicit (keyword-based) and implicit references
- Gracefully degrade when information is missing
- Provide clear user prompts when clarification needed
- Support both interactive (ask user) and automated (defaults) modes
