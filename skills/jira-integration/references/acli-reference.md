# Atlassian CLI (acli) Complete Reference

Comprehensive reference for the Atlassian Command Line Interface (acli), covering installation, configuration, and all major commands for Jira automation.

## Installation

### Download and Setup

```bash
# Download acli (check latest version at bob swift website)
curl -O https://bobswift.atlassian.net/wiki/download/attachments/16285777/acli-9.8.0-distribution.zip

# Extract
unzip acli-9.8.0-distribution.zip -d ~/acli

# Add to PATH
echo 'export PATH=$PATH:~/acli' >> ~/.bashrc
source ~/.bashrc

# Verify installation
acli jira --help
```

### Configuration

**Method 1: Command-line parameters**
```bash
acli jira --server https://your-domain.atlassian.net \
  --user user@example.com \
  --password your-api-token \
  --action getServerInfo
```

**Method 2: Configuration file**

Create `~/.acli/acli.properties`:
```properties
server=https://your-domain.atlassian.net
user=user@example.com
password=your-api-token
```

Then run without credentials:
```bash
acli jira --action getServerInfo
```

**Method 3: Environment variables**
```bash
export ACLI_SERVER=https://your-domain.atlassian.net
export ACLI_USER=user@example.com
export ACLI_PASSWORD=your-api-token

acli jira --action getServerInfo
```

---

## Core Commands

### getServerInfo

Get Jira server information.

```bash
acli jira --action getServerInfo
```

### login

Authenticate and store credentials.

```bash
acli jira --action login \
  --server https://your-domain.atlassian.net \
  --user user@example.com \
  --password your-api-token
```

---

## Issue Commands

### getIssueList

List issues using JQL queries.

```bash
# Basic list
acli jira --action getIssueList \
  --project PROJ

# With JQL query
acli jira --action getIssueList \
  --jql "project = PROJ AND status = 'To Do'"

# With specific output format
acli jira --action getIssueList \
  --jql "assignee = currentUser()" \
  --outputFormat 2

# With specific columns
acli jira --action getIssueList \
  --jql "project = PROJ" \
  --outputFormat 2 \
  --columns "key,summary,status,assignee,priority"

# Limit results
acli jira --action getIssueList \
  --jql "project = PROJ" \
  --limit 50

# Output to file
acli jira --action getIssueList \
  --jql "project = PROJ" \
  --file issues.txt \
  --append
```

**Output Formats**:
- `1`: Standard format (default)
- `2`: CSV format
- `999`: Issue keys only (one per line)

### getIssue

Get detailed information about a specific issue.

```bash
# Basic issue details
acli jira --action getIssue \
  --issue PROJ-123

# With specific output format
acli jira --action getIssue \
  --issue PROJ-123 \
  --outputFormat 2

# With specific columns
acli jira --action getIssue \
  --issue PROJ-123 \
  --outputFormat 2 \
  --columns "key,summary,description,status,assignee,reporter,created,updated"

# Output to file
acli jira --action getIssue \
  --issue PROJ-123 \
  --file issue-details.txt
```

### createIssue

Create a new issue.

```bash
# Basic issue creation
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --summary "Implement authentication"

# With full details
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --summary "Implement authentication" \
  --description "Add OAuth2 authentication to the application" \
  --priority "High" \
  --assignee "john.doe" \
  --labels "backend,security" \
  --components "API,Security"

# With custom fields
acli jira --action createIssue \
  --project PROJ \
  --type "Bug" \
  --summary "Login fails on mobile" \
  --field "customfield_10001=High Priority" \
  --field "customfield_10002=Mobile App"

# From file
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --file issue-template.txt \
  --findReplace "SUMMARY:Implement authentication" \
  --findReplace "DESCRIPTION:Add OAuth2 support"

# Create multiple issues
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --file issues-list.csv \
  --continue
```

### updateIssue

Update an existing issue.

```bash
# Update summary
acli jira --action updateIssue \
  --issue PROJ-123 \
  --summary "Updated summary"

# Update multiple fields
acli jira --action updateIssue \
  --issue PROJ-123 \
  --summary "Updated summary" \
  --description "Updated description" \
  --priority "Critical"

# Update assignee
acli jira --action updateIssue \
  --issue PROJ-123 \
  --assignee "jane.doe"

# Update custom fields
acli jira --action updateIssue \
  --issue PROJ-123 \
  --field "customfield_10001=New Value" \
  --field "customfield_10002=Another Value"

# Add labels (append)
acli jira --action updateIssue \
  --issue PROJ-123 \
  --labels "new-label" \
  --labelsAdd

# Replace labels
acli jira --action updateIssue \
  --issue PROJ-123 \
  --labels "label1,label2,label3"

# Remove labels
acli jira --action updateIssue \
  --issue PROJ-123 \
  --labels "old-label" \
  --labelsRemove

# Update multiple issues
acli jira --action updateIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --labels "sprint-24" \
  --labelsAdd
```

