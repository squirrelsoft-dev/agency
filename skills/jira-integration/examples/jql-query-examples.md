# JQL Query Examples

Practical JQL (Jira Query Language) queries for common use cases, organized by category. Copy and adapt these queries for your specific needs.

## Basic Queries

### By Project

```jql
# All issues in project
project = PROJ

# Multiple projects
project IN (PROJ, TEAM, DEV)

# Exclude project
project != PROJ
```

### By Issue Type

```jql
# All bugs
issuetype = Bug

# Stories and tasks
issuetype IN (Story, Task)

# Everything except subtasks
issuetype != Sub-task
```

### By Status

```jql
# Open issues
status = "To Do"

# In progress
status = "In Progress"

# Any open status
status IN ("To Do", "In Progress", "Review")

# Not done
status != Done

# Closed issues
status = Closed OR status = Done
```

---

## Assignment Queries

```jql
# Assigned to me
assignee = currentUser()

# Unassigned
assignee IS EMPTY

# Specific user
assignee = "john.doe"

# Assigned to team members
assignee IN ("john.doe", "jane.smith", "bob.jones")

# Not assigned to me
assignee != currentUser()

# Was ever assigned to me
assignee WAS currentUser()
```

---

## Date-Based Queries

### Created Date

```jql
# Created today
created >= startOfDay()

# Created in last 7 days
created >= -7d

# Created this week
created >= startOfWeek()

# Created last month
created >= startOfMonth(-1) AND created < startOfMonth()

# Created between dates
created >= "2024-01-01" AND created <= "2024-01-31"
```

### Updated Date

```jql
# Updated today
updated >= startOfDay()

# Updated in last hour
updated >= -1h

# Updated this week
updated >= startOfWeek()

# Not updated in 30 days
updated < -30d
```

### Due Date

```jql
# Due today
duedate = endOfDay()

# Overdue
duedate < now() AND status != Done

# Due this week
duedate >= startOfWeek() AND duedate <= endOfWeek()

# Due in next 7 days
duedate >= now() AND duedate <= 7d

# No due date
duedate IS EMPTY
```

### Resolution Date

```jql
# Resolved today
resolutiondate >= startOfDay()

# Resolved this sprint
resolutiondate >= startOfMonth() AND resolutiondate <= endOfMonth()
```

---

## Label Queries

```jql
# Has specific label
labels = backend

# Has any of these labels
labels IN (backend, frontend, api)

# Has both labels
labels = backend AND labels = urgent

# Missing labels
labels IS EMPTY

# Has label starting with...
labels ~ "sprint-*"
```

---

## Priority Queries

```jql
# High priority
priority = High

# Critical and high
priority IN (Highest, High)

# Not low priority
priority != Low

# Has priority set
priority IS NOT EMPTY
```

---

## Sprint Queries

```jql
# Current sprint issues
sprint in openSprints()

# Specific sprint
sprint = "Sprint 24"

# Future sprints
sprint in futureSprints()

# Issues not in any sprint
sprint IS EMPTY

# Issues in closed sprints
sprint in closedSprints()

# Issues in active sprint for board
sprint in openSprints() AND project = PROJ
```

---

## Epic Queries

```jql
# Issues in specific epic
"Epic Link" = PROJ-100

# Issues with any epic
"Epic Link" IS NOT EMPTY

# Issues without epic
"Epic Link" IS EMPTY

# Epic itself
issuetype = Epic

# Epics in project
project = PROJ AND issuetype = Epic
```

---

## Component Queries

```jql
# Specific component
component = "API"

# Multiple components
component IN ("API", "Frontend")

# No component
component IS EMPTY

# Has any component
component IS NOT EMPTY
```

---

## Text Search Queries

```jql
# Search in summary and description
text ~ "authentication"

# Summary contains
summary ~ "login"

# Description contains
description ~ "database"

# Exact phrase
summary ~ "\"user authentication\""

# Multiple keywords (OR)
text ~ "login OR signup OR register"

# Multiple keywords (AND)
text ~ "login" AND text ~ "mobile"
```

---

## Reporter and Creator Queries

```jql
# Reported by me
reporter = currentUser()

# Created by specific user
creator = "john.doe"

# Not reported by me
reporter != currentUser()
```

---

## Watcher Queries

```jql
# I'm watching
watcher = currentUser()

# Specific user is watching
watcher = "john.doe"

# Has watchers
watchers IS NOT EMPTY
```

---

## Comment Queries

```jql
# Has comments
comment IS NOT EMPTY

# Commented by me
comment ~ currentUser()

# No comments
comment IS EMPTY
```

---

## Advanced Combination Queries

### Sprint Planning

```jql
# Sprint backlog (ready to pull in)
project = PROJ AND
labels = "sprint-ready" AND
sprint IS EMPTY AND
status = "To Do"
ORDER BY priority DESC, created ASC
```

### My Current Work

```jql
# What I'm working on now
assignee = currentUser() AND
status IN ("In Progress", "Review") AND
sprint in openSprints()
ORDER BY updated DESC
```

### Overdue High Priority Items

