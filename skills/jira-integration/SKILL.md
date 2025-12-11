---
name: jira-integration
description: Master Jira integration using acli CLI, Jira REST API, issue management, sprint operations, JQL queries, and ADF comment formatting. Essential for Jira-based project management automation.
triggers:
  - "jira integration"
  - "acli"
  - "atlassian cli"
  - "jira api"
  - "jql query"
  - "jira sprint"
  - "adf format"
  - "jira comment"
  - "jira issue detection"
---

# Jira Integration Mastery

This skill provides comprehensive guidance for integrating with Jira using the Atlassian CLI (acli), Jira REST API, and ADF (Atlassian Document Format). Essential for automating issue management, sprint planning, JQL queries, and building robust Jira-based workflows.

## When to Use This Skill

- Automating Jira issue creation, updates, and transitions
- Building sprint planning workflows
- Writing and executing JQL queries
- Formatting comments with ADF (Atlassian Document Format)
- Parsing Jira URLs and extracting metadata
- Integrating Jira into development automation
- Creating bulk operations across multiple issues

---

## Atlassian CLI (acli) Mastery

The Atlassian CLI (`acli`) is the primary tool for Jira automation via command line.

### Installation and Configuration

```bash
# Download acli
curl -O https://bobswift.atlassian.net/wiki/download/attachments/16285777/acli-9.8.0-distribution.zip

# Extract and setup
unzip acli-9.8.0-distribution.zip
export PATH=$PATH:/path/to/acli

# Configure connection
acli jira --server https://your-domain.atlassian.net --user user@example.com --password your-api-token --action getServerInfo

# Store credentials (creates ~/.acli/acli.properties)
acli jira --server https://your-domain.atlassian.net --user user@example.com --password your-api-token --action login
```

**Configuration file** (`~/.acli/acli.properties`):
```properties
server=https://your-domain.atlassian.net
user=user@example.com
password=your-api-token
```

### Issue Operations

**List issues**:
```bash
# List issues in project
acli jira --action getIssueList --project PROJ

# List with JQL
acli jira --action getIssueList --jql "project = PROJ AND status = 'To Do'"

# List with specific fields
acli jira --action getIssueList --jql "assignee = currentUser()" --outputFormat 2 --columns "key,summary,status"
```

**Get issue details**:
```bash
# Get full issue details
acli jira --action getIssue --issue PROJ-123

# Get specific fields
acli jira --action getIssue --issue PROJ-123 --outputFormat 2 --columns "key,summary,description,status,assignee"
```

**Create issue**:
```bash
# Create issue
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --summary "Implement authentication" \
  --description "Add OAuth2 authentication to the application" \
  --priority "High" \
  --labels "backend,security"

# Create with custom fields
acli jira --action createIssue \
  --project PROJ \
  --type "Bug" \
  --summary "Login fails on mobile" \
  --field "customfield_10001=High Priority"
```

**Update issue**:
```bash
# Update summary and description
acli jira --action updateIssue \
  --issue PROJ-123 \
  --summary "Updated summary" \
  --description "Updated description"

# Update custom fields
acli jira --action updateIssue \
  --issue PROJ-123 \
  --field "customfield_10001=New Value"

# Add labels
acli jira --action updateIssue \
  --issue PROJ-123 \
  --labels "bug,urgent" \
  --labelsAdd
```

**Transition issue**:
```bash
# Move to different status
acli jira --action transitionIssue \
  --issue PROJ-123 \
  --transition "In Progress"

# Transition with comment
acli jira --action transitionIssue \
  --issue PROJ-123 \
  --transition "Done" \
  --comment "Completed implementation and testing"
```

**Assign issue**:
```bash
# Assign to user
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "john.doe"

# Assign to me
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "@me"
```

### Sprint Operations

**List sprints**:
```bash
# List sprints for board
acli jira --action getSprintList \
  --board "PROJ Board"

# List active sprints
acli jira --action getSprintList \
  --board "PROJ Board" \
  --state "active"
```

**Add issues to sprint**:
```bash
# Add single issue
acli jira --action addIssuesToSprint \
  --sprint "Sprint 24" \
  --issue "PROJ-123"

# Add multiple issues
acli jira --action addIssuesToSprint \
  --sprint "Sprint 24" \
  --issue "PROJ-123,PROJ-124,PROJ-125"
```

**Start sprint**:
```bash
# Start sprint with date range
acli jira --action startSprint \
  --sprint "Sprint 24" \
  --startDate "2024-01-01" \
  --endDate "2024-01-14"
```

