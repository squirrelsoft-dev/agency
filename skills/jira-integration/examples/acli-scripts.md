# Atlassian CLI (acli) Script Examples

Practical shell scripts demonstrating common Jira automation patterns using acli. These scripts can be used directly or adapted for specific workflows.

## Issue Management Scripts

### Create Issue from Template

```bash
#!/bin/bash
# create-story.sh - Create a story from template

SUMMARY="$1"
DESCRIPTION="$2"
PRIORITY="${3:-Medium}"

if [ -z "$SUMMARY" ]; then
  echo "Usage: $0 'Summary' 'Description' [Priority]"
  exit 1
fi

acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --summary "$SUMMARY" \
  --description "$DESCRIPTION" \
  --priority "$PRIORITY" \
  --labels "needs-triage"
```

### Bulk Transition Issues

```bash
#!/bin/bash
# bulk-transition.sh - Transition multiple issues

ISSUES="$1"
TRANSITION="$2"

if [ -z "$TRANSITION" ]; then
  echo "Usage: $0 'ISSUE1,ISSUE2,ISSUE3' 'Transition Name'"
  exit 1
fi

acli jira --action progressIssue \
  --issue "$ISSUES" \
  --transition "$TRANSITION" \
  --continue
```

### Close Completed Issues

```bash
#!/bin/bash
# close-done-issues.sh - Close all issues marked as done

JQL="project = PROJ AND status = 'In Review' AND updated < -7d"

echo "Finding issues to close..."
ISSUES=$(acli jira --action getIssueList \
  --jql "$JQL" \
  --outputFormat 999)

if [ -z "$ISSUES" ]; then
  echo "No issues to close"
  exit 0
fi

echo "Closing issues:"
echo "$ISSUES"

echo "$ISSUES" | while read -r issue; do
  acli jira --action progressIssue \
    --issue "$issue" \
    --transition "Done" \
    --comment "Auto-closed after 7 days in review"
  echo "Closed $issue"
done
```

### Assign Issues by Label

```bash
#!/bin/bash
# assign-by-label.sh - Assign issues based on label

LABEL="$1"
ASSIGNEE="$2"

if [ -z "$ASSIGNEE" ]; then
  echo "Usage: $0 <label> <assignee>"
  exit 1
fi

acli jira --action getIssueList \
  --jql "project = PROJ AND labels = '$LABEL' AND assignee IS EMPTY" \
  --outputFormat 999 | \
acli jira --action assignIssue \
  --issue "@-" \
  --assignee "$ASSIGNEE" \
  --continue

echo "Assigned all issues with label '$LABEL' to $ASSIGNEE"
```

### Report Issue Statistics

```bash
#!/bin/bash
# issue-stats.sh - Generate issue statistics

PROJECT="${1:-PROJ}"

echo "=== Issue Statistics for $PROJECT ==="
echo ""

TOTAL=$(acli jira --action getIssueList \
  --jql "project = $PROJECT" \
  --outputFormat 999 | wc -l)

TODO=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND status = 'To Do'" \
  --outputFormat 999 | wc -l)

IN_PROGRESS=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND status = 'In Progress'" \
  --outputFormat 999 | wc -l)

DONE=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND status = 'Done'" \
  --outputFormat 999 | wc -l)

echo "Total Issues: $TOTAL"
echo "To Do: $TODO"
echo "In Progress: $IN_PROGRESS"
echo "Done: $DONE"
echo ""

if [ "$TOTAL" -gt 0 ]; then
  VELOCITY=$((DONE * 100 / TOTAL))
  echo "Completion Rate: ${VELOCITY}%"
fi
```

---

## Sprint Management Scripts

### Create and Start Sprint

```bash
#!/bin/bash
# create-sprint.sh - Create and populate sprint

SPRINT_NAME="$1"
START_DATE="$2"
END_DATE="$3"

if [ -z "$END_DATE" ]; then
  echo "Usage: $0 'Sprint Name' 'YYYY-MM-DD' 'YYYY-MM-DD'"
  exit 1
fi

echo "Creating sprint: $SPRINT_NAME"
acli jira --action createSprint \
  --board "PROJ Board" \
  --name "$SPRINT_NAME" \
  --startDate "$START_DATE" \
  --endDate "$END_DATE"

echo "Adding sprint-ready issues..."
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready'" \
  --outputFormat 999 | \
acli jira --action addIssuesToSprint \
  --sprint "$SPRINT_NAME" \
  --issue "@-"

echo "Starting sprint..."
acli jira --action startSprint \
  --sprint "$SPRINT_NAME"

echo "Sprint $SPRINT_NAME created and started!"
```

