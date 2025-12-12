# Issue Management: Jira Issue Fetch

Fetch Jira issue details using acli (Atlassian CLI) and extract structured information.

## When to Use

**Trigger conditions**:
- User provides Jira issue key (e.g., `PROJ-123`)
- User provides Jira URL (e.g., `https://company.atlassian.net/browse/PROJ-123`)
- User provides `next` keyword to fetch next assigned issue from sprint

**Purpose**: Retrieve complete issue details for planning and implementation.

---

## Detection Logic

Identify Jira issue source from `$ARGUMENTS`:

**Jira Issue Patterns**:
- Jira key format: `PROJ-123`, `ABC-456` (uppercase letters, hyphen, numbers)
- Jira URL: `https://company.atlassian.net/browse/PROJ-123`
- `next` keyword: Find next open issue in active sprint

**Not Jira** if:
- Numeric only: `123` (likely GitHub)
- GitHub URL pattern

---

## Fetch Commands

### Fetch Specific Issue

```bash
# Using Jira issue key
acli jira --action getIssue \
  --issue "$ARGUMENTS" \
  --outputFormat 2

# Get structured output with specific fields
acli jira --action getIssue \
  --issue "$ARGUMENTS" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,issuetype,assignee,reporter,labels,created,updated"
```

### Fetch from URL

```bash
# Extract issue key from URL
ISSUE_KEY=$(echo "$ARGUMENTS" | grep -oP '[A-Z]+-\d+')

if [ -n "$ISSUE_KEY" ]; then
  acli jira --action getIssue \
    --issue "$ISSUE_KEY" \
    --outputFormat 2
fi
```

### Fetch Next Issue

```bash
# Find next issue in active sprint assigned to current user
CURRENT_USER=$(acli jira --action getServerInfo --outputFormat 999 --field currentUser)

# Get next issue from active sprint
acli jira --action getIssueList \
  --jql "sprint in openSprints() AND assignee = currentUser() AND status != Done" \
  --maxResults 1 \
  --outputFormat 2 \
  --columns "key,summary,description,priority,status"

# Or get from backlog with specific criteria
acli jira --action getIssueList \
  --jql "project = PROJ AND assignee = currentUser() AND status = 'To Do' AND sprint is EMPTY" \
  --maxResults 1 \
  --outputFormat 999
```

---

## Output Structure

### CSV Output (outputFormat 2)

```csv
Key,Summary,Description,Status,Priority,Issue Type,Assignee,Reporter,Labels,Created,Updated
PROJ-123,"Add user authentication","Implement user login and registration...","In Progress","High","Story","username","reporter","backend,security","2024-12-01 10:00:00","2024-12-10 15:30:00"
```

### List Output (outputFormat 999)

```
PROJ-123
```

### Parsing CSV Output

```bash
# Read issue details
ISSUE_DATA=$(acli jira --action getIssue \
  --issue "$ARGUMENTS" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,issuetype,assignee,labels")

# Parse CSV (skip header)
echo "$ISSUE_DATA" | tail -n +2 | while IFS=',' read -r key summary description status priority issuetype assignee labels; do
  echo "Key: $key"
  echo "Summary: $summary"
  echo "Description: $description"
  echo "Status: $status"
  echo "Priority: $priority"
  echo "Type: $issuetype"
  echo "Assignee: $assignee"
  echo "Labels: $labels"
done
```

---

## Common Fields Reference

**Essential Fields**:
- `key` - Issue key (e.g., PROJ-123)
- `summary` - Issue title/summary
- `description` - Full issue description (may contain markdown)
- `status` - Current status (To Do, In Progress, Done, etc.)
- `priority` - Priority level (Highest, High, Medium, Low, Lowest)
- `issuetype` - Type (Story, Bug, Task, Epic, etc.)

**Metadata Fields**:
- `assignee` - Assigned user
- `reporter` - Issue creator
- `labels` - Comma-separated labels
- `created` - Creation timestamp
- `updated` - Last updated timestamp
- `duedate` - Due date (if set)

**Sprint/Project Fields**:
- `sprint` - Sprint name(s)
- `project` - Project key
- `fixversions` - Target version(s)
- `components` - Component(s)