**Close sprint**:
```bash
# Complete sprint (moves incomplete issues to backlog)
acli jira --action completeSprint \
  --sprint "Sprint 24"
```

### Board Management

**List boards**:
```bash
# List all boards
acli jira --action getBoardList

# List boards for project
acli jira --action getBoardList \
  --project PROJ
```

**Get board configuration**:
```bash
# Get board details
acli jira --action getBoard \
  --board "PROJ Board"
```

### Bulk Operations

**Bulk transition**:
```bash
# Transition multiple issues
acli jira --action progressIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --transition "In Progress"
```

**Bulk update**:
```bash
# Update multiple issues
acli jira --action updateIssue \
  --issue "PROJ-123,PROJ-124" \
  --labels "sprint-24" \
  --labelsAdd
```

For complete acli command reference, see `references/acli-reference.md`.

---

## Jira REST API Patterns

### API Basics

```typescript
import axios from 'axios';

// Configure API client
const jiraClient = axios.create({
  baseURL: 'https://your-domain.atlassian.net/rest/api/3',
  auth: {
    username: 'user@example.com',
    password: 'your-api-token'
  },
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
});
```

### Issue CRUD Operations

**Get issue**:
```typescript
const response = await jiraClient.get(`/issue/PROJ-123`);
const issue = response.data;

console.log(issue.key);
console.log(issue.fields.summary);
console.log(issue.fields.status.name);
```

**Create issue**:
```typescript
const newIssue = await jiraClient.post('/issue', {
  fields: {
    project: {
      key: 'PROJ'
    },
    summary: 'Implement authentication',
    description: {
      type: 'doc',
      version: 1,
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Add OAuth2 authentication'
            }
          ]
        }
      ]
    },
    issuetype: {
      name: 'Story'
    },
    priority: {
      name: 'High'
    },
    labels: ['backend', 'security']
  }
});

console.log(`Created issue: ${newIssue.data.key}`);
```

**Update issue**:
```typescript
await jiraClient.put(`/issue/PROJ-123`, {
  fields: {
    summary: 'Updated summary',
    labels: ['bug', 'urgent']
  }
});
```

**Transition issue**:
```typescript
// Get available transitions
const transitionsResp = await jiraClient.get(`/issue/PROJ-123/transitions`);
const transitions = transitionsResp.data.transitions;

// Find "In Progress" transition
const inProgressTransition = transitions.find(t => t.name === 'In Progress');

// Execute transition
await jiraClient.post(`/issue/PROJ-123/transitions`, {
  transition: {
    id: inProgressTransition.id
  }
});
```

### Advanced Operations

**Add comment**:
```typescript
await jiraClient.post(`/issue/PROJ-123/comment`, {
  body: {
    type: 'doc',
    version: 1,
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'This issue has been reviewed and approved'
          }
        ]
      }
    ]
  }
});
```

**Add attachment**:
```typescript
import FormData from 'form-data';
import fs from 'fs';

const form = new FormData();
form.append('file', fs.createReadStream('screenshot.png'));

await jiraClient.post(`/issue/PROJ-123/attachments`, form, {
  headers: {
    ...form.getHeaders(),
    'X-Atlassian-Token': 'no-check'
  }
});
```

**Link issues**:
```typescript
await jiraClient.post('/issueLink', {
  type: {
    name: 'Blocks'
  },
  inwardIssue: {
    key: 'PROJ-123'
  },
  outwardIssue: {
    key: 'PROJ-456'
  }
});
```

For complete API patterns and examples, see `references/jira-api-patterns.md`.

---

## JQL (Jira Query Language)

JQL is Jira's query language for searching and filtering issues.

### Basic JQL Syntax

```jql
# Single condition
project = PROJ

# Multiple conditions (AND)
project = PROJ AND status = "To Do"

# Multiple conditions (OR)
status = "To Do" OR status = "In Progress"

# Negation
status != Done

# IN operator
status IN ("To Do", "In Progress")

# Comparison
created >= -7d
```

### Common JQL Queries

**By status**:
```jql
# Open issues
status IN ("To Do", "In Progress", "Review")

# Closed issues
status = Done

# Not done
status != Done
```

**By assignee**:
```jql
# Assigned to me
assignee = currentUser()

# Unassigned
assignee IS EMPTY

# Assigned to specific user
assignee = "john.doe"
```

**By date**:
```jql
# Created in last 7 days
created >= -7d

# Updated today
updated >= startOfDay()

# Due this week
due <= endOfWeek()
```