### Sprint Planning Helper

```bash
#!/bin/bash
# sprint-planning.sh - Prepare issues for sprint planning

echo "=== Sprint Planning Report ==="
echo ""

echo "Sprint-Ready Issues:"
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready' AND sprint IS EMPTY" \
  --outputFormat 2 \
  --columns "key,summary,priority,assignee"

echo ""
echo "Blocked Issues:"
acli jira --action getIssueList \
  --jql "project = PROJ AND (status = Blocked OR labels = blocked)" \
  --outputFormat 2 \
  --columns "key,summary,status"

echo ""
echo "Overdue Issues:"
acli jira --action getIssueList \
  --jql "project = PROJ AND duedate < now() AND status != Done" \
  --outputFormat 2 \
  --columns "key,summary,duedate,assignee"
```

### Close Sprint and Move Items

```bash
#!/bin/bash
# close-sprint.sh - Close sprint and move incomplete items

CURRENT_SPRINT="$1"
NEXT_SPRINT="$2"

if [ -z "$NEXT_SPRINT" ]; then
  echo "Usage: $0 'Current Sprint' 'Next Sprint'"
  exit 1
fi

echo "Closing sprint: $CURRENT_SPRINT"
echo "Moving incomplete items to: $NEXT_SPRINT"

# Get incomplete issues
INCOMPLETE=$(acli jira --action getIssueList \
  --jql "sprint = '$CURRENT_SPRINT' AND status != Done" \
  --outputFormat 999)

if [ -n "$INCOMPLETE" ]; then
  echo "Moving $( echo "$INCOMPLETE" | wc -l) incomplete issues..."

  echo "$INCOMPLETE" | while read -r issue; do
    acli jira --action removeIssuesFromSprint \
      --sprint "$CURRENT_SPRINT" \
      --issue "$issue"

    acli jira --action addIssuesToSprint \
      --sprint "$NEXT_SPRINT" \
      --issue "$issue"

    echo "Moved $issue to $NEXT_SPRINT"
  done
fi

# Close sprint
acli jira --action completeSprint \
  --sprint "$CURRENT_SPRINT"

echo "Sprint closed!"
```

### Sprint Velocity Report

```bash
#!/bin/bash
# sprint-velocity.sh - Calculate sprint velocity

SPRINT="$1"

if [ -z "$SPRINT" ]; then
  echo "Usage: $0 'Sprint Name'"
  exit 1
fi

echo "=== Sprint Velocity Report: $SPRINT ==="
echo ""

TOTAL=$(acli jira --action getIssueList \
  --jql "sprint = '$SPRINT'" \
  --outputFormat 999 | wc -l)

COMPLETED=$(acli jira --action getIssueList \
  --jql "sprint = '$SPRINT' AND status = Done" \
  --outputFormat 999 | wc -l)

IN_PROGRESS=$(acli jira --action getIssueList \
  --jql "sprint = '$SPRINT' AND status = 'In Progress'" \
  --outputFormat 999 | wc -l)

TODO=$(acli jira --action getIssueList \
  --jql "sprint = '$SPRINT' AND status = 'To Do'" \
  --outputFormat 999 | wc -l)

echo "Total Stories: $TOTAL"
echo "Completed: $COMPLETED"
echo "In Progress: $IN_PROGRESS"
echo "To Do: $TODO"
echo ""

if [ "$TOTAL" -gt 0 ]; then
  VELOCITY=$((COMPLETED * 100 / TOTAL))
  echo "Velocity: ${VELOCITY}%"
fi

echo ""
echo "Completed Issues:"
acli jira --action getIssueList \
  --jql "sprint = '$SPRINT' AND status = Done" \
  --outputFormat 2 \
  --columns "key,summary,assignee"
```

---

## Bulk Operations

### Bulk Label Update

```bash
#!/bin/bash
# bulk-label.sh - Add label to multiple issues

OLD_LABEL="$1"
NEW_LABEL="$2"

if [ -z "$NEW_LABEL" ]; then
  echo "Usage: $0 <old-label> <new-label>"
  exit 1
fi

echo "Finding issues with label '$OLD_LABEL'..."
ISSUES=$(acli jira --action getIssueList \
  --jql "project = PROJ AND labels = '$OLD_LABEL'" \
  --outputFormat 999)

if [ -z "$ISSUES" ]; then
  echo "No issues found"
  exit 0
fi

COUNT=$(echo "$ISSUES" | wc -l)
echo "Updating $COUNT issues..."

echo "$ISSUES" | while read -r issue; do
  acli jira --action updateIssue \
    --issue "$issue" \
    --labels "$OLD_LABEL" \
    --labelsRemove

  acli jira --action updateIssue \
    --issue "$issue" \
    --labels "$NEW_LABEL" \
    --labelsAdd

  echo "Updated $issue"
done

echo "Done!"
```