**Custom Fields**:
- `customfield_xxxxx` - Access custom fields by ID

---

## Error Handling

### Issue Not Found

```bash
# Check if issue exists
if ! acli jira --action getIssue --issue "$ARGUMENTS" --outputFormat 999 &>/dev/null; then
  echo "Error: Jira issue $ARGUMENTS not found"

  # Suggest alternatives
  echo "Possible reasons:"
  echo "- Issue key is incorrect"
  echo "- You don't have permission to view this issue"
  echo "- Issue is in a different Jira project"

  exit 1
fi
```

### No Issues Found (for "next")

```bash
# Check if any issues match criteria
ISSUE_COUNT=$(acli jira --action getIssueList \
  --jql "assignee = currentUser() AND status != Done" \
  --outputFormat 999 | wc -l)

if [ "$ISSUE_COUNT" -eq 0 ]; then
  echo "No open issues assigned to you"

  # Use AskUserQuestion tool:
  # "No issues found assigned to you. What would you like to do?"
  # - View all sprint issues
  # - View backlog issues
  # - Specify issue key manually
fi
```

### Permission Errors

If acli returns permission errors:
- Verify acli is configured: Check `~/.acli/acli.properties`
- Verify user has access to project
- Check authentication token is valid
- Suggest running setup: `acli jira --action login`

---

## Integration with Other Components

After fetching, pass issue data to:

1. **issue-metadata-extraction.md** - Extract title, description, labels
2. **dependency-parsing.md** - Parse dependencies from issue description
3. Plan creation workflow - Convert issue to implementation plan

---

## Example Usage

```bash
# Fetch specific issue
acli jira --action getIssue \
  --issue "PROJ-123" \
  --outputFormat 2 \
  --columns "key,summary,description,status,priority,labels"

# Find next sprint issue
NEXT_ISSUE=$(acli jira --action getIssueList \
  --jql "sprint in openSprints() AND assignee = currentUser() AND status = 'To Do'" \
  --maxResults 1 \
  --outputFormat 999)

if [ -n "$NEXT_ISSUE" ]; then
  acli jira --action getIssue \
    --issue "$NEXT_ISSUE" \
    --outputFormat 2
fi

# Fetch issue with all comments
acli jira --action getComments \
  --issue "PROJ-123" \
  --outputFormat 2
```

---

## Advanced Queries

### Fetch Related Issues

```bash
# Get issues linked to current issue
acli jira --action getIssueList \
  --jql "issue in linkedIssues(PROJ-123)" \
  --outputFormat 2 \
  --columns "key,summary,status,linktype"
```

### Fetch Sub-tasks

```bash
# Get all sub-tasks of a story
acli jira --action getIssueList \
  --jql "parent = PROJ-123" \
  --outputFormat 2 \
  --columns "key,summary,status,assignee"
```

### Fetch Epic Issues

```bash
# Get all issues in an epic
acli jira --action getIssueList \
  --jql "'Epic Link' = PROJ-100" \
  --outputFormat 2 \
  --columns "key,summary,status,priority"
```

---

## Validation

After fetching, verify:

- [ ] Issue key retrieved successfully
- [ ] Summary and description are not empty
- [ ] Issue status indicates it's workable (not Done/Closed)
- [ ] Output is valid and parseable
- [ ] Description contains sufficient detail for planning

If issue lacks detail, prompt user:
```
Use AskUserQuestion tool:

"Jira issue PROJ-123 has minimal description. Would you like to:
- Proceed anyway and ask clarifying questions
- Update the issue in Jira first
- Skip this issue and work on another"
```

---

## Notes

- acli requires initial configuration in `~/.acli/acli.properties`
- Default server can be set to avoid `--server` flag on every command
- Use `--outputFormat 2` for CSV output (easier to parse)
- Use `--outputFormat 999` for issue keys only (one per line)
- Complex descriptions may contain Jira wiki markup - handle formatting
- Custom fields require knowing field IDs - use `getFieldList` to discover
- Rate limiting: Jira Cloud limits to ~10 requests/second