**By sprint**:
```jql
# Current sprint
sprint in openSprints()

# Specific sprint
sprint = "Sprint 24"

# Issues not in sprint
sprint IS EMPTY
```

**By label**:
```jql
# Has specific label
labels = backend

# Has any of multiple labels
labels IN (backend, frontend)

# Missing labels
labels IS EMPTY
```

### Advanced JQL Patterns

**Combination queries**:
```jql
# Sprint items assigned to me
project = PROJ AND sprint in openSprints() AND assignee = currentUser()

# High priority bugs
project = PROJ AND issuetype = Bug AND priority IN (Highest, High)

# Overdue items
duedate < now() AND status != Done
```

**Using functions**:
```jql
# Issues updated by me
updatedBy = currentUser()

# Issues where I'm a watcher
watcher = currentUser()

# Issues in epics
"Epic Link" IS NOT EMPTY
```

**Ordering results**:
```jql
# Order by priority, then created date
project = PROJ ORDER BY priority DESC, created ASC

# Multiple sort fields
status = "To Do" ORDER BY priority DESC, updated DESC
```

For 30+ JQL query examples, see `examples/jql-query-examples.md`.

---

## ADF (Atlassian Document Format)

ADF is Jira's JSON-based format for rich text content in descriptions and comments.

### Basic ADF Structure

```typescript
// Simple text paragraph
const adf = {
  type: 'doc',
  version: 1,
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: 'Hello, world!'
        }
      ]
    }
  ]
};
```

### Text Formatting

**Bold, italic, code**:
```typescript
{
  type: 'doc',
  version: 1,
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: 'This is ',
          marks: []
        },
        {
          type: 'text',
          text: 'bold',
          marks: [{ type: 'strong' }]
        },
        {
          type: 'text',
          text: ', '
        },
        {
          type: 'text',
          text: 'italic',
          marks: [{ type: 'em' }]
        },
        {
          type: 'text',
          text: ', and '
        },
        {
          type: 'text',
          text: 'code',
          marks: [{ type: 'code' }]
        }
      ]
    }
  ]
}
```

### Links

```typescript
{
  type: 'text',
  text: 'Click here',
  marks: [
    {
      type: 'link',
      attrs: {
        href: 'https://example.com'
      }
    }
  ]
}
```

### Code Blocks

```typescript
{
  type: 'codeBlock',
  attrs: {
    language: 'typescript'
  },
  content: [
    {
      type: 'text',
      text: 'function hello() {\n  console.log("Hello");\n}'
    }
  ]
}
```

### Lists

**Bullet list**:
```typescript
{
  type: 'bulletList',
  content: [
    {
      type: 'listItem',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'First item'
            }
          ]
        }
      ]
    },
    {
      type: 'listItem',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Second item'
            }
          ]
        }
      ]
    }
  ]
}
```

**Ordered list**:
```typescript
{
  type: 'orderedList',
  content: [
    // Same listItem structure as bulletList
  ]
}
```

### Helper Functions

```typescript
// Create simple text paragraph
function createParagraph(text: string) {
  return {
    type: 'paragraph',
    content: [
      {
        type: 'text',
        text
      }
    ]
  };
}

// Create ADF document
function createADFDocument(...paragraphs: any[]) {
  return {
    type: 'doc',
    version: 1,
    content: paragraphs
  };
}

// Usage
const doc = createADFDocument(
  createParagraph('First paragraph'),
  createParagraph('Second paragraph')
);
```

For complete ADF specification and templates, see `references/adf-format-guide.md` and `examples/adf-comment-templates.md`.

---

## Issue Detection and Parsing

### Jira URL Patterns

```typescript
// Jira issue URL pattern
const JIRA_ISSUE_URL = /https?:\/\/([^\/]+)\.atlassian\.net\/browse\/([A-Z]+-\d+)/g;

// Custom Jira domain
const JIRA_CUSTOM_URL = /https?:\/\/jira\.([^\/]+)\.com\/browse\/([A-Z]+-\d+)/g;

function detectJiraIssues(text: string) {
  const matches = Array.from(text.matchAll(JIRA_ISSUE_URL));

  return matches.map(match => ({
    url: match[0],
    domain: match[1],
    key: match[2]
  }));
}

// Example
const text = "See https://mycompany.atlassian.net/browse/PROJ-123";
const issues = detectJiraIssues(text);
// => [{ url: "...", domain: "mycompany", key: "PROJ-123" }]
```

### Jira Issue Key Pattern