### Bulk Priority Update

```bash
#!/bin/bash
# set-priority.sh - Set priority for issues matching JQL

JQL="$1"
PRIORITY="$2"

if [ -z "$PRIORITY" ]; then
  echo "Usage: $0 'JQL Query' 'Priority'"
  exit 1
fi

echo "Finding issues..."
acli jira --action getIssueList \
  --jql "$JQL" \
  --outputFormat 999 | \
acli jira --action updateIssue \
  --issue "@-" \
  --priority "$PRIORITY" \
  --continue

echo "Priority updated to $PRIORITY"
```

### Copy Issues Between Projects

```bash
#!/bin/bash
# copy-issues.sh - Copy issues from one project to another

SOURCE_PROJECT="$1"
TARGET_PROJECT="$2"
JQL_FILTER="${3:-status = 'To Do'}"

if [ -z "$TARGET_PROJECT" ]; then
  echo "Usage: $0 <source-project> <target-project> [jql-filter]"
  exit 1
fi

echo "Copying issues from $SOURCE_PROJECT to $TARGET_PROJECT"
echo "Filter: $JQL_FILTER"

acli jira --action getIssueList \
  --jql "project = $SOURCE_PROJECT AND $JQL_FILTER" \
  --outputFormat 2 \
  --columns "summary,description,priority,issuetype" | \
  tail -n +2 | while IFS=',' read -r summary description priority issuetype; do

  acli jira --action createIssue \
    --project "$TARGET_PROJECT" \
    --type "$issuetype" \
    --summary "$summary" \
    --description "$description" \
    --priority "$priority"

  echo "Copied: $summary"
done
```

---

## Reporting Scripts

### Daily Status Report

```bash
#!/bin/bash
# daily-status.sh - Generate daily status report

DATE=$(date +%Y-%m-%d)
PROJECT="${1:-PROJ}"

echo "=== Daily Status Report - $DATE ==="
echo "Project: $PROJECT"
echo ""

echo "Created Today:"
acli jira --action getIssueList \
  --jql "project = $PROJECT AND created >= startOfDay()" \
  --outputFormat 2 \
  --columns "key,summary,issuetype,reporter"

echo ""
echo "Completed Today:"
acli jira --action getIssueList \
  --jql "project = $PROJECT AND resolutiondate >= startOfDay()" \
  --outputFormat 2 \
  --columns "key,summary,assignee"

echo ""
echo "Currently In Progress:"
acli jira --action getIssueList \
  --jql "project = $PROJECT AND status = 'In Progress'" \
  --outputFormat 2 \
  --columns "key,summary,assignee,updated"

echo ""
echo "Overdue:"
acli jira --action getIssueList \
  --jql "project = $PROJECT AND duedate < now() AND status != Done" \
  --outputFormat 2 \
  --columns "key,summary,duedate,assignee"
```

### Team Workload Report

```bash
#!/bin/bash
# team-workload.sh - Show team member workload

PROJECT="${1:-PROJ}"

echo "=== Team Workload Report ==="
echo "Project: $PROJECT"
echo ""

# Get all assignees
ASSIGNEES=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND assignee IS NOT EMPTY AND status != Done" \
  --outputFormat 2 \
  --columns "assignee" | tail -n +2 | sort -u)

echo "$ASSIGNEES" | while read -r assignee; do
  COUNT=$(acli jira --action getIssueList \
    --jql "project = $PROJECT AND assignee = '$assignee' AND status != Done" \
    --outputFormat 999 | wc -l)

  echo "$assignee: $COUNT open issues"
done
```

### Weekly Summary