### progressIssue (transitionIssue)

Transition an issue to a new status.

```bash
# Basic transition
acli jira --action progressIssue \
  --issue PROJ-123 \
  --transition "In Progress"

# With comment
acli jira --action progressIssue \
  --issue PROJ-123 \
  --transition "Done" \
  --comment "Completed implementation and testing"

# With resolution
acli jira --action progressIssue \
  --issue PROJ-123 \
  --transition "Done" \
  --resolution "Fixed"

# Transition multiple issues
acli jira --action progressIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --transition "In Progress"
```

**Common transitions**:
- "To Do" → "In Progress"
- "In Progress" → "In Review"
- "In Review" → "Done"
- Any → "Blocked"
- Any → "Backlog"

### assignIssue

Assign an issue to a user.

```bash
# Assign to user
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "john.doe"

# Assign to me
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "@me"

# Unassign (assign to nobody)
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "@unassigned"

# Assign multiple issues
acli jira --action assignIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --assignee "john.doe"
```

### deleteIssue

Delete an issue.

```bash
# Delete single issue
acli jira --action deleteIssue \
  --issue PROJ-123

# Delete multiple issues
acli jira --action deleteIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125"
```

---

## Comment Commands

### addComment

Add a comment to an issue.

```bash
# Simple comment
acli jira --action addComment \
  --issue PROJ-123 \
  --comment "This looks good!"

# Comment from file
acli jira --action addComment \
  --issue PROJ-123 \
  --file comment.txt

# Comment with mentions
acli jira --action addComment \
  --issue PROJ-123 \
  --comment "[~john.doe] Please review this issue"
```

### getCommentList

List comments on an issue.

```bash
# Get all comments
acli jira --action getCommentList \
  --issue PROJ-123

# With specific output format
acli jira --action getCommentList \
  --issue PROJ-123 \
  --outputFormat 2
```

---

## Sprint Commands

### getSprintList

List sprints for a board.

```bash
# List all sprints
acli jira --action getSprintList \
  --board "PROJ Board"

# List active sprints only
acli jira --action getSprintList \
  --board "PROJ Board" \
  --state "active"

# List future sprints
acli jira --action getSprintList \
  --board "PROJ Board" \
  --state "future"

# List closed sprints
acli jira --action getSprintList \
  --board "PROJ Board" \
  --state "closed"
```

### createSprint

Create a new sprint.

```bash
# Create sprint with dates
acli jira --action createSprint \
  --board "PROJ Board" \
  --name "Sprint 25" \
  --startDate "2024-01-15" \
  --endDate "2024-01-28"

# Create sprint without dates (backlog sprint)
acli jira --action createSprint \
  --board "PROJ Board" \
  --name "Sprint 25"
```

### startSprint

Start a sprint.

```bash
# Start sprint
acli jira --action startSprint \
  --sprint "Sprint 25" \
  --startDate "2024-01-15" \
  --endDate "2024-01-28"

# Start with goal
acli jira --action startSprint \
  --sprint "Sprint 25" \
  --startDate "2024-01-15" \
  --endDate "2024-01-28" \
  --goal "Complete authentication feature"
```

### completeSprint

Complete (close) a sprint.

```bash
# Complete sprint (move incomplete issues to backlog)
acli jira --action completeSprint \
  --sprint "Sprint 25"

# Complete sprint (move incomplete issues to next sprint)
acli jira --action completeSprint \
  --sprint "Sprint 25" \
  --moveIssuesTo "Sprint 26"
```

### addIssuesToSprint

Add issues to a sprint.

```bash
# Add single issue
acli jira --action addIssuesToSprint \
  --sprint "Sprint 25" \
  --issue "PROJ-123"

# Add multiple issues
acli jira --action addIssuesToSprint \
  --sprint "Sprint 25" \
  --issue "PROJ-123,PROJ-124,PROJ-125"

# Add issues from JQL query
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready'" \
  --outputFormat 999 | \
acli jira --action addIssuesToSprint \
  --sprint "Sprint 25" \
  --issue "@-"
```

### removeIssuesFromSprint

Remove issues from a sprint.

```bash
# Remove single issue
acli jira --action removeIssuesFromSprint \
  --sprint "Sprint 25" \
  --issue "PROJ-123"

# Remove multiple issues
acli jira --action removeIssuesFromSprint \
  --sprint "Sprint 25" \
  --issue "PROJ-123,PROJ-124,PROJ-125"
```

---

## Board Commands

### getBoardList

List boards.

```bash
# List all boards
acli jira --action getBoardList

# List boards for project
acli jira --action getBoardList \
  --project PROJ

# With output format
acli jira --action getBoardList \
  --outputFormat 2
```

### getBoard

Get board details.

```bash
# Get board configuration
acli jira --action getBoard \
  --board "PROJ Board"

# With output format
acli jira --action getBoard \
  --board "PROJ Board" \
  --outputFormat 2
```

---

## Project Commands

### getProjectList

List projects.

