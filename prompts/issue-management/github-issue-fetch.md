# Issue Management: GitHub Issue Fetch

Fetch GitHub issue details using gh CLI and extract structured information.

## When to Use

**Trigger conditions**:
- User provides GitHub issue number (e.g., `123`)
- User provides GitHub issue URL (e.g., `https://github.com/owner/repo/issues/123`)
- User provides `next` keyword to fetch next assigned issue

**Purpose**: Retrieve complete issue details for planning and implementation.

---

## Detection Logic

Identify GitHub issue source from `$ARGUMENTS`:

**GitHub Issue Patterns**:
- Numeric only: `123`, `456`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- Pull request URL: `https://github.com/owner/repo/pull/123`
- `next` keyword: Find next open issue assigned to current user

**Not GitHub** if:
- Jira key format: `PROJ-123`, `ABC-456`
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`

---

## Fetch Commands

### Fetch Specific Issue

```bash
# Numeric issue number
gh issue view $ARGUMENTS

# Full URL (gh CLI auto-handles URLs)
gh issue view $ARGUMENTS

# Get structured JSON output
gh issue view $ARGUMENTS --json number,title,body,state,labels,assignees,milestone,createdAt,updatedAt,closedAt,comments
```

### Fetch Next Issue

```bash
# Find next issue assigned to current user
gh issue list \
  --assignee @me \
  --state open \
  --limit 1 \
  --json number,title,body,labels,assignees,milestone

# Or find next unassigned issue with specific label
gh issue list \
  --state open \
  --label "needs-implementation" \
  --no-assignee \
  --limit 1 \
  --json number,title,body,labels,assignees,milestone
```

### Extract Issue Number

```bash
# From JSON output, extract issue number for reference
ISSUE_NUMBER=$(gh issue view $ARGUMENTS --json number --jq '.number')
echo "Working on issue #$ISSUE_NUMBER"
```

---

## Output Structure

The gh CLI returns JSON with these fields:

```json
{
  "number": 123,
  "title": "Add user authentication",
  "body": "## Description\n\nImplement user login and registration...\n\n## Acceptance Criteria\n\n- [ ] Users can register...",
  "state": "OPEN",
  "labels": [
    {"name": "feature"},
    {"name": "high-priority"}
  ],
  "assignees": [
    {"login": "username"}
  ],
  "milestone": {
    "title": "v1.0",
    "dueOn": "2024-12-31T00:00:00Z"
  },
  "createdAt": "2024-12-01T10:00:00Z",
  "updatedAt": "2024-12-10T15:30:00Z",
  "closedAt": null,
  "comments": [...]
}
```

---

## Error Handling

### Issue Not Found

```bash
# Check if issue exists before fetching
if ! gh issue view $ARGUMENTS &>/dev/null; then
  echo "Error: Issue #$ARGUMENTS not found"
  exit 1
fi
```

### No Issues Found (for "next")

```bash
# Check if any issues match criteria
ISSUE_COUNT=$(gh issue list --assignee @me --state open --json number --jq 'length')

if [ "$ISSUE_COUNT" -eq 0 ]; then
  echo "No open issues assigned to you"

  # Ask user what to do
  # Use AskUserQuestion tool:
  # "No issues found assigned to you. What would you like to do?"
  # - View all open issues
  # - View unassigned issues
  # - Specify issue number manually
fi
```

### Permission Errors

If gh CLI returns permission errors:
- Verify user is authenticated: `gh auth status`
- Verify user has access to repository
- Suggest running: `gh auth login`

---

## Integration with Other Components

After fetching, pass issue data to:

1. **issue-metadata-extraction.md** - Extract title, description, labels
2. **dependency-parsing.md** - Parse dependencies from issue body
3. Plan creation workflow - Convert issue to implementation plan

---

## Example Usage

```bash
# Fetch issue #123
gh issue view 123 --json number,title,body,labels,assignees

# Fetch from URL
gh issue view https://github.com/owner/repo/issues/123

# Find next issue
NEXT_ISSUE=$(gh issue list --assignee @me --state open --limit 1 --json number --jq '.[0].number')
if [ -n "$NEXT_ISSUE" ]; then
  gh issue view "$NEXT_ISSUE"
fi
```

---

## Validation

After fetching, verify:

- [ ] Issue number retrieved successfully
- [ ] Title and body are not empty
- [ ] Issue state is "OPEN" (warn if closed)
- [ ] JSON output is valid and parseable
- [ ] Issue body contains sufficient detail for planning

If issue lacks detail, prompt user:
```
Use AskUserQuestion tool:

"Issue #123 has minimal description. Would you like to:
- Proceed anyway and ask clarifying questions
- Update the issue with more details first
- Skip this issue and work on another"
```

---

## Notes

- gh CLI automatically uses repository context from current directory
- Can override repository with `--repo owner/repo` flag
- Use `--json` flag for structured output (easier to parse)
- Use `--jq` for filtering JSON output directly
- Comments can be fetched separately if needed: `gh issue view 123 --comments`