```typescript
// Issue key pattern (e.g., PROJ-123)
const JIRA_KEY = /\b([A-Z]{2,10}-\d+)\b/g;

function extractJiraKeys(text: string): string[] {
  const matches = Array.from(text.matchAll(JIRA_KEY));
  return matches.map(m => m[1]);
}

// Example
const text = "Implements PROJ-123 and fixes PROJ-456";
const keys = extractJiraKeys(text);
// => ["PROJ-123", "PROJ-456"]
```

### Auto-fetch Issue Details

```typescript
async function fetchJiraIssue(key: string) {
  const response = await jiraClient.get(`/issue/${key}`);
  return {
    key: response.data.key,
    summary: response.data.fields.summary,
    status: response.data.fields.status.name,
    assignee: response.data.fields.assignee?.displayName,
    url: `https://your-domain.atlassian.net/browse/${key}`
  };
}

// Auto-enrich text with issue details
async function enrichWithJiraData(text: string) {
  const keys = extractJiraKeys(text);
  const issues = await Promise.all(keys.map(fetchJiraIssue));

  let enriched = text;
  issues.forEach(issue => {
    const pattern = new RegExp(issue.key, 'g');
    enriched = enriched.replace(
      pattern,
      `[${issue.key}](${issue.url}) (${issue.summary})`
    );
  });

  return enriched;
}
```

---

## Sprint Management

### Sprint Planning Workflow

```bash
# 1. Create new sprint
acli jira --action createSprint \
  --board "PROJ Board" \
  --name "Sprint 25" \
  --startDate "2024-01-15" \
  --endDate "2024-01-28"

# 2. Add issues to sprint (from JQL query)
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready'" \
  --outputFormat 999 | \
  acli jira --action addIssuesToSprint \
    --sprint "Sprint 25" \
    --issue "@-"

# 3. Start sprint
acli jira --action startSprint \
  --sprint "Sprint 25"
```

### Sprint Reporting

```typescript
interface SprintMetrics {
  name: string;
  total: number;
  completed: number;
  inProgress: number;
  todo: number;
  velocity: number;
}

async function getSprintMetrics(sprintId: string): Promise<SprintMetrics> {
  const response = await jiraClient.get(`/sprint/${sprintId}/issues`);
  const issues = response.data.issues;

  const completed = issues.filter((i: any) => i.fields.status.name === 'Done').length;
  const inProgress = issues.filter((i: any) => i.fields.status.name === 'In Progress').length;
  const todo = issues.filter((i: any) => i.fields.status.name === 'To Do').length;

  return {
    name: response.data.sprint.name,
    total: issues.length,
    completed,
    inProgress,
    todo,
    velocity: (completed / issues.length) * 100
  };
}
```

---

## Quick Reference

### Essential acli Commands
- `acli jira --action getIssueList --jql "query"` - Query issues
- `acli jira --action createIssue --project PROJ --type Story --summary "..."` - Create issue
- `acli jira --action transitionIssue --issue KEY --transition "Status"` - Change status
- `acli jira --action addIssuesToSprint --sprint "Sprint" --issue "KEY"` - Add to sprint
- `acli jira --action getSprintList --board "Board"` - List sprints

### Key API Endpoints
- `GET /issue/{issueKey}` - Get issue
- `POST /issue` - Create issue
- `PUT /issue/{issueKey}` - Update issue
- `POST /issue/{issueKey}/transitions` - Transition issue
- `POST /issue/{issueKey}/comment` - Add comment

### JQL Quick Patterns
- `project = PROJ AND assignee = currentUser()` - My issues
- `sprint in openSprints()` - Current sprint
- `status = "To Do" ORDER BY priority DESC` - Prioritized backlog
- `created >= -7d` - Recent issues

### ADF Basics
- Paragraph: `{type: 'paragraph', content: [{type: 'text', text: '...'}]}`
- Bold: `marks: [{type: 'strong'}]`
- Code: `marks: [{type: 'code'}]`
- Link: `marks: [{type: 'link', attrs: {href: '...'}}]`

### Best Practices
- Always use API tokens (not passwords) for authentication
- Cache Jira project metadata to reduce API calls
- Use JQL for complex queries instead of filtering in code
- Validate issue keys before API calls (format: PROJECT-123)
- Use ADF for all rich text content (descriptions, comments)
- Handle Jira API rate limits (10 requests/second)

---

## Related Skills

- **jira-adf-generator**: Generate properly formatted ADF for Jira comments
- **github-integration**: Alternative provider integration for comparison
- **agency-workflow-patterns**: General workflow automation applicable to any provider
- **github-workflow-best-practices**: Sprint concepts and planning patterns