```jql
# Critical overdue items
priority IN (Highest, High) AND
duedate < now() AND
status NOT IN (Done, Closed)
ORDER BY duedate ASC
```

### Recently Completed

```jql
# Done this week
project = PROJ AND
status = Done AND
resolutiondate >= startOfWeek()
ORDER BY resolutiondate DESC
```

### Stale Issues

```jql
# Not updated in 30 days
project = PROJ AND
status != Done AND
updated < -30d
ORDER BY updated ASC
```

### Blocked Issues

```jql
# Issues marked as blocked
project = PROJ AND
(labels = blocked OR status = Blocked)
ORDER BY priority DESC
```

### Missing Information

```jql
# Issues without description
project = PROJ AND
description IS EMPTY AND
status != Done
```

### Bugs Reported This Month

```jql
# New bugs
issuetype = Bug AND
created >= startOfMonth() AND
status IN ("To Do", "In Progress")
ORDER BY priority DESC, created DESC
```

### Team Workload

```jql
# Team member's open issues
assignee IN membersOf("engineering-team") AND
status NOT IN (Done, Closed)
ORDER BY assignee ASC, priority DESC
```

### Sprint Velocity

```jql
# Completed in last sprint
project = PROJ AND
sprint = "Sprint 23" AND
status = Done
```

---

## Time Tracking Queries

```jql
# Has time logged
timespent IS NOT EMPTY

# No time logged
timespent IS EMPTY

# Over estimate
remainingEstimate < 0

# Has estimate
originalEstimate IS NOT EMPTY
```

---

## Linking Queries

```jql
# Has linked issues
issueFunction in linkedIssuesOf("PROJ-123")

# Blocks other issues
issueFunction in linkedIssuesOf("PROJ-123", "blocks")

# Is blocked by other issues
issueFunction in linkedIssuesOf("PROJ-123", "is blocked by")
```

---

## Custom Field Queries

```jql
# Custom field value
"Story Points" = 5

# Custom field range
"Story Points" >= 3 AND "Story Points" <= 8

# Custom field is empty
"Story Points" IS EMPTY

# Custom select field
"Team" = "Backend Team"
```

---

## Resolution Queries

```jql
# Specific resolution
resolution = Fixed

# Multiple resolutions
resolution IN (Fixed, Done)

# Unresolved
resolution IS EMPTY

# Won't fix
resolution = "Won't Fix"
```

---

## Functions and Advanced Features

### Time Functions

```jql
# Start of day/week/month/year
created >= startOfDay()
created >= startOfWeek()
created >= startOfMonth()
created >= startOfYear()

# End of day/week/month/year
duedate <= endOfDay()
duedate <= endOfWeek()
duedate <= endOfMonth()
duedate <= endOfYear()

# Now
updated >= now()
```

### Membership Functions

```jql
# Team members
assignee IN membersOf("team-name")

# Group members
reporter IN membersOf("developers")
```

### History Functions

```jql
# Status was ever...
status WAS "In Progress"

# Changed status
status CHANGED

# Changed by user
status CHANGED BY currentUser()

# Changed during period
status CHANGED AFTER -7d
```

---

## Sorting

```jql
# Single sort
ORDER BY priority DESC

# Multiple sorts
ORDER BY priority DESC, created ASC

# Common sort patterns
ORDER BY updated DESC           # Recently updated
ORDER BY created DESC           # Recently created
ORDER BY duedate ASC           # Soonest due
ORDER BY priority DESC, rank ASC  # Kanban board order
```

---

## Best Practices

1. **Use parentheses**: Group conditions with `AND`/`OR`
   ```jql
   (priority = High OR priority = Highest) AND status = "To Do"
   ```

2. **Quote strings with spaces**: Use quotes for multi-word values
   ```jql
   status = "In Progress"
   ```

3. **Use functions**: Leverage built-in functions for dates
   ```jql
   created >= startOfWeek()  # Better than manual dates
   ```

4. **Limit results**: Add `ORDER BY` for consistent sorting
   ```jql
   project = PROJ ORDER BY created DESC
   ```

5. **Test incrementally**: Build complex queries step by step

6. **Save common queries**: Save as filters for reuse

7. **Use field aliases**: Some fields have shortcuts
   - `assignee = currentUser()` vs `assignee = "@me"`

8. **Check field names**: Custom fields use full name with quotes
   ```jql
   "Story Points" = 5  # Not storyPoints
   ```

9. **Consider performance**: Avoid `text ~` on large projects

10. **Use `IN` for multiple values**: More efficient than multiple `OR`
    ```jql
    status IN ("To Do", "In Progress", "Review")  # Good
    status = "To Do" OR status = "In Progress" OR status = "Review"  # Verbose
    ```

---

## Resources

- **JQL Reference**: https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/
- **JQL Functions**: https://support.atlassian.com/jira-software-cloud/docs/jql-functions/
- **JQL Operators**: https://support.atlassian.com/jira-software-cloud/docs/jql-operators/
- **JQL Keywords**: https://support.atlassian.com/jira-software-cloud/docs/jql-keywords/