```bash
# List all projects
acli jira --action getProjectList

# With output format
acli jira --action getProjectList \
  --outputFormat 2

# With specific columns
acli jira --action getProjectList \
  --outputFormat 2 \
  --columns "key,name,lead,description"
```

### getProject

Get project details.

```bash
# Get project info
acli jira --action getProject \
  --project PROJ

# With output format
acli jira --action getProject \
  --project PROJ \
  --outputFormat 2
```

---

## User Commands

### getUser

Get user information.

```bash
# Get user details
acli jira --action getUser \
  --userId "john.doe"

# Get current user
acli jira --action getUser \
  --userId "@me"
```

### getUserList

List users.

```bash
# List all users
acli jira --action getUserList

# Search for users
acli jira --action getUserList \
  --search "john"
```

---

## Advanced Features

### Batch Operations

**Read from file**:
```bash
# Process issues from file (one issue key per line)
cat issues.txt | acli jira --action updateIssue \
  --issue "@-" \
  --labels "sprint-24" \
  --labelsAdd
```

**Output to file**:
```bash
# Write results to file
acli jira --action getIssueList \
  --jql "project = PROJ" \
  --file results.txt

# Append to file
acli jira --action getIssueList \
  --jql "project = PROJ" \
  --file results.txt \
  --append
```

### Find and Replace

```bash
# Use placeholders in templates
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --file template.txt \
  --findReplace "@SUMMARY@:New Feature" \
  --findReplace "@PRIORITY@:High"
```

### Continue on Error

```bash
# Continue processing on errors
acli jira --action updateIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --labels "updated" \
  --labelsAdd \
  --continue
```

### Verbose Output

```bash
# Enable verbose logging
acli jira --action getIssue \
  --issue PROJ-123 \
  --verbose
```

### Simulate Mode

```bash
# Test without executing
acli jira --action updateIssue \
  --issue PROJ-123 \
  --summary "Updated summary" \
  --simulate
```

---

## Common Patterns

### Bulk Issue Creation

```bash
# Create issues from CSV file
# Format: type,summary,description,priority
cat issues.csv | while IFS=',' read -r type summary description priority; do
  acli jira --action createIssue \
    --project PROJ \
    --type "$type" \
    --summary "$summary" \
    --description "$description" \
    --priority "$priority"
done
```

### Sprint Planning

```bash
# Add all sprint-ready issues to current sprint
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready'" \
  --outputFormat 999 | \
acli jira --action addIssuesToSprint \
  --sprint "current" \
  --issue "@-"
```

### Status Report

```bash
# Generate status report
echo "=== Project Status Report ==="
echo ""
echo "To Do:"
acli jira --action getIssueList \
  --jql "project = PROJ AND status = 'To Do'" \
  --outputFormat 999 | wc -l

echo "In Progress:"
acli jira --action getIssueList \
  --jql "project = PROJ AND status = 'In Progress'" \
  --outputFormat 999 | wc -l

echo "Done:"
acli jira --action getIssueList \
  --jql "project = PROJ AND status = 'Done'" \
  --outputFormat 999 | wc -l
```

### Bulk Transition

```bash
# Move all "To Do" items to "In Progress"
acli jira --action getIssueList \
  --jql "project = PROJ AND status = 'To Do' AND assignee = currentUser()" \
  --outputFormat 999 | \
acli jira --action progressIssue \
  --issue "@-" \
  --transition "In Progress" \
  --continue
```

---

## Error Handling

### Common Errors

**Authentication failed**:
```
Error: Authentication failed
```
Solution: Check credentials in acli.properties or command-line parameters

**Invalid JQL**:
```
Error: Invalid JQL query
```
Solution: Validate JQL syntax, check field names and operators

**Issue not found**:
```
Error: Issue PROJ-123 does not exist
```
Solution: Verify issue key, check permissions

**Invalid transition**:
```
Error: Transition 'Done' not found
```
Solution: Check available transitions for issue's current status

**Rate limit exceeded**:
```
Error: Rate limit exceeded
```
Solution: Implement delays between requests, reduce frequency

---

## Best Practices

1. **Use configuration file**: Store credentials in `~/.acli/acli.properties`
2. **Use API tokens**: Never use passwords, always use API tokens
3. **Validate before bulk operations**: Test with `--simulate` flag
4. **Handle errors**: Use `--continue` for bulk operations
5. **Use JQL for filtering**: More efficient than processing in shell
6. **Output to files**: Use `--file` for large result sets
7. **Use specific columns**: Reduce data transfer with `--columns`
8. **Batch operations**: Group multiple actions when possible
9. **Check permissions**: Ensure user has required permissions
10. **Monitor rate limits**: Jira API has rate limits (10 req/sec)

---

## Resources

- **Official Documentation**: https://bobswift.atlassian.net/wiki/spaces/ACLI/overview
- **Jira REST API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **JQL Reference**: https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/
- **API Tokens**: https://id.atlassian.com/manage-profile/security/api-tokens