```bash
#!/bin/bash
# weekly-summary.sh - Generate weekly summary

PROJECT="${1:-PROJ}"

echo "=== Weekly Summary ==="
echo "Project: $PROJECT"
echo "Week: $(date +%Y-%W)"
echo ""

CREATED=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND created >= startOfWeek()" \
  --outputFormat 999 | wc -l)

COMPLETED=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND resolutiondate >= startOfWeek()" \
  --outputFormat 999 | wc -l)

IN_PROGRESS=$(acli jira --action getIssueList \
  --jql "project = $PROJECT AND status = 'In Progress'" \
  --outputFormat 999 | wc -l)

echo "Issues Created: $CREATED"
echo "Issues Completed: $COMPLETED"
echo "Currently In Progress: $IN_PROGRESS"
echo ""

echo "Top Contributors (by completion):"
acli jira --action getIssueList \
  --jql "project = $PROJECT AND resolutiondate >= startOfWeek()" \
  --outputFormat 2 \
  --columns "assignee" | tail -n +2 | sort | uniq -c | sort -rn | head -5
```

---

## Integration Scripts

### Sync with Git Commits

```bash
#!/bin/bash
# sync-with-git.sh - Auto-transition issues based on git commits

# Get recent commits
git log --since="1 day ago" --pretty=format:"%s" | \
  grep -oP '[A-Z]+-\d+' | sort -u | while read -r issue; do

  echo "Found $issue in git commits"

  # Check current status
  STATUS=$(acli jira --action getIssue \
    --issue "$issue" \
    --outputFormat 2 \
    --columns "status" | tail -1)

  # Auto-transition to In Progress if in To Do
  if [ "$STATUS" = "To Do" ]; then
    acli jira --action progressIssue \
      --issue "$issue" \
      --transition "In Progress" \
      --comment "Automatically moved to In Progress based on git activity"
    echo "Moved $issue to In Progress"
  fi
done
```

### Export to CSV

```bash
#!/bin/bash
# export-issues.sh - Export issues to CSV

JQL="${1:-project = PROJ AND sprint in openSprints()}"
OUTPUT_FILE="${2:-issues-$(date +%Y%m%d).csv}"

echo "Exporting issues to $OUTPUT_FILE"
echo "Query: $JQL"

acli jira --action getIssueList \
  --jql "$JQL" \
  --outputFormat 2 \
  --columns "key,summary,status,assignee,priority,created,updated" \
  --file "$OUTPUT_FILE"

echo "Exported to $OUTPUT_FILE"
echo "Total issues: $(tail -n +2 "$OUTPUT_FILE" | wc -l)"
```

---

## Automation Scripts

### Auto-label by Component

```bash
#!/bin/bash
# auto-label.sh - Automatically label issues based on component

acli jira --action getIssueList \
  --jql "project = PROJ AND component = 'API' AND labels NOT IN (backend)" \
  --outputFormat 999 | \
acli jira --action updateIssue \
  --issue "@-" \
  --labels "backend" \
  --labelsAdd \
  --continue

acli jira --action getIssueList \
  --jql "project = PROJ AND component = 'Frontend' AND labels NOT IN (frontend)" \
  --outputFormat 999 | \
acli jira --action updateIssue \
  --issue "@-" \
  --labels "frontend" \
  --labelsAdd \
  --continue

echo "Auto-labeling complete"
```

### Stale Issue Reminder

```bash
#!/bin/bash
# stale-reminder.sh - Comment on stale issues

DAYS_STALE="${1:-30}"

echo "Finding issues not updated in $DAYS_STALE days..."

acli jira --action getIssueList \
  --jql "project = PROJ AND updated < -${DAYS_STALE}d AND status != Done" \
  --outputFormat 999 | while read -r issue; do

  acli jira --action addComment \
    --issue "$issue" \
    --comment "This issue hasn't been updated in $DAYS_STALE days. Please review and update status."

  echo "Added reminder to $issue"
done
```

---

## Best Practices

1. **Error handling**: Add `--continue` flag for bulk operations
2. **Testing**: Use `--simulate` flag to test without executing
3. **Logging**: Redirect output to log files for audit trail
4. **Credentials**: Use config file instead of command-line parameters
5. **Rate limiting**: Add delays between operations for large batches
6. **Validation**: Check JQL queries return expected results before bulk operations
7. **Backup**: Export issues before bulk updates
8. **Permissions**: Ensure service account has required permissions
9. **Monitoring**: Log script execution and results
10. **Documentation**: Comment scripts with usage examples

---

## Notes

- All scripts assume `acli` is installed and configured with valid credentials
- Set default server in `~/.acli/acli.properties` for convenience
- Use `--outputFormat 999` to get issue keys only (one per line)
- Use `--outputFormat 2` for CSV output
- The `@-` parameter reads input from stdin (for piping)
- Add error handling and logging for production use
- Consider rate limits when running bulk operations (10 req/sec for Jira Cloud)
